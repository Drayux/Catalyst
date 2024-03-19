export ZSH_CONFIG_DIR="$HOME/.config/zsh"

source $ZSH_CONFIG_DIR/environment.sh
source $ZSH_CONFIG_DIR/aliases.sh
source $ZSH_CONFIG_DIR/scripts.sh
source $ZSH_CONFIG_DIR/config.sh

eval "$(starship init zsh)"
