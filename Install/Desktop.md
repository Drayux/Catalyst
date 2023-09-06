# Core operation
## Install DBUS / Audio services
This is a child project of `dinit-userservd`, it provides service files for the user instance of dinit that handles the DBus -> Pipewire -> Wireplumber chain.

_**NOTE:** If the system hasn't been restarted, `sudo dinitctl start dinit-userservd` may be necessary to enable these services._

> `git clone git@github.com:Xynonners/dinit-userservd-services.git ~/Downloads/Repositories/dinit-userservd/dinit-userservd-services`  
Clone the repository  

> `cd ~/Downloads/Repositories/dinit-userservd/dinit-userservd-services`  
> `cp services/* ~/.config/dinit.d`  
> `rm ~/.config/dinit.d/pipewire-media-session.user` (Optional)  
> `sudo cp scripts/dbus-session /etc/dinit.d/user/scripts`  
> `sudo chmod +x /etc/dinit.d/user/scripts/dbus-session`  
Install the service files

> `dinitctl enable dbus.user`  
> `dinitctl enable pipewire.user`  
> `dinitctl enable pipewire-pulse.user`  
> `dinitctl enable wireplumber.user`  
Enable the user services  
_**NOTE:**_ Do **not** run these comands as root, as it will target the system dinit and not the user dinit.  

## _**TODO:**_ Instal ssdm service
_(Needs completion of my ssdm project)_

# Desktop Environment
> Environment of choice: [KDE Plasma](https://kde.org/plasma-desktop/)  
As much as I wanted to commit to Hyprland for my new install, I have opted instead of KDE. The following is a summary of my rationale.  

    I really loved the look, feel, and flow of Hyprland. I could easily imagine myself feeling at home here if development were my primary workflow. Alas, it is not. The nature of tiling windows is not nearly as friendly to my streaming / video editing use case. The floating window mode was really impressive, though it still conflicted whenever my goal was somewhat of a "hybrid" workspace. That all said, it was lightweight, highly-configurable, and came with a solid "out of the box" config. I loved that I knew every component that went into it.  

    Plasma on the other hand is very monolithic-feeling. I'm not a huge fan of the gigantic list of dependencies, and the nature of the ecosystem making it a bit unintuitive to mix and match alternative options. However, there are many more features to plasma that make it feel extra polished, such as the menu editor and the centralized system settings. If KDE had better support for "ground-up" window customization, and more tiling functionalitym it would be the easy pick. Perhaps some day I'll fork Hyprland and port it into a replacement for KWin?? Either way, it is flexible, modular, and _mostly_ stable, which is essential for me.

## Installation
> `pacman -S plasma-desktop`  
This is the package for the bare-minimum install (anything less is just using the components piecewise, which doesn't really work without drop-in replacements.)  
_**NOTE:**_ This _requires_ `xorg_xwayland` and `wayland-protocols` for wayland mode to operate properly  
_**NOTE:**_ Prefer `ttf-droid` for fonts, and `*-vlc` for media playback  

**Core applications / packages**  
- kscreen
- kgamma5
- kwayland-integration
- plasma-nm (_**TODO:**_ disable modem manager to stop log spam)
- plasma-pa
- xdg-desktop-portal / xdg-desktop-portal-kde  
- dolphin / dolphin-plugins / (ark) (consider dolphin-root alternative)
- gwenview
- kitty (alternatively alacritty)
- firewalld-dinit (`sudo dinitctl enable firewalld`)
- wget
- ~~corepacker (for node package management stuff)~~

_**TODO:** Determine how xdg-desktop-portal (and friends) are autostarted. Their services are meant for systemd and I did nothing to make them work...they just worked raw dog?? I cannot find anything that suggests it activates it, such as an active dinit service or anything. Going to assume dbus is responsible for now._  
_**NOTE:**_ ^^It appears that the answer lies within `/usr/share/dbus-*/services`  

**Desktop applications**  
- firefox (alternatively firedragon)
- discord (webcord-vencord-git, asar only in pacman-arch, use electron25)
- cider / (spotify / muffon)
- steam / gamescope / protontricks [AUR]
- obs (build from source!)
- vscodium (+libdbusmenu-glib)
- mailspring
- gimp
- inkscape
- godot
- bitwarden [pacman-arch]
- qpwgraph [pacman-arch]
- itgmania [AUR]
- prismlauncher [AUR]
- davinci-resolve [AUR]

**Miscellaneous**  
- kinfocenter
- kio-admin
- kfind
- plasma-systemmonitor
- ~~ksystemlog~~
- partitionmanager
- alsa-scarlett-gui
- flameshot* (~~alternatively grim / slurp~~ / wl-clipboard)
- rofi / eww (package eww-tray-wayland-git) / (also [stray?](https://github.com/oknozor/stray))
- plasma-firewall
- wine
- valgrind
- gdb
- strace
- trash-cli
- carla
- nerd-fonts
- pavucontrol*

## Styling
### _**TODO:**_ KDE-rounded-corners
_A continuation of shape-corners that works on 5.27!_

# _**TODO:**_ Extra stuff
### Fonts
- ~~otf-font-awesome~~
- ttf-droid
- ttf-roboto
- ttf-carlito
- ttf-font-awesome
- ttf-dejavu-nerd
- ttf-firacode-nerd
- ttf-ubuntu-nerd
- ttf-jetbrains-mono-nerd
- ttf-nerd-fonts-symbols-mono

### Desktop packages
- dbus-dinit (`dinitctl enable dbus`)
- xdg-desktop-portal-hyprland
- xdg-user-dirs
- xdg-utils
- hyprland
- hyprpaper
- dunst (notification daemon)
- rofi
- waybar
- firefox (select pipewire-jack and ttf-droid)