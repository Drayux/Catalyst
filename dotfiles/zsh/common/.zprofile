# PROFILE --> .zprofile
# Script is loaded first on every *LOGIN* shell

# https://github.com/spaceship-prompt/spaceship-prompt/issues/726#issuecomment-534231326
export LC_CTYPE="en_US.UTF-8"

# >>> Configure XDG directory locations <<<
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local"
export XDG_CACHE_HOME="${HOME}/.local/cache"
export XDG_STATE_HOME="${HOME}/.local/state"
if test -z "${XDG_RUNTIME_DIR}"; then
	rundir="/tmp/run/${UID}"
	mkdir -p ${rundir} -m 0700
	export XDG_RUNTIME_DIR="${rundir}"
fi

# >>> Relocate config files to preference <<<
export GIT_CONFIG_GLOBAL="${XDG_CONFIG_HOME}/gitconfig"

# >>> Relocate history files to preference <<<
HISTORY_PATH="${XDG_DATA_HOME}/history"
mkdir -p "${HISTORY_PATH}" # Ensure the directory exists
export HISTSIZE=8192       # For ZSH
export SAVEHIST=65536      # For ZSH
export HISTFILE="${HISTORY_PATH}/zsh"
export LESSHISTFILE="${HISTORY_PATH}/less"
export PYTHON_HISTORY="${HISTORY_PATH}/python"

# >>> Relocate data files to preference <<<
export GNUPGHOME="${XDG_DATA_HOME}/crypt"

# >>> Prepend user scripts to path <<<
SCRIPT_PATH="${XDG_CONFIG_HOME}/zsh/scripts"
export PATH="$SCRIPT_PATH:$PATH"

# TODO: Organize these as they pop up (I don't remember what's in them)
# export __GL_SHADER_DISK_CACHE_PATH="${XDG_CACHE_HOME}/shaders"	# NVidia only
# export CARGO_HOME="${XDG_CACHE_HOME}/cargo"
# export WINEPREFIX="${XDG_DATA_HOME}/wine" # May fit in .local for data, but may be better in .var for applications
