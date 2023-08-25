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

# Troubleshooting
## Global App Menu
Many applications run under Wayland seem to be incompatible with the global app menu, instead using their native app menu and showing no entries in the widget. The only current practical fix for this is to run the application under XWayland instead.  
