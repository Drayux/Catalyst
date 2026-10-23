#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

FSMODE=$(getarg fsmode=)
FSMODE=${FSMODE:-overlay}
warn "DEBUG: fsmode resolved to '$FSMODE'"

SYSROOT=/sysroot
OVERLAY_DEV=/dev/disk/by-label/OVERLAY
OVERLAY_MNT=/run/overlay-pt
SNAP_DIR=/run/snapshot
DIRS="usr etc var"

# ── helpers ──────────────────────────────────────────────────────────────────

mount_overlay_pt() {
    mkdir -p "$OVERLAY_MNT"
    mount "$OVERLAY_DEV" "$OVERLAY_MNT"
}

ensure_overlay_structure() {
    # Creates upper/ and work/ subdirs on overlay_pt if absent
    for dir in $DIRS; do
        mkdir -p "$OVERLAY_MNT/upper/$dir"
        mkdir -p "$OVERLAY_MNT/work/$dir"
    done
}

mount_overlays() {
    local upper_root=$1
    local work_root=$2
    for dir in $DIRS; do
        mount -t overlay overlay \
            -o lowerdir="$SYSROOT/$dir",upperdir="$upper_root/$dir",workdir="$work_root/$dir" \
	    "$SYSROOT/$dir"
    done
}

overlay_pt_is_dirty() {
    for dir in $DIRS; do
        local upper="$OVERLAY_MNT/upper/$dir"
        if [ -d "$upper" ] && [ -n "$(ls -A "$upper" 2>/dev/null)" ]; then
            return 0  # dirty
        fi
    done
    return 1  # clean
}

clean_overlay_pt() {
    for dir in $DIRS; do
        rm -rf "${OVERLAY_MNT:?}/upper/$dir"
        rm -rf "${OVERLAY_MNT:?}/work/$dir"
        mkdir -p "$OVERLAY_MNT/upper/$dir"
        mkdir -p "$OVERLAY_MNT/work/$dir"
    done
}

# ── boot modes ───────────────────────────────────────────────────────────────

case "$FSMODE" in
    overlay)
        mount_overlay_pt
        ensure_overlay_structure
        mount_overlays "$OVERLAY_MNT/upper" "$OVERLAY_MNT/work"
        ;;

    snapshot)
        # upper lives entirely in RAM; overlay_pt is untouched
        for dir in $DIRS; do
            mkdir -p "$SNAP_DIR/upper/$dir"
            mkdir -p "$SNAP_DIR/work/$dir"
        done
        mount_overlays "$SNAP_DIR/upper" "$SNAP_DIR/work"
        ;;

    live)
        mount_overlay_pt

        if overlay_pt_is_dirty; then
            echo ""
            echo "WARNING: overlay_pt has uncommitted changes."
            echo "Booting live and then committing later may produce a stale overlay."
            echo ""
            echo "  y  — clean overlay_pt now and continue booting"
            echo "  n  — abort and return to GRUB"
            echo ""
            printf "Choice: "
            read -r answer </dev/console

            case "$answer" in
                y|Y)
                    #clean_overlay_pt
		    echo 'clean_overlay_pt stubbed for now'
                    ;;
                *)
                    umount "$OVERLAY_MNT"
                    echo ""
                    echo "Live mode aborted. Rebooting to GRUB menu..."
                    sleep 3
                    reboot -f
                    ;;
            esac
        fi

        umount "$OVERLAY_MNT"
        # Base is already mounted rw via the GRUB cmdline; nothing more to do
        ;;

    commit)
        mount_overlay_pt
        ensure_overlay_structure

        for dir in $DIRS; do
            # Mount the merged view into a temporary path
            local merged="/run/merged-$dir"
            mkdir -p "$merged"

            mount -t overlay overlay \
                -o lowerdir="$SYSROOT/$dir",\
upperdir="$OVERLAY_MNT/upper/$dir",\
workdir="$OVERLAY_MNT/work/$dir" \
                "$merged"

            # Sync the merged view onto the base.
            # rsync --delete sees whiteout targets as absent in merged,
            # so it deletes them from base without any whiteout handling.
            #rsync -aAX --delete "$merged/" "$SYSROOT/$dir/"
            echo 'rsync -aAX --delete "$merged/" "$SYSROOT/$dir/" stubbed for now'

            umount "$merged"
        done

        # Clear overlay_pt so it is clean for the next upgrade cycle
        clean_overlay_pt
        umount "$OVERLAY_MNT"

        # Continue booting directly into overlay mode with empty upper
        mount_overlay_pt
        mount_overlays "$OVERLAY_MNT/upper" "$OVERLAY_MNT/work"
        ;;

esac
