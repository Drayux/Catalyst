#!/bin/bash

WM_DISPLAYS='DP-3 HDMI-A-1'

setup() {
	doas /etc/greetd/scripts/enable_displays.sh $WM_DISPLAYS
	export XDG_CACHE_HOME=${XDG_CACHE_HOME:-${XDG_RUNTIME_DIR}/cache}
	export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
	export XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.var/local}
	export XDG_STATE_HOME=${XDG_STATE_HOME:-${HOME}/.var/state}
}

# An unexpected caveat of booting with the 'video=' parameter is that
# setting the status to 'on' once actually works perfectly, so no cleanup
# routine is needed for now.
# cleanup() {}

# trap cleanup EXIT INT TERM

# setup && /bin/bash
setup && dbus-run-session $@
