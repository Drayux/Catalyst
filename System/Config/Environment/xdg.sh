#!/bin/sh

# XDG directory configuration (/etc/profile.d/)
# > Overrides defaults provided by elogind

# Desktop spec environment
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME="${HOME}/.local/cache"
export XDG_STATE_HOME="${HOME}/.local/state"

# Runtime directory (/run/usr/...) for session management
if test -z "${XDG_RUNTIME_DIR}"; then
	rundir="/tmp/run/${UID}"
	mkdir -p ${rundir} -m 0700
	export XDG_RUNTIME_DIR="${rundir}"
fi
