# About
This repository is my attempt at a creating a comprehensive collection of everything major I've learned about linux since I dove down the rabbit hole a year ago as well as all of my configuration files, scripts, and the like.

This is still a **work in progress** (and probably always _will_ be to some extent) as I still have many steps remaining to "perfect" my setup. The vast majority of configuration files will likely only be added after I have "completed" that portion of the setup to the full extent of my intention.

# Discussions
I highly encourage you to use the github discussions feature for any configuration changes you wish to suggest, typos on my readmes, questions left unanswered, or even if you're facing a similar issue to me! I love hearing feedback, and perhaps I may be a helpful resource to you.

# To-do
- Write a script that runs through `Config/Filesystem/` and checks for differences between the files located here and those on the system (ensure script ignores any files with the name of README.md)
- Some of the packages on the install guide can (and probably should) be moved to later phase as many are not immediately necessary
- Finish this To-do list  

# Directory Structure
### OUT OF DATE--still figuring the new hierarcy
## Build
Manually compiled applications (not handled by package manager)  
Includes references to specific Git repo / branch, notes on dependencies and build troubleshooting  
Includes copies of any modified files, and additional build files (like OBS -> build.sh)  
  
## Config
Any program configuration files (basically a directory clone of /etc/ and /home/.config)  
_^^These will be located in `./Filesystem`_  
Also includes notes to miscellaneous things such as links to KDE themes, fonts, etc.  
Finally, customization resources will be available here as well (such as desktop wallpapers)  
  
## Install
Notes regarding installation and initial setup of the OS (include microsoft in EFI partition, useradd options)  
List of systemd services to enable (or disable)  
Includes files such as a comprehensive list of packages to explicitly install  
  
## Notes
Miscellaneous notes of various tricks and troubleshooting (ex. finding the package responsible for a file w/ pacman or launch parameters for steam games)  
Also included are things like a "system TODO list"  
  
## Scripts
Personal, system-management scripts (/home/Documents/scripts)  

---

## _Misc_
A collection of incompleted drafts of various things; unorganized and unsuitable for being "published" to the primary configuration  