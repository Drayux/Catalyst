# Placeholder for Firefox
### Package: firefox-appmenu-bin
Prefer this package (over `firefox`) if on KDE and seeking to use the global app menu. This package adds a patch to the base version which allows the application menu to be detected by DBus.  

### Wayland
Use environment variable: `MOZ_ENABLE_WAYLAND=1`  
Note that this does break the application menu provided by KDE (no entries present, as seen with other wayland applications.)  

### Custom Theme
_**TODO:**_ My dream Firefox config would feature tree-style-tabs instead of the default tabs, but have a seamless integration (i.e. remove the default tabs at the start, have the tab sidebar be persistent or mouseover to show, etc.) Many of these customizations are possible via modifying the Firefox theme(?) directly, however I have yet to dive down this rabbit hole.  

This GitHub repo ([FlyingFox](https://github.com/akshat46/FlyingFox)) showcases a custom Firefox theme that nearly perfectly matches the format and theming elements that I'd hope to obtain with my custom configuration. That said, it is built for a _very_ outdated version of Firefox (78.15 - Version as of writing this: 112.0.)  
> [Mozilla Support Page - Advanced Customization](https://support.mozilla.org/en-US/kb/contributors-guide-firefox-advanced-customization)  
> [Stack Overflow - Hide Tab Bar](https://superuser.com/questions/1268732/how-to-hide-tab-bar-tabstrip-in-firefox-57-quantum)  

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
