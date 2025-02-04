# ZDOTDIR set via pam: /etc/security/pam_env.conf
# > ZDOTDIR	DEFAULT=@{HOME}/.config/zsh
source $ZDOTDIR/environment
source $ZDOTDIR/aliases
source $ZDOTDIR/options

# >>> System-specific configuration <<<
source ${XDG_DATA_HOME}/.overrides 2> /dev/null || true

# >>> Startup MOTD <<<
fastfetch 2> /dev/null || true

eval "$(starship init zsh)"
