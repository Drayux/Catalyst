#!/bin/sh

export CARGO_HOME="$HOME/.cache/cargo"
export EDITOR="/usr/bin/micro"
export GIT_CONFIG_GLOBAL="$HOME/.config/git/global"
export LC_CTYPE="en_US.UTF-8"	# https://github.com/spaceship-prompt/spaceship-prompt/issues/726#issuecomment-534231326
export LESSHISTFILE="$HOME/.cache/zsh/lesshst"
export PYTHON_HISTORY="$HOME/.cache/zsh/pyhst"
export WINEPREFIX="$HOME/.local/wine"


# TODO: Some of these environment variables pertain to more than just CLI tools!
# 	    As a result, they may need to be set elsewhere!

# export QT_QPA_PLATFORM=wayland
# export GDK_BACKEND=wayland,x11
# export XCURSOR_SIZE=24

# Should be handled by flatpak
# export MOZ_ENABLE_WAYLAND=1

# Handled by PAM (/etc/security/pam_env.conf)
# export XDG_CONFIG_DIR="$HOME/.config"
# export ZDOTDIR="$HOME/.config/zsh"
