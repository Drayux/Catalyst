#!/bin/zsh
#echo "this is a test: $@
yay -Ss $@ --color=always | less -r --quit-if-one-screen
