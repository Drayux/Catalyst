# ZDOTDIR set via pam: /etc/security/pam_env.conf
# > ZDOTDIR	DEFAULT=@{HOME}/.config/zsh
source $ZDOTDIR/environment.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/options.zsh

# >>> Startup MOTD <<<
fastfetch 2> /dev/null || true

eval "$(starship init zsh)"
