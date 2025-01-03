#!/bin/zsh

export GIT_CONFIG_GLOBAL="${XDG_CONFIG_HOME}/git/global"
export WINEPREFIX="${XDG_DATA_HOME}/wine"
export CARGO_HOME="${XDG_CACHE_HOME}/cargo"

export HIST_DIR="${HOME}/.local/hist"
export LESSHISTFILE="${HIST_DIR}/less"
export PYTHON_HISTORY="${HIST_DIR}/python"

export LC_CTYPE="en_US.UTF-8"	# https://github.com/spaceship-prompt/spaceship-prompt/issues/726#issuecomment-534231326

# TODO: Some of these environment variables pertain to more than just CLI tools!
# > As a result, they may need to be set elsewhere!

# export QT_QPA_PLATFORM=wayland
# export GDK_BACKEND=wayland,x11
# export XCURSOR_SIZE=24

# Should be handled by flatpak
# export MOZ_ENABLE_WAYLAND=1
# something something kitty wayland

# Handled by PAM (/etc/security/pam_env.conf)
# export XDG_CONFIG_DIR="$HOME/.config"
# export ZDOTDIR="$HOME/.config/zsh"

# Add scripts folder to the path for custom commands
SCRIPT_PATH=$(realpath $(dirname "$0")/scripts)
export PATH="$SCRIPT_PATH:$PATH"

