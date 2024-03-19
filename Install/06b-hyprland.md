# Hyprland "desktop environment" setup
> ### **OPTIONAL:** Gnome and/or Hyprland can be installed, this setup assumes both

**\[ [⇽ Previous](./06a-gnome.md) | [Next ⇾](./07-software.md) \]**  

> **WORK IN PROGRESS**

## Extra packages
- [dex](https://archlinux.org/packages/extra/any/dex/) : Desktop autostart
- [ags](https://aylur.github.io/ags-docs/config/installation/) : Aylur's GTK shell

## TODO: Desktop portal configuration (`~/.config/xdg-desktop-portal/hyprland-portals.conf`)
^^Additionally I'd like to find the piece of documentation that talks about the naming format of the `*-portals.conf`

# Customization
## Function keys
How to map function keys: https://www.reddit.com/r/hyprland/s/M3GYpBwo9e  

## Cursors
For later, see this for setting the cursor on hyprland https://wiki.hyprland.org/Hypr-Ecosystem/hyprcursor/

## AGS reference
Original post: https://www.reddit.com/r/unixporn/s/RCYdTgQleY  
Dotfiles: https://github.com/Aylur/dotfiles  

# Misc notes
## Wallpapers
Hyprland default wallpapers are stored at `usr/share/hyprland/wallX.png`  
^^I will likely replace the existing wallpaper exec with simply putting what I want into the defaults (it may also be possible to do this in the .config as the hyprland config overrides a global config in the same /usr/share/hyprland/ directory...probably. It may also just be there as an example)
