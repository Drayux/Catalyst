#!/bin/sh

# Add scripts folder to the path for custom commands
SCRIPT_PATH=$(realpath $(dirname "$0")/scripts)
export PATH="$SCRIPT_PATH:$PATH"
