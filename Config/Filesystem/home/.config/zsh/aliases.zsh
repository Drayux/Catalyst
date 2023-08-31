#!/bin/zsh
# This alias allows me to specify git config values in a file other than ~/.gitconfig
# Note however that using the git config --add ... will generate a new ~/.gitconfig
alias git='git -c include.path="~/.config/git.conf"'

# Print all directories with a trailing '/'
#alias ls="ls -p"

# Search for packages with fancy output
# alias pacss="yay -Ss $@ --color=always | less -r --quit-if-one-screen"
