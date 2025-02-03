#!/bin/zsh

# Power management
if which loginctl 2>&1 > /dev/null; then
	alias reboot='loginctl reboot'
	alias shutdown='loginctl poweroff'
fi # TODO: echo mem > /sys/power/state

# Git shortcuts
# > Handy log shortcut, does not pull from config
alias log='git log --graph --oneline --all'
# > Specify the location of the local git config
# alias git='git -c include.path="${XDG_CONFIG_HOME}/git/local"'
alias git='git -c include.path="${XDG_CONFIG_HOME}/git/local"'

# Hist file relocation
alias wget='wget --hsts-file "${HIST_DIR}/wget"'

# For funsies
alias neofetch='fastfetch'

