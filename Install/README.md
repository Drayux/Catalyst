# Operating system install
> ### A personalized flow with the things I like and without the things I don't

# About
This directory is organized into a pseudo-"drop in" format but for sets of instructions. Each file denotes a major "phase" of the install, and these files should be relevant in an arbitrary order, so long as the target states of the preceeding files have been satisfied. (I.E. setting up the desktop environment wouldn't apply very effectively if the system is not yet bootable.)

Furthermore, this guide applies to all of my computers, where some steps apply to only one configuration and not another. The guide will prioritize my desktop system (catalyst.v3) with additional footnotes for my laptop: a repurposed Macbook 14,2 (chitin.v1) with additional firmware demands. These system-dependent variations are indiciated accordingly within the documents.

# System
**Operating System:** Artix Linux  
**Init System:** Open RC  
**Desktop:** (Minimal) Gnome / Hyprland  
  
**CPU:** AMD Ryzen-9 5900X  
**GPU:** AMD RX7900 XTX  

# Resources
[Artix Wiki - Installation Guide](https://wiki.artixlinux.org/Main/Installation)  
[Arch Wiki - Installation Guide](https://wiki.archlinux.org/title/Installation_guide)  
[Youtube - Learn Linux TV](https://youtu.be/DPLnBPM4DhI?si=CKxJV9tQhyc6olat)  
_^^Some information is out of date, but I found the presentation to be incredibly beneficial._  

# Files
[**installer**](./00-installer.md) ➤➤ Setup of the bootable installation medium  
[**base**](./01-base.md) ➤➤ Base system install: bootloader, init system, kernel, networking, and package manager  
[**config**](./02-config.md) ➤➤ System-wide configuration  
[**hardware**](./03-hardware.md) ➤➤ Additional components for full HW support (firmware, modules, dkms, etc.)  
[**environment**](./04-environment.md) ➤➤ User accounts and system functionality  
[**packages**](./05-packages.md) ➤➤ Remaining system packages  
[**gnome**](./06a-gnome.md) ➤➤ Gnome desktop environment  
[**hyprland**](./06b-hyprland.md) ➤➤ Hyprland "desktop environment"  
[**flatpak**](./07-software.md) ➤➤ Flatpak applications and respective tweaks  
