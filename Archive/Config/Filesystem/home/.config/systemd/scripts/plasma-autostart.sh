#!/bin/sh

# Systemd service script to autostart plasma wayland on user login
# Specified per-user, so (in my case) root does not get a DE automatically
# TODO: I'd love to have this script restart if I log out of the tty and then log back in

# Called on systemctl --user start plasma-autostart.service
start_service() {
	echo "Attempting to launch..."
	if [ ! $(pidof /usr/bin/plasmashell) ] ; then
		# Only start if not already running
		# Returns /usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland
		# ...which my dumbass couldn't figure out that dbus-run... takes startplasma-wayland as an argument
		$(awk -F = '/^Exec/{print $2}' /usr/share/wayland-sessions/plasmawayland.desktop) &
		# maybe auto logout once wayland is closed (service type would have to be changed from forking to simple)
	fi
}

# Called on systemctl --user stop plasma-autostart.service
# stop_service() {
	# TODO: Not sure if this should do anything...
	# 		If I want to "stop the autostarter"
	#		I don't believe I want to exit the DE automatically }

case $1 in
	start)
		start_service
		;;
	stop)
		stop_service
		;;
esac
