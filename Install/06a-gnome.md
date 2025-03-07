# Gnome desktop environment setup
> ### **OPTIONAL:** Gnome and/or Hyprland can be installed, this setup assumes both

**\[ [⇽ Previous](./05-packages.md) | [Next ⇾](./06b-hyprland.md) \]**  

> **WORK IN PROGRESS**

## Settings
Center new windows: `gsettings set org.gnome.mutter center-new-windows true`  
Super-M2 resize: `gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true`  
Increase window timeout: `gsettings set org.gnome.mutter check-alive-timeout 20000`  

Fix file manager shortcut: `gio mime inode/directory org.gnome.Nautilus.desktop`  

**Needs further customization**  
Customize xcursor theme (GTK): `gsettings set org.gnome.desktop.interface cursor-theme 'THEME_NAME'`  
~~Show desktop icons: `gsettings set org.gnome.desktop.background show-desktop-icons true` (needs testing)~~

**Misc settings in GUI**  
(dark mode, disable hot corners, workspaces on primary only, disable screen blank, sleep after an hour)  

### Environment
Gnome provides an excess of session files, so we can just use our own

> `cp .../System/Config/Desktop/gnome.desktop /usr/share/sessions/`  

_**NOTE:** Whether or not `gnome-session` uses wayland depends upon the `XDG_SESSION_TYPE` environment variable._

## Configuration _(TODO)_
- ~~**System tray!** (aka I need to be able to conveniently exit discord)~~
- ~~**System taskbar!** (one such builtin extention provides one, but it is hella ugly tbh)~~
- ~~Move gnome-shell top bar to the bottom (look into the `Just perfection` shell extension)~~
- ~~Show desktop icons~~
- ~~Libadwaita theme for GTK3 applications~~
- ~~Clipboard history~~
- ~~Preset window tiling spaces (like KDE)~~ ([Documentation](https://github.com/Leleat/Tiling-Assistant/wiki/Layouts))
- ~~Icon theme (right now I would really like something halfway between Adwaita and Colloid ; Adwaita++ synthwave folders would be sick nasty if I could find them, too)~~
- ~~Figure out how to change the names of _.desktop_ entries in the app launcher~~ ([Upon further searching](https://help.gnome.org/admin//system-admin-guide/2.32/menustructure-desktopentry.html.en), it appears that directory precedence for the same-named entry has the behavior of overriding one another)
- Starship prompt configuration (technically not gnome-specific but it's part of the rice)
- Neovim setup / crash course / whatever else (also part of the rice, less-so gnome) ... `gsettings get org.gnome.nautilus.preferences thumbnail-limit` looks really promising but appears to have no effect
- Hide file thumbnails in large directories to preserve resources (in nautilus)
- AGS shell config (technically more of a TODO for hyprland)
- Cursor customization (wait for hyprland setup since cursors are more involved for that one)
- (would love an easier way to customize application filetype associations but alas)
- Customize the selected directory for screenshots without changing the value of `xdg-pictures`

## Extensions
#### // Desktop Icons
[Desktop Icons NG (GTK3) - Rastersoft](https://extensions.gnome.org/extension/2087/desktop-icons-ng-ding/)  
[Desktop Icons NG (GTK4) - Smedius](https://extensions.gnome.org/extension/5263/gtk4-desktop-icons-ng-ding/)  

 _The latter is a newer version of the former taking advantage of Libadwaita GTK4 theming. It looks much more thematically consistent, yet it appears to have a few more visual bugs, such as unusual placement in activity overview. That said, the GTK3 one looks fantastic alongside `adw-gtk3`._  

#### // Panel Icons
[App Icons Taskbar - andrew_z](https://extensions.gnome.org/extension/4944/app-icons-taskbar/)  
[Tray Icons: Reloaded - Martin](https://extensions.gnome.org/extension/2890/tray-icons-reloaded/)  

_Add taskbar/system tray icons to the panel. Of great mention is App Icons Taskbar which accomplishes exactly what I was hoping I might find._  

#### // Tweaks
Utility extensions that provide extra "settings options"/functionality to various shell components.  
[Tiling Assistant - Leleat](https://extensions.gnome.org/extension/3733/tiling-assistant/)  
[Clipboard History - SUPERCILEX](https://extensions.gnome.org/extension/4839/clipboard-history/)  
[Just Perfection - Justperfection](https://extensions.gnome.org/extension/3843/just-perfection/)  

#### // Notable Mentions
Not currently using any of the following extensions, but they provide compelling features or seem to be viable alternatives.

[AppIndicator and KStatusNotifierItem Support - 3v1n0](https://extensions.gnome.org/extension/615/appindicator-support)  
[Transparent Top Bar (Adjustable transparency) - Gonzague](https://extensions.gnome.org/extension/3960/transparent-top-bar-adjustable-transparency/)  
[[OUTDATED] Big Avatar - Gustavo Peredo](https://extensions.gnome.org/extension/3488/big-avatar/)  

#### // Wishlist
The following are extensions I have not yet found, but am hopeful may exist someday (or otherwise could become projects of my own.)  
- `.desktop` entry editor (akin to the one provided by KDE)

### Installation
Shell extensions are relatively simple, they just need the extension folder located within `~/.local/share/gnome-shell/extensions` and named according to the UUID provided in the metdata file (after extracting the archive.)  
_The directory will not exist if no extensions have been installed._  

> `cat ~/.local/share/gnome-shell/extensions/ding@rastersoft.com/metadata.json` _(example)_
```json
{
  "_generated": "Generated by SweetTooth, do not edit",
  "description": "Adds icons to the desktop. Fork of the original Desktop Icons extension, with several enhancements.",
  "name": "Desktop Icons NG (DING)",
  "shell-version": [ "45", "46" ],
  "url": "https://gitlab.com/rastersoft/desktop-icons-ng",
  "uuid": "ding@rastersoft.com",
  "version": 68
}
```

[Installation Guide - Pragmatic Linux](https://www.pragmaticlinux.com/2021/06/manually-install-a-gnome-shell-extension-from-a-zip-file/)  

## Theme
[Libadwaita-GTK3](https://github.com/lassekongo83/adw-gtk3) is a port of the _clean-as-fuck_ GTK4 theming for GTK3 applications. It's not perfect, but it looks much nicer than stock GTK3 by removing the top bar gradient.

> `yay -S adw-gtk3`  
_Optionall append `sassc` as this is a make dependency that I also use for AGS._  

> `gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'`  
> _`gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'`_  
Set the gnome theme settings  
_`prefer-dark` should be handled by the settings panel, but it is available if necessary._

### Flatpak
_**TODO:** For flatpak applications, determine if this is a necessary additional step._  

We will also install the flatpak for it, so the theme is available within the respective application sandboxes. This flatpak is called `adw-gtk3-dark`.

> `flatpak install org.gtk.Gtk3theme.adw-gtk3-dark`  
_Optionally `org.gtk.Gtk3theme.adw-gtk3` for the light theme._  

_**NOTE:** The session may need to be restarted for the light/dark mode to be properly updated._

### Icons
> `gtk-update-icon-cache -q <ICON_DIR>`  
Generate the icon cache  
_`ICON_DIR` is the directory that contains the `index.theme` file._  

> `gsettings set org.gnome.desktop.interface icon-theme '<ICON_THEME_NAME>'`  
Set the icon theme  
_Theme name is specified in `index.theme`_.

Note that the system will look for icon themes in `/usr/share/icons/ICON_DIR` or `~/.local/share/icons/ICON_DIR`  
_An [archive](/System/Graphics/Icons/catalyst-icons.tar.xz) of my modified icon set is available._  

**index.theme configuration**  
_This is a very rough overview of the extent to which I tweaked for my custom theme._  

```conf
[Icon Theme]
Name=ICON_THEME_NAME
Comment=Fun little theme description.
Example=folder
Inherits=Adwaita,hicolor        # Can be any other theme names, usually well-known names work best
FollowsColorScheme=false        # Not 100% sure on this one, but I think it means that the DE will look for <icon>-dark variants

# Specify every icon-containing subdirectory in the icon theme directory here
Directories=scalable/apps,...,

[scalable/apps]                 # Directory name
Context=Applications            # The "type" of icons (see below)
Size=64
MinSize=16
MaxSize=512
Type=Scalable

# ...

# NOTE: Symbolic icons seem to follow the same naming pattern as their scalable variants
#       That said, they specify a different Size/MinSize so I anticipate the DE knows to swap depending on the "target" size for a given application

# NOTE: Many icon packs store app icons via a "friendly" name and then provide symlinks (in the same directory) for the official "icon name" which the application seeks
#       It would be possible to store application icons in a completely unique directory and just store the appropriately-targeted links in the directory specified by this configuration

# Possible icon "types" (that I have seen thus far):
#   - Applications
#   - MimeTypes
#   - Places
#   - (the above is extent to which I've customized)
#   - Actions
#   - Categories
#   - Devices
#   - Emblems
#   - Status
```

## Notes
### Mimetype associations
`GIO` (from `glib2`) appears to be the component necessary for associating a default application with a mimetype, said mimetype is provided by XDG.

Application type associations are stored at: `/usr/share/applications/mimeinfo.cache`

To solve the `.desktop` entries with `Terminal=true` not launching, use the xdg-terminal-exec script: https://github.com/Vladimir-csp/xdg-terminal-exec/tree/master (uses config file `~/.config/xdg-terminals.list`.) This is a result of GIO using a hard-coded list of possible terminal executables, instead of recursively looking up the default terminal application.  
> [Fedora Forum - Set Default Terminal in Gnome](https://discussion.fedoraproject.org/t/set-default-terminal-in-gnome/77341/9)

_**TODO:** There additionally exists a command to update the mimeinfo file, but I need to find it again._

### Desktop features
The following is my attempt to describe a thought I am struggling to compose into words: I really like the idea of a barebones desktop environment, but with all of the "framework" in place to support all of the niceties of a fully-involved environment. Fortunately, Gnome does a great job of satisfying that. The following features (rather classes of features perhaps) come to mind as elements that I'd like to have accounted for by the same "major subsystem" (aka the DE.)

- **Settings**
    - Wallpapers / Theming
    - Display configuration
    - Devices (Keyboard/Mouse/Touchpad) - Controller support is also nice, but only KDE has this currently
    - Networking (GUI interface)
    - Sound (GUI interface)
    - Battery (GUI interface)
- **Window Management** (duh, the following are specific features I like to have)
    - Workspaces (with keybinds to move between them)
    - Window hiding (minimization, with a way to see what is hidden / restore them)
    - Super+\<click\> move/resize
    - Non-focus-stealing windows (Gnome does really well at this!)
    - Intelligent screen usage (aka tiling or tiling-tangent features)
- **Application Launching**
    - Application menu (ideally with customizable entries, KDE does well at this!)
    - Default application specification
    - Shortcut handling
    - Mimetype parsing
- **Notifications**
    - Including control over what notifications are shown ideally
    - Provides a service for applications that demand one (such as discord)
- **Utility**
    - Removable storage handling (automounting/syncing/etc.)
    - Permissions elevation GUI
    - Common "shell" features
        - Desktop icons
        - Desktop "panel"
    - Common panel indicators
        - Taskbar / System tray
        - Clock
        - Battery indicator
        - Control panel (mini GUI for common settings/power)
        - Workspace indicator
        - Notification log
        - Media controls
        - Calendar* (Not a must for me, but gnome's is quite nice!)
        - Application menu* (also not a must, but I loved the one on KDE....when it was functional)

### Complaints
_As a simliar section, this is my attempt at a list of all of the things currently "stressing" me about Gnome. The goal of this list is just to get the thoughts out to help me better process them._

Gnome still has many abstracted components, notably these are the executables itself as they **follow somewhat of a major chain of events**. `gnome-shell` is the "primary executable" that _is_ Gnome itself. Yet, it should be ran via `gnome-session` which runs both `gnome-shell`, `dbus`, as well as `gnome-settings-daemon` to give the shell the full breadth of its functionality. Further, the window manager itself is called `mutter` which can also be ran by itself with limited functionality. However, after launching Gnome with `gnome-session`, no mutter process will be running.

Running a command such as `gnome-shell && gnome-settings-daemon` will not function as expected, which I find unintuitive to the point of being stressful, even though I should only need to worry about running `gnome-session`. Alas, I think a major source of this stress is the difficulty of trying to provide specific parameters, such as selecting a specific GPU or designating that I want to run a wayland session instead of an x11 one.

Gnome settings daemon launches any number of additional settings services, which it is very ambigious to me which is which, as well as what all is even listed. I would prefer to see this much more configurable in case I wish to remove something specifically, or add something custom, as this would make it much easier to construct a "minimal" form of Gnome, instead of "installing an arbitrary feature package and hoping it starts automatically."

For some reason, I can't help but overthink the mutter portion of the shell in particular. There are many such applications where they depend on another to already be present in order to run properly. An example of this could be something like a graphical application depending upon a display server such as Wayland or XOrg, both of which implement a protocol that it expects in order to create a window and present graphics to it. Alternatively, Pipewire provides an API for audio that sound-producing applications require.

Alas, something about the fact mutter can run by itself, and otherwise runs "completely interally" when gnome-shell is ran is causing me to drastically overthink how it works, even though it is the same concept. Gnome-shell must be looking for some sort of API provided by a nested instance of mutter in order to provide functionality. In retrospect, perhaps the extent of my stress is fully a result of having issues getting Gnome to start consistently (see Bugs.)

_I'd like to see the entire process reduced to something as simple as a bash script, even if it were convoluted with lines where some session PID were saved to a variable or whatnot. The enumeration of every unique process that is launched, as well as parameters and order in some form of logical flow should fully resolve my overwhelming feelings._

Another such complaint comes from the "users" portion of gnome settings. It allows one to be specified as an administrator, which is effectively "adding" new behavior on top of existing Linux behavior, that only serves to unnecessarily abstract things. Too many examples of these types of features are the source of a desktop environment feeling..."not minimal/overbaked" and a primary reason I sought to move away from KDE.

### Keybinds
#### Launchers

    > Home folder: <super> + `
    > Launch help browser: <disabled>

#### Navigation

    > Hide all normal window: <super> + d
    > Move window one monitor down: <disabled>
    > Move window one monitor to the left: <disabled>
    > Move window one monitor to the right: <disabled>
    > Move window one monitor up: <disabled>
    > Move window one workspace to the left: <shift> + <super> + left
    > Move window one workspace to the right: <shift> + <super> + right
    > Move window to workspace 1: <shift> + <super> + 1
    > Move window to workspace 2: <shift> + <super> + 2
    > Move window to workspace 3: <shift> + <super> + 3
    > Move window to workspace 4: <shift> + <super> + 4
    > Switch to workspace 1: <super> + 1
    > Switch to workspace 2: <super> + 2
    > Switch to workspace 3: <super> + 3
    > Switch to workspace 4: <super> + 4
    > Switch to workspace on the left: <super> + left
    > Switch to workspace on the right: <super> + right
    > Switch windows of an application: <disabled>

#### System

    > Lock screen: <disabled>
    > Log out: <shift> + <super> + l

#### Typing

    > Switch to next input source: <disabled>
    > Swithc to previous input source: <disabled>

#### Windows

    > Close window: <super> + q
    > Hide window: <super> + down
    > Lower window below other windows: <super> + pgdn
    > Maximize window: <disabled>
    > Raise window above other windows: <super> + pgup
    > Restore window: <disabled>
    > Toggle fullscreen mode: <shift> + <super> + up
    > Toggle maximization state: <super> + up
    > View split on left: <ctrl> + <super> + left
    > View split on right: <ctrl> + <super> + right

### Utility: `dconf editor`
This may prove a beneficial supplimental tool to gnome-control-panel, although all settings can be modified through the `gsettings` CLI

## Bugs
### Could not connect to Wayland server (**major issue**)
This appears to be specific to gnome-shell. Running with and without dbus-run-session seems to make no difference. Gnome-shell never fails the second time (start it with `dbus-run-session gnome-shell --wayland` ; wrapping the whole thing in `timeout 10` allows it to fail but still return to a usable VT ; launch gnome-session with `XDG_SESSION_TYPE=wayland /usr/bin/gnome-session`

Further, launch gnome shell _seems_ more likely to fail if the system was restarted from the gnome-shell, and power to the machine was kept. I'd hesitantly speculate that the error here is some sort of graphics mode on the card itself.

The logging file says something along the lines of `(EE) could not connect to wayland server`, sometimes followed by some error in the GJS, some mentioned a nonexistant bus. There are warnings about no systemd1 busses and service files, and also warnings about being unable to find a session ID, all of which also appear on a successful launch.

Gnome session appears to _always_ launch successfully after the first attempt.

Mutter has no issue launching at all, yet when gnome-shell errors, no window manager appears to be present at all.

~~_I am tempted to either wait for gnome shell version 46 (currenlty on 45.4) or to build gnome-shell from source._~~

My new theory as to the cause of this is some side-effect of not having systemd. Pending posting the full error report, a few messages on stdout after timeout kills an unsuccessful launch make mentions of looking for some sort of _display_ target, which it cannot find. This leaves me to wonder if said target exists to resolve a race condition that where some display-related process must be running before gnome-shell attempts to initialize. Attempting to launch gnome will start this process, but the required order is only occasionally met.

**I've just realized: As I do not use GDM, I've become almost certain that this issue is a result of some form of race condition. Gnome devs wouldn't notice it as launching from GDM will already have a wayland display server active.**

> **Possible Resolution**  
In my experimentation with GDM thus far, I have yet to have an unsuccessful launch (despite the fact GDM uses XOrg, amusingly.) I'd still prefer to use `ly` if could, so this solution is not optimal, but certainly much less disruptive.  

### ~~Alacritty doesn't prompt until another wayland application is open~~
~~This is a reported bug with gnome-shell. Kinda annoying, but not major. **TODO** Link the issue report!~~  

_**Resolved!**_

### Networking does not properly resume after wake from suspend
_This may not be a gnome issue! **TODO:** I need to test this from a TTY!_

Suspend appears to work perfectly, with the sole exception of the networking after wake. When on just WiFi, waking completely kills internet connection, and even the gnome shell panel shows a little question mark on the icon indiciating no connection. (I have yet to test if I can still ping the router in this state or not.)  

When connected to both ethernet and wireless, resuming from suspend kills the ethernet link, but wireless still appears to function after a considerable delay. That said, it appears to be substantially throttled in this case as well.

Either way, every wake from suspend seems to require that I run:

> `sudo rc-service NetworkManager restart`

Additionally, I noticed some weird networking behavior on Chitin as well, however I have not done much testing with this, beyond seeing that restarting NetworkManager also frequently solves the issues at hand.

In conclusion, this may not be a gnome issue, rather a NetworkManager issue, or possibly even an issue with OpenRC and sleep states, or simply the service scripts provided by the Artix compatibility package.

> **Possible Resolution**  
Disabling wifi when on a wired connection appears to allow the ethernet to function as intended.  

### Gnome control panel
- Crashes with the search indexer locations option
- Setting a keybind breaks the UI so you need to back out and select a different major option before going back to keyboard to try again

### Permissions elevation
Small "hole" for issues rather than a jarring one in of itself: Gnome doesn't have any way of handling an excess of permission elevation requests. What this means is that if an application were to bug out and continuously try to elevate permissions, you will get stuck in a loop where the only escape is killing the troublesome process in a TTY.

## Packages (entire `gnome` group summary)
_I am using a very neutered gnome. I love what the shell brings to the table, but I don't generally want the "fully-weight" desktop environment. That said, I may have neutered it so much that this is the source of some bugs in the system...it is hard to say for sure._

> New desktop will be some abuse of GNOME. Tiling is so nice, but not super well-suited to gaming or a wide-screen monitor without a lot of tweaking. I can always install hyprland later, especially with alot of common tools (such as preferring GTK and everything else.)

~~`baobab` -> Disk usage utility (prefer `df -h` CLI)~~  
~~`epiphany` -> Gnome web browser~~  
`evince` -> Document viewer (dependency of sushi)  
~~`gdm` -> Gnome display manager (prefer LY)~~  
~~`gnome-backgrounds` -> Default wallpapers (located in `/usr/share/backgrounds/`~~  
`gnome-calculator` -> Calculator app (likely prefer native version)   
~~`gnome-calendar` -> Calendar app (not useful for desktop with google calendar)~~  
`gnome-characters` -> Symbols and emoji selection/lookup (useful if I cannot find an inline way of doing this)  
~~`gnome-clocks` -> Clock app?~~  
**`gnome-color-manager` -> Display color profiles tool (Installed for the sake of the settings screen, but color is unsupported by my monitors)**  
~~`gnome-connections` -> Remote desktop client? Perhaps the inverse of `gnome-remote-desktop`~~  
~~`gnome-console` -> Gnome's terminal (prefer alacritty)~~  
~~`gnome-contacts` -> Contacts program (local so not very useful on desktop, prefer my google contacts)~~  
**`gnome-control-center` -> Settings UI (requires gnome-settings-daemon to be running to use\*)**  
^^pair this with dconf editor--consider whether to use the flatpak or native install (thinking local rn)  
~~`gnome-disk-utility` -> Disk partition manager (prefer gdisk CLI)~~  
~~`gnome-font-viewer` -> (Prefer flatpack or alternative on flatpak)~~  
`gnome-keyring` -> required dependency of xdg-desktop-portal-gnome  
~~`gnome-maps` -> Map viewer (not very useful on desktop)~~  
~~`gnome-menus` -> Application (xdg .desktop) menus relevant to gnome? (+GUI editor like in KDE)~~  
~~`gnome-music` -> Music player (prefer spotify for music, or VLC for local files)~~  
`gnome-remote-desktop` -> Remote desktop (prefer this *if* I ever want a remote desktop)  
**`gnome-session` -> Core handler for mutter WM and gnome shell...not sure what else it's responsible for but it seems various things such as the audio and networking are handled here?**  
**`gnome-settings-daemon` -> Appears to allow the various gnome apps to share configuration parameters (such as having the shell connect to an audio device??)**  
^^upon further looking, it appears that is a seperate program for many operations handled by some window managers indepently such as: keybinds, clipboard, gtk-theme, mouse speed, etc.) It is akin to a configuration file with a wrapper process to edit/read it (`nwg-look` appears to edit whatever gtk styles would be stored here directly)  
^^In retrospect, the pulseaudio dependency is probably to allow `gnome-control-panel` to select the default device or otherwise chance settings like the plasma applet supports  
**`gnome-shell` -> Desktop shell (handles window switching, app launching, and probably keybind handling....*tragically*)**  
**`gnome-shell-extensions` -> Javascript/CSS loader for gnome-shell (allows extensions to work)**  
**`gnome-software` -> Software management utility (supports flatpak so consider this highly!)**  
**`gnome-system-monitor` -> Process and resource usage viewer**  
~~`gnome-text-editor` -> (prefer terminal editor)~~  
~~`gnome-tour` -> Gnome guided tour~~  
~~`gnome-user-docs` -> Gnome documentation~~  
`gnome-user-share` -> LAN file sharing  
~~`gnome-video-effects` -> prefabbed gstreamer effects collection (not software itself)~~  
~~`gnome-weather` -> Weather app (not very useful for desktop...prefer a flatpak if desired)~~  
~~`grilo-plugins` -> Grilo is an abstraction library for media content (which is not used by anything that I plan to use)~~  
**`gvfs` -> GIO (glibc) filesystem support for nautilus (req but we want asexplicit since there are optional dependencies)  
`gvfs-afc` -> opt dep  
`gvfs-google` -> opt dep  
`gvfs-gphoto` -> opt dep  
`gvfs-mtp` -> opt dep  
`gvfs-nfs` -> opt dep  
`gvfs-smb` -> opt dep**  
~~`loupe` -> Image viewer (consider using the flatpak/alternative such as GNOME photos)~~  
~~`malcontent` -> Parental control software~~  
**`nautilus` -> File manager**  
~~`orca` -> Screen reader~~  
~~`rygel` -> Media streaming service/server (cool for server but not desktop)~~  
~~`simple-scan` -> Scanning software (to using scanner devices; prefer flatpak if desired)~~  
~~`snapshot` -> Trivial equivalent to photobooth (prefer flatpak if desired)~~  
**`sushi` -> File previewer for nautilus**  
~~`tecla` -> Keyboard viewer (required dep of control center)~~  
`totem` -> Media player (will likely opt for VLC instead)  
**`tracker3-miners` -> File indexer (opt for nautilus)**  
**`xdg-desktop-portal-gnome` -> App resource access**  
~~`xdg-user-dirs-gtk` -> XDG user dirs plus nautilus bookmark file?~~  
~~`yelp` -> GNOME help~~  
