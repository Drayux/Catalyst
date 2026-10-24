#!/bin/bash

check() {
	# Unconditionally include this module (0; return 1 to exclude)

	# An advanced version of this configuration could check if the coresponding
	# GRUB configuration exists before including this, but we'll just drop to
	# live mode if no `fsmode` param is given.

	return 0
}

depends() {
	# Base is the default "0" module; rootfs because that needs to be mounted
	# for this to matter at all
	echo "base rootfs-block"
}

install() {
	# pre-pivot is the last hook before the real FS goes "live"
	# https://wiki.gentoo.org/wiki/Dracut#Hook_scripts

	# TBH no idea priority to use; guessing right in the middle unless it
	# appears to cause me trouble

	inst_hook pre-pivot 80 "$moddir/mount-overlay.sh"
	# ^^ should be: /usr/lib/dracut/modules.d/99rootfs-overlay/mount-rootfs-overlay.sh

	# The overlay script depends on findmnt and rsync
	dracut_install findmnt rsync
}
