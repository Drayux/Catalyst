#!/bin/zsh
# Prefer using a service to call de-autostart instead!
LOGPATH="/var/log/scripts/launch-de"

launch_wayland () {
	# startplasma-wayland
	$(awk -F = '/^Exec/{print $2}' /usr/share/wayland-sessions/plasmawayland.desktop)
}

launch_xorg () {
	# TODO: Xorg seems to need a number more features to run correctly (pipewire not connecting)
	# TODO: Look into xauthority as this may be the issue (compare with sx script)
	# Check that xorg is not running, only launch if so
	if [ ! $(pidof /usr/lib/Xorg) ] ; then
		sudo /usr/bin/Xorg $@ &	
	fi

	# Run XRANDR config
	# TODO (move this to its own function maybe?)
		
	# startplasma-x11
	DISPLAY=:0 $(awk -F = '/^Exec/{print $2}' /usr/share/xsessions/plasma.desktop)
	
	# Quit the X-server after logout
	sudo kill $(pidof /usr/lib/Xorg)
}

# -- SCRIPT ENTRY --

# Ensure that a DE is not already running
PROC=$(ps -ef | grep -v grep | grep -E 'startplasma-wayland|startplasma-x11')
if [ "$PROC" ] ; then
	TTYNO=$(echo $PROC | grep -Eo 'tty[0-9]+')
	echo "Plasma already running on $TTYNO. Aborting!"
	exit 1
fi

# Set additional environment variables (after the DE check succeeds)
# export QT_QPA_PLATFORM=xcb	# This one forces all of QT to be X11, which means only X11 windwos are recognized by panels such as latte and the global app menu

# Process script arguments
# -w or <none> --> Launch a wayland env
# -x --> Launch an X env
# -xs --> Launch an X env with a custom configuration file built for streaming
if [ "$#" -gt 0 ] ; then	
	case $1 in
		-w)
			launch_wayland
			;;
		-x)
			launch_xorg
			;;
		-xs)
			echo "currently disabled soz bb"
			exit 0
			
			# XORG_ARGS="ooga booga"
			# launch_xorg $XORG_ARGS
			launch_xorg -config /etc/X11/xorg-stream.conf
			;;
		*)
			echo "Unrecognized option '$1'"
	esac
else
	launch_wayland
fi
