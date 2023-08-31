# Core operation
### Install DBUS / Audio services
This is a child project of `dinit-userservd`, it provides service files for the user instance of dinit that handles the DBus -> Pipewire -> Wireplumber chain.

_**NOTE:** If the system hasn't been restarted, `sudo dinitctl start dinit-userservd` may be necessary to enable these services._

> `git clone git@github.com:Xynonners/dinit-userservd-services.git ~/Downloads/Repositories/dinit-userservd/dinit-userservd-services`  
Clone the repository  

> `cd ~/Downloads/Repositories/dinit-userservd/dinit-userservd-services`  
> `cp services/* ~/.config/dinit.d`  
> `rm ~/.config/dinit.d/pipewire-media-session.user` (Optional)  
> `sudo cp -r scripts /etc/dinit.d/user`  
> `sudo chmod +x /etd/dinit.d/user/scripts/dbus-session`  
Install the service files

> `dinitctl enable dbus.user`  
> `dinitctl enable pipewire.user`  
> `dinitctl enable pipewire-pulse.user`  
> `dinitctl enable wireplumber.user`  
Enable the user services  
_**NOTE:**_ Do **not** run these comands as root, as it will target the system dinit and not the user dinit.  

### _**TODO:**_ Instal ssdm service
_(Needs completion of my ssdm project)_

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