#!/bin/zsh
SCRIPT_PATH=$(realpath $(dirname "$0")/scripts)

# Aliases for running user scripts (usually found ./scripts)
alias pacss="zsh $SCRIPT_PATH/pacss.zsh"
