_These are notes regarding my desktop environment and configuration, notably all KDE-relevant things._ 

# KDE Plasma Pros / Cons
### Pros
- Unified *system* settings (displays, mouse, keyboard shortcuts, appearance\*, power settings, sddm customization, etc) all in the same place
	- Great solution for managing default applications and mime types
	- Great solution for managing keyboard shortcuts
	- Many window manager options (super+click to move/resize, send below, transparency rules)
	- Offers integrations with additional programs like latte dock
- Unified application launcher
	- Offers an elegant solution for editing .desktop entries
- Unified system integration
	- Provides GUIs for drive partitioning, system monitoring, display configruation, etc.
	- Particular interest: network configuration GUI
	- Particular interest: USB drive mounting GUI
	- Drag and drop desktop
	- Clipboard history
	- File search (with indexer)
- Global app menu support
- Cool built-in compositor (with effects)  
- Aesthetically pleasing without too much hastle  

### Cons
- Primary support is for X11 - Wayland exists but it's scuffed and under-developed (See the screenshots in `Config/Plasma/Bugs/`)
- Virtual displays with XRandr not supported
- Compositor occasionally has graphical bugs
- Weird behavior that is hard to diagnose
	- Random lag spikes
	- Crashing with electron apps
	- Panels and edit mode being unwieldy
	- Firefox has a giga invisible border
	- Drag and drop desktop has invisible icons, crashes some applications, or is otherwise unintuitive
- Customization feels limited
	- The tools provided only go so far
	- Themes can be downloaded but they have very limited customization
	- Creating your own themes is a _gigantic_ rabbit hole
	- Panels are relatively limited and "fixed" (can't be removed/replaced easily - problematic because this is the core means of desktop customization)
- Themes/KDE Store entries are difficult to manage and install and the entire ecosystem feels relatively scuffed--Would much prefer to see this extended to the package manager (perhaps as its own repository)

### Neutral
- Comprehensive KDE ecosystem
	- **PRO:** Many things have relatively seamless integrations and the desktop environment feels polished and fully-featured
	- **PRO:** Such a large project also has a very large development team keeping everything as cutting-edge as possible
	- **CON:** This also makes the system feel quite "locked down" as it is unnatural to replace some elements (like using rofi feels out of place, for example.) - Similarly, this can make it less compatible with some alternative systems
	- **CON:** Almost every KDE application has many inter-dependencies and the entire desktop environment feels quite bulky, relying on multiple hundred packages even for a "minimal" installation - Most apps cannot be installed "standalone"

# Plasma Desktop Packages
### **Core package:** `plasma-desktop`
Package lists are sorted by their pacman groups, with my best attempt at removing duplicates in subsequent categories.  

## plasma
**bold:** Package of interest (for immediate install or future consideration)  
_underline:_ Package will be installed alongside `plasma-desktop` (as a dependency)  

- **bluedevil** : KDE bluetooth integrations
- _breeze_ : Theme
- breeze-gtk : Theme
- breeze-plymoth : Theme
- discover : KDE app store (might make plugin installation less scuffed)
- drkonqi : Crash handler
- flatpak-kcm : Systemsettings support for flatpak
- _kactivitymanagerd_ : Something about user activities
- _kde-cli-tools_ : Various cli tools
- kde-gtk-config : Probably allows customization of gtk app style
- _kdecoration_ : Handles window decorations (I think)
- kdeplasma-addons : Miscellaneous collection of addons
- **kgamma5** : Presumably akin to kscreen but for gamma options
- **khotkeys** : Something about KDE hotkeys?? (appears obsolete)
- **kinfocenter** : Provides system(?) information
- _kmenuedit_ : Useful .desktop file editing tool
- _kpipewire_ : Pipewire intergration
- **kscreen** : Display configuration
- _kscreenlocker_ : Lock screen
- ksshaskpass : SSH integration
- _ksystemstats_ : System monitoring (application?)
- kwallet-pam : Pam integration for _kwallet_
- **kwayland-integration** : Wayland for KDE frameworks?
- kwin : KDE window manager ; Does not include a shell (aka not standalone)
- kwrited : Daemon that listens for wall and write messages...probably for multi user
- _layer-shell-qt_ : Wayland stuff
- _libkscreen_ : KDE library
- _libksysguard_ : KDE library
- _milou_ : Handles shell search
- oxygen : Theme (ugly)
- _oxygen-sounds_ : Theme
- plasma-browser-integration : Probably install things from KDE store site directly?
- _plasma-desktop_ : 
- plasma-disks : Monitoring smart devices for failure?
- **plasma-firewall** : System firewall control panel
- _plasma-integration_ : QT theming control
- **plasma-nm** : Network manager applet (the system tray thing?)
- **plasma-pa** : Pavucontrol-like applet (I think)
- plasma-sdk : Development tools
- **plasma-systemmonitor** : KDE's task manager (I think)
- plasma-thunderbolt : Thunderbolt support
- plasma-vault : Encrypted vaults (probably unnecessary with bitwarden)
- plasma-welcome : Tutorial mode??
- _plasma-workspace_ : I think this provides the shell
- plasma-workspace-wallpapers : Wallpapers for the workspace
- plymouth-kcm : Systemsettings support for Plymouth (graphical boot screen)
- _polkit-kde-agent_ : Appears to allow for a GUI for privlege elevation
- _powerdevil_ : Power state management (like going to sleep etc)
- sddm-kcm : Systemsettings support for SDDm
- _systemsettings_ : GUI configuration tool that also includes hardware and workspaces
- **xdg-desktop-portal-kde** : Desktop portal with QT extensions

## kde-system
**bold:** Package of interest (generally for immediate install)  
*underline:* Package worth consideration at a later date  

- **dolphin** : File manager
- *kcron* : Task scheduler
- kde-inotify-survey : Something about inotify quotas
- khelpcenter : KDE app documentation GUI
- **kio-admin** : This might allow dolphin to not be a pain in the ass? (administrator file management)
- ksystemlog : System log viewer (seems to look for systemd which makes it obsolete for me)
- **partitionmanager** : GUI partition management

## kde-applications (excluding duplicates)
**bold:** Package of interest (generally for immediate install)  
*underline:* Package worth consideration at a later date  

- akonadi-calendar-tools : Akonadi (contact / calendar suite) - calendar
- akonadi-import-wizard : akonadi ...
- akonadiconsole : akonadi ...
- akregator : Adkonadi - (news?) feed reader
- alligator : Kirigami (mobile crossplatform engine) - RSS
- angelfish : Plasma mobile web browser
- arianna : Mobile device...epub reader?
- **ark** : Archive utility
- artikulate : Speech practice application
- audiocd-kio : Utility for CDs with audio
- audiotube : Youtube music client
- blinken : Game (memory?)
- bomber : Game (bomberman)
- bovo : Game (gomoku?)
- cantor : Math software front end
- cervistia : CVS frontend?
- colord-kde : Screen(?) color management daemon (session version)
- dragon : Multimedia player
- elisa : Music player
- falkon : Web browser
- ffmpegthumbs : Thumbnail creator (**TODO:** does this mean for the desktop or like making youtube videos?)
- *filelight* : Disk usage information (includes dolphin integration)
- granatier : Game (bomberman)
- grantlee-editor : Theme editor?
- **gwenview** : Image viewer
- itinerary : Travel management application
- juk : Music collection manager (mostly a music player)
- k3b : CD burning application
- kaddressbook : Contact manager
- kajongg : Game (mahjongg)
- kalarm : Alarm scheduler (probably for KDE mobile?)
- *kalgebra* : Graphing calculator application
- *kalk* : Generic calculator application
- kalzium : Periodic table application
- kamera : KDE photobooth
- kamoso : Webcam recorder
- kanagram : Game (letter order)
- kapman : Game (pacman)
- kapptemplate : KDE template generator (context??)
- kasts : Kirigami - podcast player
- kate : Text editor
- *kde-dev-utils* : KDE/Qt development utilities
- kdebugsettings : qCDebug(?) utility
- *kdeconnect* : Smartphone integration
- kdegraphics-thumbnailers : Adds thumbnails to gwenview and dolphin (postscript and raw file types)
- kdenetwork-filesharing : Directory network sharing (menu button)
- *kdenlive* : Video editor
- kdepim-addons : Addons for the "generic calendar productivity suite"
- kdesdk-kio : KDE SDK kio things
- kdesdk-thumbnailers : KDE SDK thumbnail things
- kdevelop : IDE for KDE development (C++, PHP, Python)
- kdevelop-php : PHP plugin for kdevelop
- kdevelop-python : Python plugin for kdevelop
- kdf : Another disk usage utility (KDiskFree)
- kdialog : KDE's zenity (shell script dialogue GUIs)
- kdiamond : Game (puzzle)
- keditbookmarks : Bookmark (context?) organizer and editor
- keysmith : OTP client (probably obsolete with bitwarden though)
- **kfind** : File search utility
- kfourinline : Game (connect 4)
- kgeography : Game (geography practice)
- kget : Download manager (context?)
- kgoldrunner : Game (action and puzzles)
- kgpg : GPG key GUI frontend
- khangman : Game (hangman)
- kig : Interactive geometry? education?
- kigo : Game (go)
- killbots : Game (evade killer robots)
- kimagemapeditor : Editor for HTML image maps (I had no idea this existed)
- kio-gdrive : KIO protocol for google drive
- kio-zeroconf : DNS-SD services monitor
- kirigami-gallery : Mobile app image viewer
- kiriki : Game (dice)
- *kiten* : Japanese reference application
- kjumpingcube : Game (tactical?)
- kleopatra : Crypto shit
- klettres : _Learn the alphabet_
- klickety : Game (clickomania)
- klines : Game ("highly additive")
- kmag : Screen magnifier
- kmahjongg : Game (Mahjongg...again)
- kmail : Mail client
- kmail-account-wizard : Account management for kmail
- kmines : Game (minesweeper)
- kmix : Volume control program (pavucontrol or plasma-pa may make this obsolete)
- kmousetool : Accessability mouse clicker
- kmouth : Speech synthesizer (frontend)
- kmplot : Another graphing calculator application
- knavalbattle : Game (battleship)
- knetwalk : Game (puzzle?)
- knights : Game (chess)
- knotes : Popup notes
- koko : Image gallery
- kolf : Game (minigolf)
- kollision : Game (lightweight bullet hell?)
- kolourpaint : Paint program
- kompare : GUI diff tool
- kongress : Conference (IRL?) utility application
- konqueror : File manager and web browser 
- konquest : Game (Gnu-lactic)
- konsole : Terminal emulator
- kontact : Contact manager
- kontrast : Accessibility development tool
- konversation : IRC chat client
- kopete : Another chat client
- korganizer : Calendar (another pim tool)
- kpat : Game (solitare)
- krdc : Remote desktop controller
- krecorder : Audio recorder
- kreversi : Game (stratety)
- krfb : Desktop sharing (remote desktop type?)
- kruler : Screen ruler utility
- kshisen : Game (solitare but mahjongg)
- ksirk : Game (sirk?)
- ksnakeduel : Game (snake duel?)
- kspaceduel : Game (adversarial spaceships)
- ksquares : Game (dots an boxes)
- ksudoku : Game (sudoku)
- kteatime : Tea timer (seriously?)
- ktimer : Timer (with support for scripted actions?)
- ktorrent : Bittorrent client
- ktouch : Learn to type
- ktrip : Mobile app for public transport
- ktuberling : Game (construction)
- kturtle : Programming education tool
- kubrick : Game (rubik's cube)
- kwalletmanager : Fronted for kwallet (probably)
- kwave : Sound editor
- kweather : Mobile device weather app
- kwordquiz : Flash cards
- lokalize : Translations utility
- lskat : Game (liutenant skat)
- marble : Desktop globe? (map and geography API it seems)
- markdownpart : Framework API for markdown
- mbox-importer : Kmail addon for importing mailboxes
- merkuro : Akonadi - Calendar synchronization
- minuet : Music education
- *neochat* : Matrix client (decentralized communication)
- *okular* : Document viewer (similar to gwenview? ; libreoffice might be a better fit)
- palapeli : Game (jigsaw puzzles)
- parley : Vocabulary practice
- picmi : Game (nonogram logic)
- pim-data-exporter : Pim stuff
- pim-sieve-editor : Pim stuff
- plasmatube : Mobile (kirigami) youtube player
- poxml : Utility for docbook xml files?
- **print-manager** : Print job utility
- rocs : Graph theory IDE (visually follow NFA/DFAs algorithmically)
- signon-kwallet-extension : More kwallet stuff
- skanlite : Image scanning
- skanpage : Also image scanning
- spectacle : KDE screenshot utility
- step : Interactive physical (like doctor's office physical?) simulator
- svgpart : Framework API for SVGs
- sweeper : System cleaner
- telepathy-kde-accounts-kcm : IM Suite ()
- telepathy-kde-approver : IM Suite ()
- telepathy-auth-handler : IM Suite ()
- telepathy-kde-call-ui : IM Suite ()
- telepathy-kde-common-internals : IM Suite ()
- telepathy-kde-contact-list : IM Suite ()
- telepathy-kde-contact-runner : IM Suite ()
- telepathy-kde-desktop-applets : IM Suite ()
- telepathy-kde-filetransfer-handler : IM Suite ()
- telepathy-kde-integration-module : IM Suite ()
- telepathy-kde-send-file : IM Suite ()
- telepathy-kde-text-ui : IM Suite ()
- telly-skout : Kirigami (mobile device) TV guide
- *tokodon* : Mastodon client
- *umbrello* : UML modeler
- yakuake : Dropdown (konsole) terminal - Not my favorite, tragically
- zanshin : Akonadi - Todo list manager

## _**TODO:**_ kde-network
## _**TODO:**_ kde-multimedia
## _**TODO:**_ kde-utilities
## _**TODO:**_ kf5

# Dream `~/` folder
_Consult the `xdg-user-dirs` configuration_  

**Contents**
- Config (`ln -s /home/.config /home/Config`)
- Content
- Desktop
- Documents
- Downloads
- Media (contains Media/Music and Media/Videos)
- Projects
 
_**TODO:**_ Add note from discord on hidden files  

# Troubleshooting
## Global App Menu
Many applications run under Wayland seem to be incompatible with the global app menu, instead using their native app menu and showing no entries in the widget. The only current practical fix for this is to run the application under XWayland instead.  

## XDG Trash location
`$HOME/.local/Trash/`