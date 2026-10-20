# Greeter config
Target directory: `/etc/greetd/`

This configuration is notably more involved than most system configs. To substitute for systemd and its relatives on my systems, I've deferred the work to the greeter and PAM.

This configuration depends on other configs to fully function:
- `doas` -- Allows the greetd user (who owns the greetd process) to execute the `enable_displays.sh` script
- `openrc` -- The `displaymanager` target depends on this configuration to indicate that greetd should be used
- `pam` -- (Indirect) sets up the user's runtime dir, without it, the window manager will fail to launch

### `config.toml`

Specify that we should use the tuigreet as the greeter.  

_(Which is my personal favorite -- I hate the weird graphical session handoff between a graphical display manager and the window manager, and then having a lock screen that doesn't even match. I'd much rather make it a very clear transition of run modes by moving from TTY to GUI. Also! It's a nice peace of mind to not "boot into more than a bargained for" allowing better system troubleshooting if, say, my graphics driver wasn't initiating properly.)_

### `scripts/`

Main script is `wrap_session.sh` -- primary role of this script is to set the remaining XDG environment before jumping to the session. Everything under that session will subsequently inherit these variables.

This script also calls `enable_displays.sh` -- this is a secondary script which exists really just to make tuigreet "pretty." As my monitors are different sizes, the TUI looks _unfortunate_ unless I override the video mode at boot. This script turns the secondary display back on so that the graphical session can use them. It's delegated to a separate script to make its ommission trivial on other systems.

### `sessions.d/`

Self-explanatory: Possible entries for the greeter to launch.
