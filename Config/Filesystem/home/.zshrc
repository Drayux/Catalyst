# -- ENVIRONMENT VARIABLES --
export GIT_CONFIG_GLOBAL="$/HOME/.config/gitconfig"

# Parent directory for zsh scripts
export ZSH_CONFIG_DIR="$HOME/.config/zsh"

# -- SCRIPTS --
# Configure OH-MY-ZSH
source $ZSH_CONFIG_DIR/ohmyzsh/config.sh

# Alias scripts (usually complex single commands with many parameters)
source $ZSH_CONFIG_DIR/aliases.zsh
source $ZSH_CONFIG_DIR/scripts.zsh
