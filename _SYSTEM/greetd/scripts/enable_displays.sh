#!/bin/bash

# Requires elevation, see /etc/doas.conf
# echo on > /sys/class/drm/card0-HDMI-A-1/status

CARD_NUM=0

for display in $@; do
	# Avoid risk of path injection
	# I.E., $display is 'DP-2/../../boot/whatever'
	if echo $display | egrep '[^a-zA-Z0-9-]'; then
		echo "INVALID DISPLAY '$display'" >&2
		exit
	fi

	path="/sys/class/drm/card${CARD_NUM}-${display}/status"
	if ls $path 2>/dev/null >/dev/null; then
		echo on > $path
	fi
done
