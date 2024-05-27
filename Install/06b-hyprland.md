# Hyprland "desktop environment" setup
> ### **OPTIONAL:** Gnome and/or Hyprland can be installed, this setup assumes both

**\[ [⇽ Previous](./06a-gnome.md) | [Next ⇾](./07-software.md) \]**  

> **WORK IN PROGRESS**

## Extra packages
- [dex](https://archlinux.org/packages/extra/any/dex/) : Desktop autostart
- [ags](https://aylur.github.io/ags-docs/config/installation/) : Aylur's GTK shell

## TODO: Desktop portal configuration (`~/.config/xdg-desktop-portal/hyprland-portals.conf`)
^^Additionally I'd like to find the piece of documentation that talks about the naming format of the `*-portals.conf`  

https://community.spotify.com/t5/Desktop-Linux/Can-not-login-on-flatpak-wayland/td-p/5572675  
See the config in ~/.config/xdg-desktop-portal/... (yes the config file name matters: $XDG_CURRENT_DESKTOP)  
_(I need to pull this from Chitin)_  

## Environment
Supposedly hyprland can be ran with Vulkan by setting `env = WLR_RENDERER, vulkan`  
_This may be worth consideration!_  

The session file should be modified by changing the executable to `dbus-run-session Hyprland` and then copied to our custom `/usr/share/sessions/` directory  
_Discord depends on this to function properly. (I should also pull this from Chitin)_  

### Variable refresh rate
Variable refresh rate sounds like a compelling feature, if it is well-supported enough

https://wiki.archlinux.org/title/Variable_refresh_rate#Hyprland  
**NOTE:** ~~Setting the monitor to adaptive sync mode had some really weird behavior in wizard101. I am unsure if this was a result of gnome not being set to variable refresh rate mode (even though the game was in full screen) or if it is a DXVK bug?~~ This appears to just be a bug with Wizard101 itself.

# Customization
## Function keys
How to map function keys: https://www.reddit.com/r/hyprland/s/M3GYpBwo9e  

## Cursors
For later, see this for setting the cursor on hyprland:  
https://wiki.hyprland.org/Hypr-Ecosystem/hyprcursor/  

## AGS reference
Original post: https://www.reddit.com/r/unixporn/s/RCYdTgQleY  
Dotfiles: https://github.com/Aylur/dotfiles  
EWW Inspiration: https://github.com/Tail-R/xmonad_eww_dotfiles  

## Dropdown terminal
Functionality I would love to see is a terminal emulator that is launched at login in a hidden state. Pressing some keybind would present this emulator in fullscreen with translucence overtop the existing desktop. I could then enter a quick command or see the contents of some catted file before hiding the emulator with the same keybind. 

The following looks to be the closest I can currently get to this in Hyprland, without a dedicated program:  
https://github.com/hyprwm/Hyprland/issues/1510  

## Behavior
I anticipate that this would require that I write my own Hyprland plugin.

> If I spawn just one window like a terminal...even if it's tiling, I don't really want it to take up the entire screen. I only want it to tile if I have other windows open. So adding rules like that would be awesome  
Similarly, I'd love if I could add a minimum size to windows, such that if I tile a bunch vertically or something, instead of shrinking to being unusably small, I could do like super+scroll and then scroll the entire tiling "block" so to say  

# Misc notes
## Wallpapers
Hyprland default wallpapers are stored at `usr/share/hyprland/wallX.png`  
^^I will likely replace the existing wallpaper exec with simply putting what I want into the defaults (it may also be possible to do this in the .config as the hyprland config overrides a global config in the same /usr/share/hyprland/ directory...probably. It may also just be there as an example)

## Binds
By default, binds will be "capturing," meaning that if Hyprland receives them, then the keystrokes will not be forwarded to any subsequent windows. Using `bindn` instead of `bind` in the Hyprland configuration will allow the keys to be passed globally.
