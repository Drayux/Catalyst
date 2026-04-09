# TODO: See https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout for a pending config refactor
# > The second answer has many descriptions that I wish to summarize into topfile comments

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
