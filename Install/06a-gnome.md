# Gnome desktop environment setup
> ### **OPTIONAL:** Gnome and/or Hyprland can be installed, this setup assumes both

**\[ [⇽ Previous](./05-packages.md) | [Next ⇾](./06b-hyprland.md) \]**  

> **WORK IN PROGRESS**

## Package list (entire `gnome` group)
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

## Settings
Fix file manager shortcut: `gio mime inode/directory org.gnome.Nautilus.desktop`
Center new windows: `gsettings set org.gnome.mutter center-new-windows true`
Super-M2 resize: `gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true`

(needs further customization)
Customize xcursor theme (GTK): `gsettings set org.gnome.desktop.interface cursor-theme 'THEME_NAME'`

(dark mode, disable hot corners, workspaces on primary only, disable screen blank, sleep after an hour)

## UX todo
- No desktop icons
- Cannot minimize applications
- Move gnome-shell top bar to the bottom (look into the `Just perfection` shell extension)
- Cursor customization (wait for hyprland setup since cursors are more involved for that one)
- AGS shell config (technically more of a TODO for hyprland)
- Libadwaita theme for GTK3 applications
- Clipboard history
- Preset window tiling spaces (like KDE)
- (would love an easier way to customize application filetype associations but alas)

## Notes
### GIO
Gio (from `glib2`) appears to be the component necessary for associating a default application with a mimetype, said mimetype is provided by XDG.

Application type associations are stored at: `/usr/share/applications/mimeinfo.cache`

To solve the `.desktop` entries with `Terminal=true` not launching, use the xdg-terminal-exec script: https://github.com/Vladimir-csp/xdg-terminal-exec/tree/master (uses config file `~/.config/xdg-terminals.list`.) This is a result of GIO using a hard-coded list of possible terminal executables, instead of recursively looking up the default terminal application.

### dconf editor
This may prove a beneficial supplimental tool to gnome-control-panel, although all settings can be modified through the `gsettings` CLI

### Keybind settings
#### Launchers

    > Home folder: <super> + `
    > Launch help browser: <disabled>

#### Navigation

    > Hide all normal window: <super> + d
    > Move window one monitor to the left: <disabled>
    > Move window one monitor to the right: <disabled>
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
    > Hide window: <super> + pgdn
    > Maximize window: <super> + pgup
    > Toggle fullscreen mode: <super> + F11
    > View split on left: <disabled>
    > View split on right: <disabled>

## Bugs
### Could not connect to Wayland server (**major issue**)
This appears to be specific to gnome-shell. Running with and without dbus-run-session seems to make no difference. Gnome-shell never fails the second time (start it with `dbus-run-session gnome-shell --wayland` ; wrapping the whole thing in `timeout 10` allows it to fail but still return to a usable VT ; launch gnome-session with `XDG_SESSION_TYPE=wayland /usr/bin/gnome-session`

Further, launch gnome shell _seems_ more likely to fail if the system was restarted from the gnome-shell, and power to the machine was kept. I'd hesitantly speculate that the error here is some sort of graphics mode on the card itself.

The logging file says something along the lines of `(EE) could not connect to wayland server`, sometimes followed by some error in the GJS, some mentioned a nonexistant bus. There are warnings about no systemd1 busses and service files, and also warnings about being unable to find a session ID, all of which also appear on a successful launch.

Gnome session appears to _always_ launch successfully after the first attempt.

Mutter has no issue launching at all, yet upon error, no window manager appears to be present at all. I fear what is happening is some sort of race condition, though mutter would also be closed on the second time attempt that everything is launched, and still has no issue.

_I am tempted to either wait for gnome shell version 46 (currenlty on 45.4) or to build gnome-shell from source._

### Alacritty doesn't prompt until another wayland application is open
This is a reported bug with gnome-shell. Kinda annoying, but not major. **TODO** Link the issue report!

### Gnome control panel
- Crashes with the search indexer locations option
- Setting a keybind breaks the UI so you need to back out and select a different major option before going back to keyboard to try again
