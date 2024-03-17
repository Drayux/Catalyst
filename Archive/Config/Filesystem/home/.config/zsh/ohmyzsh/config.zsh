#!/bin/zsh

# Variable required for many zsh scripts and plugins
export ZSH="$HOME/.config/zsh/ohmyzsh"

# -- GENERAL --
CASE_SENSITIVE="false"					# Should pattern matching be case-sensitive
HYPHEN_INSENSITIVE="false"				# Should hyphens be "case-sensitive"
ENABLE_CORRECTION="true"				# Should ZSH attempt auto-corrections (TODO: Check if I like how this feels)

zstyle ':omz:update' mode auto      	# options: disabled, auto, reminder
# zstyle ':omz:update' frequency 13		# Auto-updater frequency (days)


# -- EXTRA --
COMPLETION_WAITING_DOTS="true"
# COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
DISABLE_UNTRACKED_FILES_DIRTY="true"	# Allows for much faster git checking
HIST_STAMPS="yyyy/mm/dd"				# History command date format


# -- COMPATIBILITY --
# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"


# -- THEME --
# ZSH_THEME="starship"
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
if [[ $(print -P %y | grep tty) ]] ; then
	# We are inside of a TTY
	ZSH_THEME="darkblood"
else
	# We are in an emulator
	ZSH_THEME="agnoster"
fi


# -- PLUGINS --
plugins=(
  git
  # zsh-autosuggestions
)


# -- LOAD ZSH --
source $ZSH/oh-my-zsh.sh
