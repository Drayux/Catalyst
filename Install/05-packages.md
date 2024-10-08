# System packages
> ### "Core" list of system packages as they pertain to my use case

**\[ [⇽ Previous](./04-environment.md) | [Next ⇾](./06a-gnome.md) \]**  

> `cat /System/Scripts/packages.list | yay -`  
Install the package list: [packages.list](/System/Packages/packages.list)  
_**AUR** packages placed into seperate list: [packages-aur.list](/System/Packages/packages-aur.list)_

# Base
_Packages that are **already installed** from previous steps._  

## Kernel
- `base`
- `base-devel`
- `amd-ucode`/`intel-ucode`
- `linux`
- `linux-headers`
- `linux-firmware`
- `wireless-regdb`
- `mkinitcpio`
- `dkms`

## Boot
- `grub`
- `efibootmgr`

## Init
- `openrc`
- `elogind-openrc`
- `networkmanager-openrc`
- `openntpd-openrc`
- `bluez-openrc`
- `tlp-openrc`

## Command line
- `less`
- `mandb`
- `man-pages`
- `micro`
- `openssh`
- `git`
- `zsh`

## Package manager
- `pacman` (installed as dependency of `base`)
- `artix-keyring` (installed as a depenency of `base-devel`)
- `archlinux-keyring`

## Noteworthy dependencies
**base** ➤ `glibc`, `bash`, `grep`, `sed`, `tar`  
**base-devel** ➤ `gcc`, `make`, `sudo`, `which`  

# Graphics
_Packages relating to the system's **graphical output**._

## Driver
- `wayland`
- `wayland-utils`
- `wl-clipboard`
- `xorg-xwayland`
- `xorg-xlsclients`
- `mesa`
- `mesa-vdpau`
- `libva-mesa-driver` (likely included for OBS in the flatpak)
- `vulkan-icd-loader`
- `vulkan-radeon`/`vulkan-intel`
- `gstreamer`
- `gstreamer-vaapi`
- `gst-plugins-good`
- `gst-plugins-bad` (many deps, most of which are multimedia libs)
- `gst-plugin-gtk`
- `openxr`

## Fonts
- `ttf-noto-nerd`
- `ttf-ubuntu-nerd`
- `noto-fonts-emoji`
- `noto-fonts-cjk`
- `ttf-hack-nerd`
- `ttf-jetbrains-mono-nerd`
- `ttf-nerd-fonts-symbols-mono`

# Desktop
## Audio
- `pipewire`
- `pipewire-audio`
- `pipewire-jack`
- `pipewire-pulse`
- `pipewire-v4l2` (it should be determined if this does anything of value)
- `wireplumber`

## Software
- `libinput`
- `flatpak`
- `xdg-user-dirs`
- `xdg-desktop-portal-gtk` (base portal: others installed with desktop environment)
- `xdg-utils`

# Utility
_Miscellaneous utility/addon packages._

## System
- `pacman-contrib`
- `catimg` (consider alternatives)
- `neofetch` (since discontinued, consider alternatives)
- `clock-tui`<sup>AUR</sup>
- `cowsay`
- `cmatrix`

## Hardware
- `lm_sensors`
- `upower`
- `v4l-utils`

## Firmware
- `linux-firmware-qlogic`
- `upd72020x-fw`<sup>AUR</sup>

## Addons
- `starship`
- `sushi`
- `lsp-plugins-lv2`

# Development
_Software whose primary use is for **development**._

## Tools
- `curl` (installed as dep of pacman, but we want explicit)
- `wget`
- `neovim`
- `tmux`
- `gdb`
- `strace`
- `valgrind`

## Languages
- `python`
- `rust`

## Building
- `cmake`
- `meson`
- `ninja`

## Libraries
- ~~`glfw-wayland`~~ (conflicts with `glfw-x11`; better to keep it local to the project, else it's a dependency)
- `vulkan-headers`
- `vulkan-validation-layers`
- `vulkan-mesa-layers`
- `vulkan-tools`
- `spirv-tools`
- (Look into: `vulkan-extra-tools` `vulkan-extra-layers` `vulkan-utility-libraries`)
- `openxr-headers-git`<sup>AUR</sup> (akin to `glfw`, might be best to submodule this with the project)
