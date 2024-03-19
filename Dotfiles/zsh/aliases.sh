#!/bin/sh

# Specify the location of the local git config
# Note that running `git config --add ...` generates a new ~/.gitconfig
alias git='git -c include.path="$HOME/.config/git/local.conf"'

# Specify the location of the wget history file
alias wget='wget --hsts-file "$HOME/.local/zsh/wgethst"'

# Power management
alias reboot='loginctl reboot'
alias shutdown='loginctl poweroff'
