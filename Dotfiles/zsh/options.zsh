#!/bin/zsh

HISTFILE="${HIST_DIR}/zsh"
HISTSIZE=5000
SAVEHIST=5000
setopt autocd extendedglob
setopt hist_ignore_all_dups
unsetopt beep nomatch notify

bindkey -e
bindkey 	"^[[1;5C"	forward-word
bindkey 	"^[[1;5D"	backward-word
bindkey 	"^[[H"		beginning-of-line
bindkey 	"^[[F"		end-of-line
bindkey 	"^[[3~"		delete-char

# >> Plugins <<
# zsh-syntax-highlighting should be loaded last
source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh

