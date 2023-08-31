> Quick and dirty installation instructions with specific commands used to configure my system - The only omitted information is personal stuff like the WiFi password  

# Resources
[Arch Wiki - Installation Guide](https://wiki.archlinux.org/title/Installation_guide)  
[Artix Wiki - Installation](https://wiki.artixlinux.org/Main/Installation)  
[Youtube - Learn Linux TV](https://youtu.be/DPLnBPM4DhI?si=CKxJV9tQhyc6olat)  
_^^Some information is out of date, but the structure of the video is really informative._  

# Guide
## _**TODO:**_ Bootable Medium
Add the necessary configuration for the custom flexible bootable USB stick.  
Also pending getting the other distributions to work smh.  

### _The installation medium is [**Artix Linux**](https://artixlinux.org/download.php#official)_ 

### Login
**Username** : root  
**Password** : artix  

## Connect to the internet (if on wireless)
_I like to do this first as its the biggest pain in the ass if it proves not to work half-way through._  
[Arch Wiki - Network Configuration](https://wiki.archlinux.org/title/Network_configuration/Wireless)  

### Setup

> `ip link`  
List the adapters  

> `rfkill`  
> `rfkill unblock wlan`  
List the block states; provide a fix for the error `RTNETLINK answers: Operation not possible due to RF-kill` as the device is blocked by the kernel  

> `ip link set wlan0 up`  
Enable the wireless interface  

### Connect
_My current access points use WPAX so we need to use [`wpa_supplicant`](https://wiki.archlinux.org/title/Wpa_supplicant) (WEP is the old school, fixed-length one.)_  

> `wpa_cli`  
Start the command line utility (somewhat scuffed but it gets the job done)  

_**TODO:**_ `wpa_supplicant` assumes a specific interface by default, though it seems this can be specified with the CLI as well.

    > scan
    > scan_results
    ...
    > add_network
    0
    > set_network 0 ssid "SSID"
    > set_network 0 psk "PASSWORD"
    > enable_network 0

> `ip a`  
Display the adapters and their associated connections  

### System clock (Not sure if this is actually necessary)
> `s6-rc -u change ntpd`  
Activate clock-synchronization daemon  
_The s6 call is used because we have the s6 installation medium; See [here](https://wiki.artixlinux.org/Main/Installation#Update_the_system_clock) for the other mediums._


## Disk partitioning
### Target configuration
**/dev/nvme0 [PCI-E 4.0]** ->  
2TB : `/home` (Shared* user directory ; Debian will have home inside of the root partition but symlink all "user" directories, aka: shared `Desktop/` but not `.config/`)  

**/dev/nvme1 [PCI-E 3.0]** ->  
512MB : `/boot` (Boot partition ; ESP)  
750GB : `/` (Artix Linux system partition)  
~250GB : `/` (Debian system partition ; Backup OS)  

### _If reinstalling to existing partition, skip to [formatting](#format-the-partitions)_
Format just p2 for the system, and p1 if starting fresh with grub.  

### Install gptfdisk
No, seriously.  

    > pacman -Sy
    > pacman -S gdisk

_It will be loaded into memory and unavailable again after a restart._  

#### [gdisk](https://archlinux.org/packages/extra/x86_64/gptfdisk/)
#### _**NOTE:**_ I think the reason my GRUB looked like shit on the old installs is that I accidentally used and MBR table not a GPT table so I was never actually using UEFI on my Linux install...OOPSIES.  

### Partition the drive(s)
[Arch Wiki - Partitioning](https://wiki.archlinux.org/title/Partitioning)  
[GDisk Guide](https://appuals.com/partition-configure-drives-linux-uefi-boot/)  

> `lsblk`  
Display the storage device tree  

> `blkid` _(run with sudo)_  
Less pretty version of `lsblk` but it outputs the partition UUIDs  

> `wipefs -a /dev/nvme1n1`  
Absolutely fucking obliterate your entire hard drive (namely the NVMe drive in the second M.2 slot here) ; Allows for a fresh start with `gdisk`  
**DO NOT FUCK UP WHICH DRIVE YOU SPECIFY HERE!**  

> `gdisk /dev/nvme0n1`  
Open the gdisk CLI on the specified drive (namely the NVMe drive in the second M.2 slot here)  

    > o
    This option deletes all partitions and creates a new protective MBR.
    Proceed? (Y/N): y 
    # This seems to have been done automatically
    > v
    # Optional - Verify the disk
    > n
    Partition number (1-128, default 1): 
    First sector (34-1953525134, default = 2048) or {+-}size{KMGTP}: 
    Last sector (2048-1953525134, default = 1953525134) or {+-}size{KMGTP}: +512M 
    Hex code or GUID (L to show codes, Enter = 8300): EF00 
    > n
    Partition number (1-128, default 2): 
    First sector (34-1953525134, default = 1050624) or {+-}size{KMGTP}: 
    Last sector (1050624-1953525134, default = 1953525134) or {+-}size{KMGTP}: +750G
    Hex code or GUID (L to show codes, Enter = 8300): 8304 
    > n
    Partition number (1-128, default 3): 
    First sector (34-1953525134, default = 1573914624) or {+-}size{KMGTP}: 
    Last sector (1573914624-1953525134, default = 1953525134) or {+-}size{KMGTP}: 
    Hex code or GUID (L to show codes, Enter = 8300): 8304 
    > c
    Partition number (1-3): 1
    Enter name: EFI
    > c
    Partition number (1-3): 2
    Enter name: Artix
    > c
    Partition number (1-3): 3
    Enter name: Debian
    > w
    Do you want to proceed? (Y/N): y

#### Partition the home drive as well (`/dev/nvme0n1`)  
> `gdisk /dev/nvme0n1`  
Specified drive is now the contents of the first M.2 slot (The PCI-E 4.0 one on my system)  

    > o
    This option deletes all partitions and creates a new protective MBR.
    Proceed? (Y/N): y 
    > n
    Partition number (1-128, default 1): 
    First sector (34-3907029134, default = 2048) or {+-}size{KMGTP}: 
    Last sector (2048-3907029134, default = 3907029134) or {+-}size{KMGTP}: 
    Hex code or GUID (L to show codes, Enter = 8300): 8302 
    > c
    Partition number (1-3): 1
    Enter name: Drayux
    > w
    Do you want to proceed? (Y/N): y 

### Format the partitions
> `mkfs.fat -F 32 /dev/nvme1n1p1`  
Format the ESP partition as FAT32  

> `mkfs.xfs -f /dev/nvme1n1p2` (Artix system)  
> ~~`mkfs.xfs -f /dev/nvme1n1p3` (Debian)~~  
> `mkfs.xfs -f /dev/nvme0n1p1` (Drayux home)  
Format both of the system partitions as XFS  
_**NOTE:**_ The `-f` flag will force an overwrite  

### Mount the partitions
> `mount /dev/nvme1n1p2 /mnt`  
> `mkdir /mnt/boot /mnt/home` ~~(Use `-p` for nested directories)~~  
> `mount /dev/nvme1n1p1 /mnt/boot`  
> `mount /dev/nvme0n1p1 /mnt/home`  
_**TODO:**_ Ensure that this creates the intended config in `/etc/fstab`  

## Core system install
> `basestrap /mnt base base-devel amd-ucode dinit elogind-dinit ~~seatd-dinit~~`  
Init system of choice: [`dinit`](https://wiki.artixlinux.org/Main/Dinit)  
_Is it accurate to call this the GNU half of the operating system??_  

> `basestrap /mnt linux-lts linux-zen linux-lts-headers linux-firmware micro zsh`  
Primary kernel of choice: `linux-zen` (it sounds like the realtime scheduling will prove beneficial for streaming)  
Backup kernel: `linux-lts` (use this when building custom modules)  

> `fstabgen -U /mnt >> /mnt/etc/fstab`  
Generate the filesystem table  
VERIFY : Extraneous mounts may be shown, for example

> `artix-chroot /mnt`  
Change root into the fresh install!  

### Bootloader
Bootloader of choice: `GRUB`  
_It was previously `systemd-boot` and then after the **second** time an update broke my install I decided it was time for a change...Good evening, Artix my new love._  

> `pacman -S grub efibootmgr os-prober`  
Install relevant packages (`os-prober` is optional but will be convenient considering I will be dual-booting)  

> `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub`  
> `grub-mkconfig -o /boot/grub/grub.cfg`  
Install grub for a UEFI setup  
_GRUB config file `/etc/default/grub` available in this repository (rerun `grub-mkconig` after making changes.)_  

> `cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo`  
Provide grub with a locale file  

### System configuration chores
> `dinitctl enable seatd`  
Enable the user management service (used by Hyprland later on)  
_**TODO:**_ Verify if this step is required or not  

> `ln -sf /usr/share/zoneinfo/US/Mountain /etc/localtime`  
> `hwclock --systohc`  
Specify and sync the time zone  

> `micro /etc/locale.gen`  
EDIT : Uncomment the locale of choice (`en_US.UTF-8 UTF-8`)  
> `locale-gen`  

> `chsh root`  
> `> /bin/zsh`  
Change the default shell for root  

> `echo catalyst > /etc/hostname`  
Set the hostname ; Needs to be ran as root  

---
**DANGER ZONE : sudo config**  
> `EDITOR=/usr/bin/micro visudo /etc/sudoers`  
EDIT : Add dragon group to sudoers  
```
## Custom version: allow members of group dragon to execute any command
## Would require password if user has one set
%dragon ALL=(ALL:ALL) ALL
```
---

> `pacman -S mesa vulkan-radeon libva-mesa-driver mesa-vdpau wayland`  
Install the [graphics drivers/related software](https://wiki.archlinux.org/title/AMDGPU#Installation)  
_**NOTE:**_ Wayland is included here so it is marked as an explicit install  
_My system uses and AMD graphics card, it should be self-evident that this step will be different with an NVidia or Intel card._  

> `micro /etc/mkinitcpio.conf`  
EDIT : Change the `HOOKS` and `MODULES` entries  
`HOOKS=(base udev modconf block filesystems fsck)`  
`MODULES=(amdgpu radeon)`  

> `micro /etc/mkinitcpio.d/linux-zen.preset`  
> `rm /boot/initramfs-linux-zen-fallback.img` (Optional: Remove the extra entry generated by the pacman hook)  
EDIT the coniguration file : Remove the fallback preset (line 7)  
_Since I have multiple kernels installed, I really don't need two fallback images as well._  

> `mkinitcpio -P`  
Regenerate the initramfs image  

### More packages
- networkmanager-dinit
- less
- man-db
- openssh
- neofetch  
//
- git
- python  
- cmake  
- meson  
- ninja  
//  
- pipewire
- pipewire-audio
- pipewire-pulse
- pipewire-jack
- wireplumber  
//  
- gdisk*
- dosfstools* (provides tools for FAT filesystem)
- xfsprogs* (provides tools for XFS filesystem)

> `pacman -S `_`<the above list>`_  

### Users
> `groupadd dragon`  
Create the user group `dragon`  

> `useradd -d /home -s /bin/zsh -g dragon drayux`  
Create my personal user account ; Home directory is simply `/home`  
Successul execution can be veriied with `cat /etc/passwd`  
_This is somewhat dubious except that I am the sole user of this computer and always plan to be._   

> `chown drayux:dragon /home`  
Give main account full ownership of `/home`  

**Passwords**  
Having no password, and simply not setting a password are two different states. As the sole person who understands Linux where I live, I omit passwords on my account.  

    > passwd -d drayux
    > passwd root
    New password: ***
    Retype new password: ***

However if this changes, use `passwd` or `passwd <user>` to set a password.  
To change back to no password, `passwd -d <user>`  

## _**System is ready for reboot**_

## Final setup
### Networking configuration
> `dinitctl start NetworkManager`  
> `dinitctl enable NetworkManager` (Autostart everytime)  
> ~~`s6-rc -u change NetworkManager-srv`~~
> `nmcli d wifi list`  
> `nmcli d --ask wifi connect <SSID>`  
> `nmcli con show` _(Optional, good sanity check)_  
Configure a wireless network with NetworkManager (system will always connect to this network now)  
_**TODO:**_ Determine how to specify a device if multiple are available  

### SSH setup : Requires a personal key saved in the bootable medium
Many of these config files would be nice to have before installing a WM/DE, but to clone this repo from GitHub I need either my password manager or my SSH key. Generating a new key and typing it into the interface (likely via a mobile device) would be a nightmare. 

> `micro /etc/ssh/ssh_config`  
EDIT : Change all paths from `~/.ssh` to `~/.config/ssh`  
_This step is optional, instead we can copy to the default directory and move it after copying the config from this repo._  

> `mkdir -p /mnt/usb && mount /dev/sda1 /mnt/usb`  
> `cp -r /dev/sda1/ssh /home/.config`  

### Config files
> `git clone git@github.com:Drayux/Catalyst.git ~/Projects/Catalyst`  
> ~~`sudo /home/Projects/Catalyst/copy-config.zsh`~~  
_**TODO:**_ Finish the `copy-config.zsh` script!

### Package repositories
**Update `/etc/pacman.conf`**  
_This step is also optional if we copy the config from the repo, but it's good to enumerate._

    #### Artix ####
    [system]
    Include = /etc/pacman.d/mirrorlist

    [world]
    Include = /etc/pacman.d/mirrorlist

    [galaxy]
    Include = /etc/pacman.d/mirrorlist

    [lib32]
    Include = /etc/pacman.d/mirrorlist

    [universe]
    Server = https://mirror.pascalpuffke.de/artix-universe/$arch
    Server = https://mirrors.qontinuum.space/artixlinux-universe/$arch
    Server = https://mirror1.cl.netactuate.com/artix/universe/$arch
    Server = https://ftp.crifo.org/artix-universe/$arch
    Server = https://artix.sakamoto.pl/universe/$arch
    Server = https://mirror1.artixlinux.org/universe/$arch
    Server = https://universe.artixlinux.org/$arch

    #### Arch ####
    [extra]
    Include = /etc/pacman.d/mirrorlist-arch

    [community]
    Include = /etc/pacman.d/mirrorlist-arch

    [multilib]
    Include = /etc/pacman.d/mirrorlist-arch

> `pacman -Sy`  
Download the new database files  

> `pacman-key --populate archlinux`  
Add the arch linux repo GPG keys  

> `pacman -S artix-archlinux-support`  
Install the systemd compatibility scripts  

**Install Yay**  
_More information in `Build/Yay/README.md`_
> `sudo pacman -S --asdeps go`  
> `git clone https://aur.archlinux.org/yay.git`  
> `cd yay`  
> `makepkg`  
> `sudo pacman -U yay-...-x86_64.pkg.tar.zst`  
_**NOTE:**_ This should be ran as a normal user ; Cloning with git as root will create ~~weird~~ annoying permissions issues  

**Update `~/.config/yay/config.json`**  
_Included is just changes ; This file is also available in the config repository._  

    "sortby": "name"
    "removemake": "yes"
    "bottomup": true
    "devel": true
    "diffmenu": false

### User dinit services
[dinit-userservd - GitHub](https://github.com/Xynonners/dinit-userservd)  
[turnstile (alternative project) - GitHub](https://github.com/chimera-linux/turnstile)  
_`dinit-userservd` was forked from `turnstile` when turnstile was still only dinit-userservd._

**Dependency Notes**  
`dinit-userservd` requires `meson` as a make dependency  
`pam` is required for permissions negotiation  
Finally, an `elogind` service must also be running (which means it depends on `elogind-dinit` which replaces `seatd-dinit`)  

> `git clone git@github.com:Xynonners/dinit-userservd-PKGBUILD.git ~/Downloads/Repositories/dinit-userservd`  
Clone the PKGBUILD repo  

> `cd ~/Downloads/Repositories/dinit-userservd/dinit-userservd`  
> `sudo makepkg -i` (`-s` is omitted as dependencies should be installed ; elogind technically requires manual intervention)  
Install the package (essentially the dinit service file and the pam object)  
_**TODO:**_ Consider making a copy of these files in this repository for the sake of backup

> `micro /etc/pam.d/system-login`  
EDIT : Append the dinit_userservd.so entry  
`session   optional   pam_dinit_userservd.so`  

> `mkdir -p ~/.config/dinit.d/boot.d` (service directory)  
> `mkdir -p ~/.local/share/dinit` (service log directory)  
> `sudo dinitctl enable dinit-userservd`  
Enable the `dinit-userservd` service  

### _Install the rest of the config files_
### _Begin setup of the [desktop environment](./Desktop.md)..._

# Notes
## System Image
General config located in `/etc/mkinitcpio.conf`  
Preset config(s) located in `/etc/mkinitcpio.d/`  
~~Commandline options located in `/etc/kernel/cmdline`~~  
_Appears to be irrelevant if using GRUB_  

## List available shells
> `chsh -l`  

## Using `dinit`
[Github dinit Guide](https://github.com/davmac314/dinit/blob/master/doc/getting_started.md)  

For my system, `dinit` appears to be considerably faster than both s6 and systemd.  
If running `dinitctl`, forgetting to use `sudo` will show a file not found error.  

Further, if a service depends on another, and that service is not running (rather, does not exist in the case of dinit-userservd and elogind) then dinit will report that it cannot find the service description.  

## Verify UEFI mode
If the directory `/sys/firmware/efi` exists, then the system was booted with UEFI.  
[Source (AskUbuntu)](https://askubuntu.com/questions/162564/how-can-i-tell-if-my-system-was-booted-as-efi-uefi-or-bios#answer-162896)  

## Check what shell is running
> `ps -p $$`  
`$$` is the PID of the current shell  

## **TODO:** Force kill a task (via name or PID)

## Networking
Network Manager (`networkmanager`) installs `wpa_supplicant` as a dependency. However the nature of network manager providing a service to handle saved connections means that we do not want to interface with `wpa_cli` directly (if this service as running) as the two configurations will conflict, even if they both specify the same network.  

## Swap (file)
_My system has 128GB of RAM so I have taken the liberty to assume that we are safe without making a swap file. Below is the process if I change my mind._  

```
Create empty file (dd if=/dev/zero of=/mnt/swap bs=1M count=8196)
^^8196 * 1M = 8GiB; Swapfile cannot be put into /dev lmao
Change permissions (chmod 600 /mnt/swap)
Convert to swapfile (mkswap /mnt/swap)
Add to fstab configuration (nano /etc/fstab)
  >+ /mnt/swap   none   swap   sw   0 0
Can be tested with (mount -a && swapon -a)
```

## Directory symlinks
For some reason this is the least intuitive unix tool.  
To create a symbolic link _from_ DIR_A _to_ DIR_B:  

    ln -s path/to/DIR_B path/to/DIR_A
