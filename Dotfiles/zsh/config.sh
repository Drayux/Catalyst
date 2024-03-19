#!/bin/sh

HISTFILE="$HOME/.local/zsh/zshhst"
HISTSIZE=4096
SAVEHIST=4096
setopt autocd extendedglob
unsetopt beep nomatch notify

bindkey -e
bindkey 	"^[[1;5C"	forward-word
bindkey 	"^[[1;5D"	backward-word
bindkey 	"^[[H"		beginning-of-line
bindkey 	"^[[F"		end-of-line
bindkey 	"^[[3~"		delete-char
