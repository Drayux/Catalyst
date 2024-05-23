# System environment
> ### User accounts and core functionality

**\[ [⇽ Previous](./03-hardware.md) | [Next ⇾](./05-packages.md) \]**  

_**The system should be restarted for this phase:** The installation medium will be needed only for recovery._

#### **Repo clone dir indicated as `.../` (`/usr/src/catalyst/` if continuing from [02-config.md](./02-config.md)/[03-hardware.md](./03-hardware.md))**

## Networking
_This applies only to wireless networking. Wired connections will be enabled by default._  

> `sudo rc-service NetworkManager start`  
Starts the networking service if it is not already running  
_Generally this can be skipped. If the service is enabled before rebooting, then it will be running already._  

> `nmcli d wifi list`  
Scan and display available wireless networks  
_Optional if the target network SSID is already known._  

> `nmcli d wifi connect --ask $SSID`  
Connect to network `$SSID` and prompt for the password  
_`--ask` can be omitted if the psk is already known by network manager._  

### Utility
> `nmcli d` / `nmcli device`  
Shows the networking devices available to network manager  

> `nmcli d wifi show`  
Displays the current connection information (SSID, PSK, etc.) along with a QR code for convenience  

## Users
> `groupadd dragon`  
Create the group `dragon`  

> `useradd -d /home -s /bin/zsh -g dragon drayux`  

    > -d /home    : Set user's home directory as /home (should be done only on single-user systems)
    > -s /bin/zsh : Use ZSH as the default shell for this user
    > -g dragon   : Set dragon as the user's primary group
    > ...drayux   : The target user account name is drayux
_Successful account creation can be verified with `cat /etc/passwd`._  

> `chown drayux:dragon /home`  
Give drayux full ownership of `/home`  
_It is root by default, so the user will be unable to modify their home directory if this step is forgotten._  

> `passwd -d drayux`  
Set password as \<no password\> for user drayux  

### Dotfiles
Every entry in the repo's [config](/Config) directory observes the expected configuration filetree, so the entire directory can be copied directly.  

> `chown -R drayux:dragon .../Dotfiles`  
> `cp -r .../Dotfiles /home/.config`  
_This command will need to be tweaked if `.config` already exists: `cp -r .../Dotfiles/* /home/.config`._  

### Audio
Pipewire + wireplumber services are user-level, meaning that they should initialize and terminate with the user's session. This can be configured in a number of ways (such as systemd user services, hyprland `exec-once`, user environment config, etc.) For the most convenient interoperability between Gnome and Hyprland, we place a `.desktop` entry into the autostart directory: `~/.config/autostart/`.  

~~The Artix Linux packaging of `pipewire` provides the additional utility `/usr/bin/artix-pipewire-launcher` as well as a `.desktop` entry for this.~~  
_It appears that this was since removed from the pipewire packaging. The [script](/System/Scripts/audio-exec) and [desktop entry](/Dotfiles/autostart/audio.desktop) are both available (since modified.)_

~~> `ln -s /usr/share/applications/pipewire.desktop /home/.config/autostart`~~  
~~_The logging location is set via the config file: [artix-pipewire-launcher.conf](/Dotfiles/artix-pipewire-launcher.conf)._~~  

> `cp .../System/Scripts/audio-exec /usr/bin/`  
Add the launcher script to the system executables  
_The desktop entry now exists **only** in the dotfiles._

_**TODO:** The microphone may depend on Carla and LSP plugins to function here, as the Pipewire config will feature a Carla rack after my revisions._  

### Terminal
The XDG `.desktop` spec allows shortcuts for traditional programs, as well as terminal-mode programs (such as micro.) [`xdg-terminal-exec`](https://github.com/Vladimir-csp/xdg-terminal-exec/tree/master) is a wrapper script that allows the user to specify a default terminal emulator in a graphical user environment (specifically as it pertains to `glib2`). 

> `git clone https://github.com/Vladimir-csp/xdg-terminal-exec.git /home/Downloads/Repositories`  
> `cp /home/Downloads/Repositories/xdg-terminal-exec/xdg-terminal-exec /usr/bin/`  
_The terminals specified in the config will be installed from the package list in [05-packages.md](./05-packages.md)._

### Starship
Starship is my ZSH "theme" of course, supporting nearly endless configuration options.  
[Startship: Cross-shell prompt](https://starship.rs/)  

> `curl -sS https://starship.rs/install.sh | sh`
Install starship shell prompt binaries via curl  
_The prompt initalization script is already present in the [.zshrc](/Dotfiles/zsh/.zshrc) file._  

_**TODO:** I may want to modify this to use the starship package (`extra/starship`) instead. This entire section can likely be removed in that case._

### SSH
An SSH identity should be generated for authentication with various services (notably git!)

_The default SSH config doesn't respect my home folder, so we need to tweak the config: `/etc/ssh/ssh_config`. Alternatively the file can be copied from [ssh_config](/System/Config/Misc/ssh_config)._  

> `micro /etc/ssh/ssh_config`  

    > +/- | Host *
    > +/- | 	IdentityFile ~/.config/ssh/id_rsa
    > +/- | 	IdentityFile ~/.config/ssh/id_dsa
    > +/- | 	IdentityFile ~/.config/ssh/id_ecdsa
    > +/- | 	IdentityFile ~/.config/ssh/id_ed25519
    > +/- | 	UserKnownHostsFile ~/.config/ssh/hosts.d/%k

> `mkdir /home/.config/ssh/hosts.d`  
SSH will be unable to save the known hosts if the directory does not exist  

> `su drayux`  
> `ssh-keygen`
Generate a new ed25519 key pair

	> Generating public/private ed25519 key pair.
	> Enter file in which to save the key (/home/.ssh/id_ed25519): /home/.config/ssh/id_ed25519
	> ...
_Be sure to update [Github](https://github.com/settings/keys) with this new SSH key (`/home/.config/ssh/id_ed25519.pub`.)_  

### Utility
> `chsh -l`  
List all shells available to the system  
_Shell executables not in the $PATH will be omitted._  

> `ssh -T git@github.com`  
Test the SSH configuration with Github  
_This will test both the key on Github, as well as the known hosts store._  

### Additional notes
I'm split between a two differing organization options. I consider Catalyst to be a project, so it should be placed into my projects directory, except that if I want to symlink my dotfiles, I want a location that feels intentionally more "static" like `/usr/src/catalyst`. This leaves me with the options:  
- Move the repo to `/home/Projects/` now that my user directory exists (probably easier to clone again since we need to change ownership, as well as the remotes to their SSH counterparts)
- Keep the repo in `/usr/src/`, change ownership and remotes, and then symlink select dotfiles (with `ln -s <path/to/target> <link>`)

The source code for the explicit list of terminal executables can be found [here](https://gitlab.gnome.org/GNOME/glib/-/blob/main/gio/gdesktopappinfo.c#L2694).  

## AUR Helper ([`yay`](https://github.com/Jguer/yay))
_All yay operations should be ran at user level._

> `git clone https://aur.archlinux.org/yay.git /home/Downloads/Packages/yay`  
> `cd /home/Downloads/Packages/yay && makepkg -si`  
_I like to keep all of my software in the form of packages saved in `~/Downloads/Packages/` (that isn't handled explicitly by pacman or yay.)_  

### Configuration
> `yay -Y --gendb`  
Generate the package database (for first use only)  

> `yay -Y --devel --editmenu --diffmenu=false --save`  
> `yay -Y --config /etc/pacman.d/yay.conf --save`  

_Pacman's split configuration is already set up, we want to configure yay to use the alternate config mode._

> `yay -Syy`  
Refresh the database with the new repositories  

> `micro /etc/makepkg.conf`  

	> +/- | MAKEFLAGS="j12"
	> +/- | OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge !debug lto)
Edit makepkg config: Use multiple threads when building packages from source and disable the extraneous debug build  
_These options are found on lines 51 and 96 of `/etc/makepkg.conf` respectively. I like to set the number of jobs to half that of the number of threads available to my system (`nproc` / 2)_  

## Display Manager ([`ly`](https://github.com/fairyglade/ly))
A minimal console greeter that looks pretty and features _most_ of the configuration options I want.  

> `git clone --recursive https://github.com/fairyglade/ly.git`  
_LY has a couple submodule dependencies._  

> `make installopenrc`  
Installs LY with service scripts for OpenRC  

> `cp .../System/Config/Misc/ly-config.ini /etc/ly/config.ini`  
Use the config file in this repo

> `mkdir /usr/share/sessions`  
> `chown drayux:dragon /usr/share/sessions`  
Create a directory exclusively for LY (wayland) sessions  
_This is the directory specified in the config; It exists to minimize the list shown by LY, as Gnome provides a ton of extraneous `.desktop` entries._  

> `rc-update add ly`  
Enable the LY display manager service  
_We select TTY7 in the config as OpenRC defaults to spawning gettys on 1-6 and we won't use Xorg._  

## Bootloader
_**TODO:** Extra fancy grub config with the awesome monika background...Currently pending me finalizing my grub config alltogether._  

## Fonts
_This is an overview of the selected font packages, they are included in the package list to be installed in [05-packages.md](./05-packages.md)._

### System
`ttf-noto-nerd` ➤➤ [Noto Sans (Google)](https://fonts.google.com/noto/specimen/Noto+Sans)  
`ttf-ubuntu-nerd` ➤➤ [Ubuntu (Google)](https://fonts.google.com/specimen/Ubuntu)  
`ttf-opensans` ➤➤ [Open Sans (Google)](https://fonts.google.com/specimen/Open+Sans)  

---

`noto-fonts-emoji` ➤➤ Noto Sans emoji set  
`noto-fonts-cjk` ➤➤ Chinese, Japanese, and Korean character set for Noto Sans  

_**TODO:** Some starndard(?) symbols are still missing...I need to figure out what they are and what packages would provide them._

### Monospace
`ttf-hack-nerd` ➤➤ [Hack (Source Foundry)](https://sourcefoundry.org/hack/)  
`ttf-jetbrains-mono-nerd` ➤➤ [Jetbrains Mono (Jetbrains)](https://www.jetbrains.com/lp/mono/)  

### Symbols
~~`awesome-terminal-fonts` ➤➤ Additional symbols; Provides a subset of the symbols that nerd fonts does~~  
`ttf-nerd-fonts-symbols-mono` ➤➤ Collection of symbols for [nerd fonts](https://www.nerdfonts.com/)  

### Console
~~`powerline-console-fonts` ➤➤ [Terminus](https://terminus-font.sourceforge.net/) console font patched with powerline symbols~~  

### Additional notes
Fontconfig is a powerful tool that lets multiple fonts be effectly combined together. It generally comes as a dependency with any GUI-related software, and will fallback to other fonts if the current glyph is absent in the selected font. Subsequently, this makes it harder to customize which icons to use, so my ambition is to minimize the number of duplicates found in these "extra" font packages.  
_**TODO:** I need to learn how to configure fontconfig as this may actually be easier than I'd thought._

> `fc-cache -f -v`  
Rebuild the fontconfig cache  
