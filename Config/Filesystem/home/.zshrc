# Parent directory for zsh scripts
export ZSH_CONFIG_DIR="$HOME/.config/zsh"

# Configure OH-MY-ZSH
source $ZSH_CONFIG_DIR/ohmyzsh/config.sh

# Load alias scripts (usually complex single commands with many parameters)
source $ZSH_CONFIG_DIR/aliases.zsh
source $ZSH_CONFIG_DIR/scripts.zsh
