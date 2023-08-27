> Quick and dirty installation instructions with specific commands used to configure my system - The only omitted information is personal stuff like the WiFi password  

# Resources
[Arch Wiki - Installation Guide](https://wiki.archlinux.org/title/Installation_guide)  
[Artix Wiki - Installation](https://wiki.artixlinux.org/Main/Installation)  
[Youtube - Learn Linux TV](https://youtu.be/DPLnBPM4DhI?si=CKxJV9tQhyc6olat)  
_^^Some information is out of date, but the structure of the video is really informative._  

# Guide
_**AHHHH I MESSED UP!**_  
I missed the memo that I should be root when using the installer ISO.  
Log in with the provided credentials, and then run `su` to act as root.  
_(Some of the commands shown have needless sudo's!)_

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

## Disk partitioning
### Target configuration
**/dev/nvme0 [PCI-E 4.0]** ->  
2TB : `/home` (Shared* user directory ; Debian will have home inside of the root partition but symlink all "user" directories, aka: shared `Desktop/` but not `.config/`)  

**/dev/nvme1 [PCI-E 3.0]** ->  
512MB : `/boot` (Boot partition ; ESP)  
750GB : `/` (Artix Linux system partition)  
~250GB : `/` (Debian system partition ; Backup OS)  

### [gdisk](https://archlinux.org/packages/extra/x86_64/gptfdisk/)
#### _**NOTE:**_ I think the reason my GRUB looked like shit on the old installs is that I accidentally used and MBR table not a GPT table so I was never actually using UEFI on my Linux install...OOPSIES.  

### Install gptfdisk
No, seriously.  

    > sudo pacman -Sy
    > sudo pacman -S gdisk

_It will be loaded into memory and unavailable again after a restart._  

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

> `sudo gdisk /dev/nvme0n1`  
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

_**TODO:**_ Partition the home drive as well (`/dev/nvme0n1`)  
> `sudo gdisk /dev/nvme0n1`  
Specified drive is now the contents of the first M.2 slot (The PCI-E 4.0 one on my system)  

### Format the partitions
> `sudo mkfs.fat -F 32 /dev/nvme1n1p1`  
Format the ESP partition as FAT32  

> `sudo mkfs.xfs /dev/nvme1n1p2`  
> `sudo mkfs.xfs /dev/nvme1n1p3`  
Format both of the system partitions as XFS  

### Mount the partitions
> ~~`sudo mkdir /mnt/boot /mmt/system`~~  
> ~~`sudo mount /dev/nvme1n1p1 /mnt/boot`~~  
> ~~`sudo mount /dev/nvme1n1p2 /mnt/system`~~  
_**TODO:**_ Ensure that this creates the intended config in `/etc/fstab`  

Alternatively, try this mount configuration:
> `sudo mount /dev/nvme1n1p2 /mnt`  
> `sudo mkdir /mnt/boot` (Use `-p` for nested directories)  
> `sudo mount /dev/nvme1n1p1 /mnt/boot`  
_**TODO:**_ Ensure that this creates the intended config in `/etc/fstab`  

## System clock (Not sure if this is needed here yet??)
> `sudo s6-rc -u change ntpd`  
Activate clock-synchronization daemon  

## Core system install
> `basestrap /mnt base base-devel s6-base elogind-s6 amd-ucode micro`  
Init system of choice: [`s6`](https://wiki.artixlinux.org/Main/S6)  
_Is it accurate to call this the GNU half of the operating system??_  

> `basestrap /mnt linux-lts linux-zen linux-lts-headers linux-firmware`  
Primary kernel of choice: `linux-zen` (it sounds like the realtime scheduling will prove beneficial for streaming)  
Backup kernel: `linux-lts` (use this when building custom modules)  

> `fstabgen -U /mnt >> /mnt/etc/fstab`  
Generate the filesystem table  

> `artix-chroot /mnt`  
Change root into the fresh install!  

### System configuration chores
> `ls -sf /usr/share/zoneinfo/US/Mountain /etc/localtime`  
> `hwclock --systohc`  
Specify and sync the time zone  

> `micro /etc/locale.gen`  
EDIT the locale file : Uncomment the locale of choice (`en_US.UTF-8 UTF-8`)  
> `locale-gen`  

> `micro /etc/mkinitcpio.conf`  
EDIT the coniguration file : Change the `HOOKS` entry  
`HOOKS=(base udev autoconnect modconf block filesystems fsck)`  
_Later we will need to add the GPU modules to `MODULES`_  

> `micro /etc/mkinitcpio.d/linux-zen.preset`  
EDIT the coniguration file : Remove the fallback preset (line 7)  
_Since I have multiple kernels installed, I really don't need two fallback images as well._  

> `cat catalyst > /etc/hostname`  
Set the hostname ; Needs to be ran as root  

### Bootloader
Bootloader of choice: `GRUB`  
_It was previously `systemd-boot` and then after the **second** time an update broke my install I decided it was time for a change...Good evening, Artix my new love._  

> `pacman -S grub efibootmgr os-prober`  
Install relevant packages (`os-prober` is optional but will be convenient considering I will be dual-booting)  

> `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub`  
> `grub-mkconfig -o /boot/grub/grub.cfg`  
Install grub for a UEFI setup  
_GRUB config file `/etc/default/grub` available in this repository (rerun `grub-mkconig`.)_  

> `cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo`  
Provide grub with a locale file  

### More packages
- networkmanager-s6
- ~~iwd --asdeps~~
- zsh
- less
- openssh
- neofetch

> `pacman -S `_`<the above list>`_  

### Users
**DANGER ZONE : SuDo Config**  
> `EDITOR=/usr/bin/micro visudo /etc/sudoers`  
EDIT sudoers file : Add dragon group to sudoers  
```
## Custom version: allow members of group dragon to execute any command
## Would require root password if set
%dragon ALL=(ALL:ALL) ALL
```

> `groupadd dragon`  
Create the user group `dragon`  

> `useradd -d /home -s /usr/bin/zsh -g dragon drayux`  
Create my personal user account ; Home directory is simply `/home`  
Successul execution can be veriied with `cat /etc/passwd`  
_This is somewhat dubious except that I am the sole user of this computer and always plan to be._   

> `chown drayux:dragon /home`  
Give main account full ownership of `/home`  

**Passwords**  
As the sole person who understands Linux where I live, I omit passwords on my system.  
However if this changes, use `passwd` or `passwd <user>` to set a password.  

If I change my mind again, `passwd -d <user>`  

# Notes
## mkinitcpio
General config located in `/etc/mkinitcpio.conf`  
Preset config(s) located in `/etc/mkinitcpio.d/`  
~~Commandline options located in `/etc/kernel/cmdline`~~  
_Appears to be irrelevant if using GRUB_  

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
