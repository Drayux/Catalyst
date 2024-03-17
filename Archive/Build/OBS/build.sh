#!/bin/sh

# RUN FROM BASE DIR OF OBS GIT CLONE

# Build Reference -> https://github.com/obsproject/obs-studio/wiki/Building-OBS-Studio
# Portable Reference -> https://github.com/obsproject/obs-studio/wiki/build-instructions-for-linux
# Plugin Template -> https://github.com/obsproject/obs-plugintemplate

PORTABLE=ON

# Setup
if [ "$PORTABLE" = ON ] ; then
	mkdir -p "install"
	INSTALL_PATH=$(realpath "install")
else
	echo "WARNING currently set to install OBS build onto system."
	read -p "Do you wish to continue? (y/n) " CHOICE
	case $CHOICE in
		y) ;;
		Y) ;;
		*) exit 1 ;;
	esac
	INSTALL_PATH=/usr
fi
echo "Install path set to '$INSTALL_PATH'"


# Assume CEF located in parent folder
CEF_PATH=$(realpath ../cef* | head -n 1)
echo "CEF path assumed as '$CEF_PATH'"

mkdir -p build
cd build


# For non portable: -DLINUX_PORTABLE=OFF -DCMAKE_INSTALL_PREFIX=/usr
# Jack allows for creating generic nodes for unique circumstances
# Pulse is required for audio monitoring


# ENABLE_EXT_PLUGINS -> Custom parameter for third party plugins
cmake -DLINUX_PORTABLE="$PORTABLE" -DOBS_MULTIARCH_SUFFIX=64 -DQT_VERSION=6 -DCMAKE_INSTALL_PREFIX="$INSTALL_PATH" -DENABLE_BROWSER=ON -DCEF_ROOT_DIR="$CEF_PATH" -DENABLE_AJA=OFF -DENABLE_DECKLINK=OFF -DENABLE_ALSA=OFF -DENABLE_JACK=ON -DENABLE_PULSEAUDIO=ON -DENABLE_SNDIO=ON -DENABLE_VST=OFF ..

# -- Experimental debugging settings --
# cmake -DLINUX_PORTABLE="$PORTABLE" -DQT_VERSION=6 -DOBS_MULTIARCH_SUFFIX=64 -DENABLE_WAYLAND=OFF -DENABLE_PIPEWIRE=OFF -DCMAKE_INSTALL_PREFIX="$INSTALL_PATH" -DENABLE_BROWSER=ON -DCEF_ROOT_DIR="$CEF_PATH" -DENABLE_AJA=OFF -DENABLE_DECKLINK=OFF -DENABLE_ALSA=OFF -DENABLE_JACK=ON -DENABLE_PULSEAUDIO=ON -DENABLE_SNDIO=ON -DENABLE_EXT_PLUGINS=OFF ..

make -j4

# Install
if [ "$PORTABLE" = ON ] ; then
	make install
else
	sudo make install
fi
