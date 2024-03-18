# Operating system install
> ### A personalized flow with the things I like and without the things I don't

# About
This directory is organized into a pseudo-"dropin" format but for sets of instructions. Each file denotes a major "phase" of the install, and these files should be relevant in an arbitrary order, so long as the target states of the preceeding files have been satisfied. (I.E. setting up the desktop environment wouldn't apply very effectively if the system is not yet bootable.)  
  
Furthermore, this guide applies to all of my computers, where some steps apply to only one configuration and not another. The guide will prioritize my desktop system (catalyst.v3) with additional footnotes for my laptop: a repurposed Macbook 14,2 (chitin.v1) with additional firmware demands.  
**TODO:** These additions will be indicated....somehow.  

# System
**Operating System:** Artix Linux  
**Init System:** Open RC  
**Desktop:** (Minimal) Gnome / Hyprland  
  
**CPU:** AMD Ryzen 9 5900X  
**GPU:** AMD RX 7900 XTX  

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
[**flatpak**](./07-flatpak.md) ➤➤ Flatpak applications and respective tweaks  

_**TODO:** Move these to an Applications/ (needs alternative name) folder that has information for setting up any major additional systems: gaming, VMs, OBS....advanced audio scripting and my NAS setup still need locations._  
[**games**](./09a-games.md) ➤➤ Linux gaming setup (+VR)  
[**virtualization**](./09b-virtualization.md) ➤➤ Virtual machines (+PCIE passthrough)  
