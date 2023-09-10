#!/bin/zsh
# This alias allows me to specify git config values in a file other than ~/.gitconfig
# Note however that using the git config --add ... will generate a new ~/.gitconfig
alias git='git -c include.path="~/.config/git.conf"'

# Print all directories with a trailing '/'
#alias ls="ls -p"

# Include Arch Linux packages for consideration
# TODO: Find alternative means of privlege elevation
#alias pacman-arch='sudo pacman --config=/etc/pacman-arch.conf'

# Power management
alias reboot='sudo reboot'
alias shutdown='sudo poweroff'
