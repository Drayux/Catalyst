# -- ENVIRONMENT VARIABLES --

export EDITOR="/usr/bin/micro"
export GIT_CONFIG_GLOBAL="$HOME/.config/git.conf"
export WINEPREFIX="$HOME/.local/share/wine"
export ZSH_CONFIG="$HOME/.config/zsh"

# -- SCRIPTS --

# ZSH (and ohmyzsh) config
source $ZSH_CONFIG/config.sh
source $ZSH_CONFIG/ohmyzsh/config.zsh

# Aliases
source $ZSH_CONFIG/aliases.zsh
source $ZSH_CONFIG/scripts.zsh
