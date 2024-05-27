# Flatpak applications
> ### Keeping end-user applications containerized fixes the majority of my library dependency issues

**\[ [⇽ Previous](./06b-hyprland.md) \]**  

> **WORK IN PROGRESS**

# Additional software (unsorted...needs desktop environment)
## Utility programs (therefore not flatpaks)
- `alacritty`
- `alsa-scarlett-gui`
- `carla`
- `helvum`
- `kitty`
- `nautilus`
- `pince`

# Flatpaks
- Blender
- Firefox
- Flatseal
- Font Manager (_**TODO:**_ Discontinued, needs replacement)
- GIMP
- Inkscape
- Spotify
- Discord (Vesktop)
- VLC
- VSCodium
- ...
- (bitwarden)

## Dedicated documentation
- Steam (games.md)
- Lutris (games.md)
- Prism Launcher (games.md)
- OBS Studio (content.md)
- Davinci Resolve (content.md)

## Miscellaneous Add-ons
- `steam-devices-git`<sup>AUR</sup>
- AdwSteamGtk (a bit buggy but looks really nice)
- OBS VkCapture (https://github.com/nowrep/obs-vkcapture)

# Application info and configuration
## Browser
_Archived content (still needs updating.)_

### Wayland
Use environment variable: `MOZ_ENABLE_WAYLAND=1`  
_This is handled by the default configuration provided by the Flatpak_  

Note that this does break the application menu provided by KDE (no entries present, consistent with other wayland applications.)  

### Custom Theme
_**TODO:**_ My dream Firefox config would feature tree-style-tabs instead of the default tabs, but have a seamless integration (i.e. remove the default tabs at the start, have the tab sidebar be persistent or mouseover to show, etc.) Many of these customizations are possible via modifying the Firefox theme(?) directly, however I have yet to dive down this rabbit hole.  

This GitHub repo ([FlyingFox](https://github.com/akshat46/FlyingFox)) showcases a custom Firefox theme that nearly perfectly matches the format and theming elements that I'd hope to obtain with my custom configuration. That said, it is built for a _very_ outdated version of Firefox (78.15 ; 112.0 is the current version as of writing this.)  
> [Mozilla Support Page - Advanced Customization](https://support.mozilla.org/en-US/kb/contributors-guide-firefox-advanced-customization)  
> [Stack Overflow - Hide Tab Bar](https://superuser.com/questions/1268732/how-to-hide-tab-bar-tabstrip-in-firefox-57-quantum)  

Alternatively, the following is a similar type of Firefox configuration that also looks promising.

> [PenguinFox - Github](https://github.com/p3nguin-kun/penguinFox)  
> [userChrome.css - Pastebin](https://pastebin.com/PDL0h2KR)  

### Change Location of Profile Folder
Launch the profile manager by running `firefox --ProfileManager`  
When creating a new profile, select the "Choose Folder" button to specify a path to Firefox where the profile should be located.  

Unfortuantely, it should be noted that this does not prevent Firefox from saving the rest of its data in `~/.mozilla`  

### Access Advanced Settings
Inside the URL bar, the `about:` prefix specifies to Firefox to use a local command. Notably `about:about` presents a "help page" that lists all of the `about:` page entries.  

#### `about:about`
Presents a list of `about:` page entries  

#### `about:config`
Advanced Firefox configuration - Some settings here can break your profile  

#### `about:networking`
Displays active connections within Firefox - Can be used to identify sussy connections, also includes a DNS lookup  

#### `about:performance`
Displays useful performance diagnostics, somewhat like a "task manager" specific to browser tabs  
