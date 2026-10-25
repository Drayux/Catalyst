#!/bin/sh

### LLM DISCLOSURE ###

# While I'd love for every line of my config to be hand-written and carefully
# placed, it was quickly becoming apparent that a trivial part of the process
# was growing way beyond scope. Thus, the majority of this logic is not my own.

# This nature of this script's role means that it is quite difficult to test
# small changes incrementally. I have a clear idea what the ultimate effect
# should be (i.e., verifiable core commands to expect per each mode.) But with
# my limited comfort in bash, deferring the initial pass of this task to an LLM
# had the effect of saving me countless cycles of "reboot and check the logs."

# As it is now, I have inspected and modified nearly every line of this script.


# ── Shim system programs for testing ──────────────────────────────────────────

# mkdir -p /mnt/sandbox/shims
# for cmd in rsync rm rmdir mkdir mount umount reboot; do
    # cat > /mnt/sandbox/shims/$cmd << 'EOF'
# #!/bin/sh
# echo " > `basename $0` $@"
# EOF
    # chmod +x /mnt/sandbox/shims/$cmd
# done
# PATH=/mnt/sandbox/shims:$PATH


# ──────────────────────────────────────────────────────────────────────────────

command -v getarg > /dev/null || . /lib/dracut-lib.sh

FSMODE=$(getarg fsmode=)
if [[ -z "$FSMODE" ]]; then
	# If I'm having issues, I can edit the GRUB entry to remove this param
	# before booting to skip the script entirely
	return
fi

PRE_PIVOT_ROOT=/sysroot
OVERLAY_PT=/dev/disk/by-label/OVERLAY
OVERLAY_ROOT=

OVERLAY_MOUNT_DIR=/run/overlay
SNAPSHOT_MOUNT_DIR=/run/snapshot

# TODO: Consider including opt in here
MAP="usr etc var"

mount_overlay() {
	OVERLAY_ROOT="$OVERLAY_MOUNT_DIR"
	mkdir -p "$OVERLAY_ROOT"
	mount "$OVERLAY_PT" "$OVERLAY_ROOT"
}

mount_snapshot() {
	OVERLAY_ROOT="$SNAPSHOT_MOUNT_DIR"
	mkdir -p "$OVERLAY_ROOT"
	# Psuedo mount for symmetry
	# (No actual mount call since /run is already tmpfs)
}


# ── Shared helpers ────────────────────────────────────────────────────────────

# ensure_overlay_structure() {
	# for dir in $MAP; do
		# mkdir -p "$OVERLAY_ROOT/upper/$dir"
		# mkdir -p "$OVERLAY_ROOT/work/$dir"
	# done
# }

map_overlay_dirs() {
	for dir in $MAP; do
		upperdir="$OVERLAY_ROOT/upper/$dir"
		workdir="$OVERLAY_ROOT/work/$dir"
		mkdir -p "$upperdir"
		mkdir -p "$workdir"
		mount -t overlay overlay \
			-o lowerdir="$PRE_PIVOT_ROOT/$dir",upperdir="$upperdir",workdir="$workdir" \
			"$PRE_PIVOT_ROOT/$dir"
	done
}

# NOTE: This was originally intended as a safety-check to avoid a stale commit
# However, I failed to realize how many items in the rootfs get modified during
# a normal boot alone, so this triggers on EVERY overlay boot unless just wiped.
overlay_is_dirty() {
	for dir in $MAP; do
		local upper="$OVERLAY_ROOT/upper/$dir"
		if [ -d "$upper" ] && [ -n "$(ls -A "$upper" 2>/dev/null)" ]; then
			return 0  # dirty
		fi
	done
	return 1  # clean
}

# TODO: If I made an openrc service to create this timestamp instead after all
# of the other files are updated (if this is the case) then I could create a
# check that looks if the timestamp is the newest file in the partition or not
# Creates a normal timestamp for the overlay, or in the case of snapshot mode,
# this can be easily used by userspace to remind me that I'm in snapshot mode.
timestamp_overlay() {
	timestamp_path="$OVERLAY_ROOT"/.timestamp
	[ -f $timestamp_path ] || date '+%s' > $timestamp_path
}


# ── Functions for the real overlay ONLY! ──────────────────────────────────────

get_overlay_age() {
	local timestamp_path="$OVERLAY_MOUNT_DIR"/.timestamp
	if [[ ! -f "$timestamp_path" ]]; then
		printf '%s' 'ages'
		return
	fi

	local timestamp=$(<"$timestamp_path")

	# TODO: Consider deleting the file if this triggers
	timestamp=${timestamp//[[:space:]]/}
	if [[ ! "$timestamp" =~ ^[0-9]+$ ]]; then
		printf '%s' 'ages'
		return
	fi

	local delta=$(( $(date +%s) - timestamp ))
	local d=$(( delta / 86400 ))
	local h=$(( delta % 86400 / 3600 ))
	local m=$(( delta % 3600 / 60 ))
	local s=$(( delta % 60 ))

	local out=()
	(( d )) && out+=("${d}d")
	(( h )) && out+=("${h}h")
	(( m )) && out+=("${m}m")
	(( s || ${#out[@]} == 0 )) && out+=("${s}s")

	local IFS=' '
	printf '%s' "${out[*]}"
}

commit_overlay() {
	mount_snapshot

	# map_overlay_dirs -- TODO: For now, a sloppy copy to test the important bits
	# The only difference is that instead of mounting overtop the rootfs, we
	# map the merged overlay FS to the snapshot directory (to prepare for rsync)
	for dir in $MAP; do
		upperdir="$OVERLAY_MOUNT_DIR/upper/$dir"
		workdir="$OVERLAY_MOUNT_DIR/work/$dir"
		overlayfs_dir="$SNAPSHOT_MOUNT_DIR/$dir"

		mkdir -p "$upperdir"
		mkdir -p "$workdir"
		mkdir -p "$overlayfs_dir"
		mount -t overlay overlay \
			-o lowerdir="$PRE_PIVOT_ROOT/$dir",upperdir="$upperdir",workdir="$workdir" \
			"$overlayfs_dir"

		# Any regular FS read to the "merged overlay view" ($overlayfs_dir)
		# will show all files as though the overlayfs were as one. This is
		# exactly the format we wish to replicate in the live system rootfs

		live_target="$SYSROOT/${dir}"
		# rsync_target="$SYSROOT/.${dir}-sync"
		# backup_target="$SYSROOT/.${dir}-backup"

		# DIRECT VERSION
		# TODO: My atomic version is nice and secure, but runs the risk of
		# exceeding available disk space. If that becomes a concern, this is
		# definitively the method to use. But if not, the atomic version is
		# just a bit safer -- ultimately I want to make this an option, I think.

		# -a includes about all the stuff for a 'mirror' (like owner preservation)
		# rsync -aAX --delete "$overlayfs_dir/" "$live_target/"
		rsync -aAX --delete "$overlayfs_dir/" "$live_target/"

		# ATOMIC VERSION
		# rsync -aAX "$overlayfs_dir/" "$rsync_target/"
		# mv "$live_target" "$backup_target"
		# mv "$rsync_target" "$live_target"
		# rm -rf "$backup_target"

		umount "$overlayfs_dir"
	done

	# Cleanup -- assert snapshor dir is empty after unmounting
	# rmdir "$SNAPSHOT_MOUNT_DIR" # TODO: not included in UKI image
	rm -rf "$SNAPSHOT_MOUNT_DIR"
	OVERLAY_ROOT="$OVERLAY_MOUNT_DIR"
}

clean_overlay() {
	# Deliberately fails if /run/snapshot mounted instead
	for dir in $MAP; do
		rm -rf "${OVERLAY_MOUNT_DIR:?}/upper/$dir"
		rm -rf "${OVERLAY_MOUNT_DIR:?}/work/$dir"
		mkdir -p "$OVERLAY_MOUNT_DIR/upper/$dir"
		mkdir -p "$OVERLAY_MOUNT_DIR/work/$dir"
	done
	[ -f "$OVERLAY_MOUNT_DIR/.timestamp" ] && rm "$OVERLAY_MOUNT_DIR/.timestamp"
}


# ── Mode selection ────────────────────────────────────────────────────────────

echo "Booting with filesystem mode: $FSMODE"
case "$FSMODE" in
	# Live mode exits early
	live)
		mount_overlay

		if overlay_is_dirty; then
			echo ""
			echo "NOTICE: uncommitted changes found in rootfs overlay."
			echo "Booting live may produce a stale overlay cache."
			echo "—— Last commit: `get_overlay_age` ago"
			echo ""
			echo "  a — abort and return to GRUB"
			echo "  d — delete overlay and boot"
			echo "  c — commit overlay and boot"
			echo "  x — > continue boot (ignore) <"
			echo ""
			printf "Perform overlay operation? [ a/d/c/X ] > "

			while true; do
				read -r answer </dev/console || break;
				# answer=${answer//[[:space:]]/}
				case x"$answer" in
					xa|xA)
						echo "Abort: rebooting to GRUB..."
						umount "$OVERLAY_MOUNT_DIR"
						sleep 2
						reboot -f
						exit 0
						;;

					xd|xD)
						echo "Delete: cleaning cached overlay"
						clean_overlay
						break ;;
					xc|xC)
						echo "Commit: merging overlay with live"
						commit_overlay
						clean_overlay
						break ;;
					x|xx|xX)
						echo "Continue boot: no overlay operation"
						break ;;

					*) echo "Unknown selection" ;;
				esac
				printf "[ a/d/c/X ] > "
			done
		fi
		umount "$OVERLAY_MOUNT_DIR"
		# rmdir "$OVERLAY_MOUNT_DIR" # TODO: not included in UKI image
		rm -rf "$OVERLAY_MOUNT_DIR"
		;;

	advanced)
		echo ""
		echo "Maintenance options for rootfs overlay."
		echo "—— Last commit: `get_overlay_age` ago"
		echo ""
		echo "  a — abort and return to GRUB"
		echo "  d — delete cached overlay and boot"
		echo "    — or D to delete and return to GRUB"
		echo "  c — commit cached overlay and boot"
		echo "    — or C to commit and return to GRUB"
		echo "  x — > continue boot (preserve current overlay) <"
		echo ""
		printf "Perform overlay operation? [ a/d/c/X ] > "

		while true; do
			read -r answer </dev/console || break;
			# answer=${answer//[[:space:]]/}
			case x"$answer" in
				xa|xA)
					echo "Abort: rebooting to GRUB..."
					sleep 2
					reboot -f
					exit 0 ;;

				xd)
					echo "Delete: cleaning cached overlay"
					mount_overlay
					clean_overlay
					break ;;
				xD)
					echo "Delete: cleaning cached overlay"
					mount_overlay
					clean_overlay
					echo "Delete: done, rebooting to GRUB..."
					sleep 2
					reboot -f
					exit 0 ;;

				xc)
					echo "Commit: merging overlay with live"
					mount_overlay
					commit_overlay
					clean_overlay
					break ;;
				xC)
					echo "Commit: merging overlay with live"
					mount_overlay
					commit_overlay
					clean_overlay
					echo "Commit: done, rebooting to GRUB..."
					sleep 2
					reboot -f
					exit 0 ;;

				x|xx|xX)
					echo "Continue boot: no overlay operation"
					mount_overlay
					break ;;

				*) echo "Unknown selection" ;;
			esac
			printf "[ a/d/c/X ] > "
		done
		timestamp_overlay
		map_overlay_dirs
		;;
	overlay)
		mount_overlay

		timestamp_overlay
		map_overlay_dirs
		;;
	snapshot)
		mount_snapshot

		timestamp_overlay
		map_overlay_dirs
		;;
esac
