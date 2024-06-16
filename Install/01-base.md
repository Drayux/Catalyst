# Base system install
> ### The most important steps: System will be bootable after this phase

**\[ [⇽ Previous](./00-installer.md) | [Next ⇾](./02-config.md) \]**  

## Booting
Use the installation medium created in [**00-installer.md**](./00-installer.md) to boot into the Artix Linux installer.
> **Catalyst:** This requires pressing F11 to enter the boot selection menu  
> **Chitin:** We are restricted to Apple's EFI, hold option immediately after power-on to be presented with the boot medium selection  

### Login
**Username** : root  
**Password** : artix  

### Additional Notes
- The system can also be accessed as a non-root user with the username/password: `artix`/`artix`
- On Chitin, the 13" MacBook Pros have weird EDID data that reports 2800x1800 as a supported video mode, when in fact, this mode is not supported properly by the display. This results in the console output rendering offscreen at the bottom and to the right of the display, which makes the TTY install quantifiably more challenging. Adding `i915.modeset=0` as a kernel parameter will disable KMS for the Intel graphics module and keep the (correctly-selected) resolution from Grub. Accomplish this by pressing `e` on the Artix boot entry, and appending the paramter to the end of the line beginning with `linux`.
- [Arch Wiki - Intel Graphics](https://wiki.archlinux.org/title/Intel_graphics)

## Networking (Wireless)
### Unblock the adapter
> `rfkill unblock wlan`  
Skipping this step yields the error `RTNETLINK answers: Operation not possible due to RF-kill` as the device is blocked by the kernel.  

### Connect
> `wpa_cli`  
Start the command line utility (somewhat scuffed but it gets the job done)  
_My current access points use WPAX so we use [`wpa_supplicant`](https://wiki.archlinux.org/title/Wpa_supplicant) (WEP is the old school, fixed-length alternative.)_  

    > scan
    > scan_results
    ...
    > add_network
    0
    > set_network 0 ssid "SSID"
    > set_network 0 psk "PASSWORD"
    > enable_network 0

### System clock
_This is necessary so that the package manager can verify the integrity of the packages to be installed._
> `rc-service ntpd start`  
Activate clock synchronization service  
_The rc-service call is used because we have the openrc variant of the installation medium. See [the official Artix guide](https://wiki.artixlinux.org/Main/Installation#Update_the_system_clock) for the other init systems._

> `pacman -Sy`  
Download the package database  
_Since we're in a read-only filesystem, the database is downloaded to memory and therefore will not be present upon a reboot. This also applies to any additional packages installed in this phase._

### Utility
> `ip link`  
List the adapters  
  
> `ip a`  
Display the connection statuses  
  
> `rfkill`  
View the state of all rfkill switches (usually only entries for wlan and bluetooth)  

### Additional notes
- Setting up networking is not always required for system maintenance, but certainly so for system installation
- `pacman -Sy` is generally only necessary if not using `artix-chroot` as the target system _should_ have the database downloaded (though it could be out of date!)
- Wireless on Chitin is faulty until the firmware is configured: Mobile hotspots and older (i.e. Wifi \<6) access points do seem to work, however
- Additionally, the installation medium seems to be absent the thunderbolt module necessary for wired connections to work on Chitin as well
- _**TODO:**_ `wpa_cli` assumes a specific interface by default, though it seems that this can be specified with a parameter
- [Arch Wiki - Network Configuration](https://wiki.archlinux.org/title/Network_configuration/Wireless)

## Storage
### Partition table
> **CATALYST ONLY**  

**/dev/nvme1n1 : 1TB**  
> `/boot` ➤➤ ESP partition [511MiB : FAT32]  
> `/` ➤➤ System partition (Artix Linux) [181GiB : XFS]  
> `/home` ➤➤ User partition (Drayux) [750GiB : XFS]  
  
**/dev/nvme0n1 : 2TB**  
> `???` ➤➤ Storage partition [??? : XFS] **TODO**  

> `pacman -S gdisk`  
Install the [gptfdisk](https://archlinux.org/packages/extra/x86_64/gptfdisk/) package (Else we're stuck with the archaic shit)  

> `gdisk /dev/nvme1n1`  
Interactive partitioning CLI  
_Changes are only made upon a write command, so `CTRL-C` and starting over is a valid means of fixing mistakes. That said, one should be extraordinarily certain that they have specified the correct drive._  

    > o
    This option deletes all partitions and creates a new protective MBR.
    Proceed? (Y/N): y 

    > n
    Partition number (1-128, default 1): 1
    First sector (34-1953525134, default = 2048) or {+-}size{KMGTP}: 2048
    Last sector (2048-1953525134, default = 1953525134) or {+-}size{KMGTP}: +511M 
    Hex code or GUID (L to show codes, Enter = 8300): EF00 

    # ^^Ending at sector 1,048,575 means that the partition table + esp partition is 512MiB exactly

    > n
    Partition number (1-128, default 2): 2
    First sector (34-1953525134, default = 1048576) or {+-}size{KMGTP}: 1048576
    Last sector (1048576-1953525134, default = 1953525134) or {+-}size{KMGTP}: 380659711
    Hex code or GUID (L to show codes, Enter = 8300): 8304 

    # ^^Funny size so that the user parition will be exactly 750GiB ( = 1,572,864,000 sectors)

    > n
    Partition number (1-128, default 3): 3
    First sector (34-1953525134, default = 380659712) or {+-}size{KMGTP}: 380659712
    Last sector (380659712-1953525134, default = 1953523711) or {+-}size{KMGTP}: +750G
    Hex code or GUID (L to show codes, Enter = 8300): 8304 

    > c
    Partition number (1-3): 1
    Enter name: EFI

    > c
    Partition number (1-3): 2
    Enter name: System

    > c
    Partition number (1-3): 3
    Enter name: Home

    > w
    Do you want to proceed? (Y/N): y

### Filesystem creation
> **Catalyst:** The following configuration applies directly to catalyst  
> **Chitin:** Format **ONLY** `/dev/nvme0n1p2` as XFS and nothing else!  

> `mkfs.fat -F 32 /dev/nvme1n1p1`  
Format the ESP partition as FAT32  
_FAT32 is generally required for a drive to be bootable, even with modern hardware._  
  
> `mkfs.xfs /dev/nvme1n1p2`  
> `mkfs.xfs /dev/nvme1n1p3`  
Format the system and user partitions as XFS  
_Use the `-f` flag to overwrite an existing filesystem; this is likely necessary for Chitin._  

### Mount points
> `mount /dev/nvme1n1p2 /mnt`  
> `mkdir /mnt/boot /mnt/home`  

> `mount /dev/nvme1n1p1 /mnt/boot`  
> `mount /dev/nvme1n1p3 /mnt/home`  
_If creating directories with a different, nested structure, the `-p` flag can be specified with `mkdir` to generate parent directories to that of the target._  

> `fstabgen -U /mnt >> /mnt/etc/fstab`  
Generate the filesystem mount table based off of the currently mounted drives  

### Utility
> `lsblk`  
Display the storage device tree  

> `blkid`  
Output partition UUIDs (Less pretty but more verbose version of `lsblk`)  

> `wipefs -a /dev/<device>`  
Obliterate your entire disk ; Might be convenient, might be crazy hamburger, you decide!    

### Additional notes
- Both of my drives use 512 byte sectors, so calculations are performed accordingly
- [GPT fdisk Guide](https://appuals.com/partition-configure-drives-linux-uefi-boot/)
- [Arch Wiki - Partitioning](https://wiki.archlinux.org/title/Partitioning)

## Installation
> `basestrap /mnt base base-devel amd-ucode/intel-ucode micro`  
Install basic packages via a pacman wrapper script  
_Important! `amd-ucode` should be installed on systems with an AMD chipset versus `intel-ucode` for systems with an Intel chipset! (Specifically this is AMD for Catalyst and Intel for Chitin, hence why both are listed.)_  
  
> `artix-chroot /mnt`  
Treat our fresh install as the new root!  
_Anything installed while in this environment will be persistent, as this **is** our new install._  
  
**TODO:** Verify that pacman's out-of-the-box config has parallel downloads enabled.  
~~`sed -i 's/#Parallel/Parallel/' /etc/pacman.conf`~~  

> `pacman -S openrc mkinitcpio linux linux-headers linux-firmware grub efibootmgr elogind-openrc networkmanager-openrc openntpd-openrc less mandb man-pages openssh git zsh`  
Install the remaining essential packages  

> `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub`  
> `cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo`  
> `update-grub`  
Install the bootloader ([grub](https://wiki.archlinux.org/title/GRUB))  
_`/usr/bin/update-grub` is a wrapper script for `grub-mkconfig -o /boot/grub/grub.cfg` provided by the grub package._  

### Root password
> `passwd`  
Set a root password  
_Optionally use the `-d` flag to set the password as \<no password\>. I feel obligated to remind the user, however, that this is **not** recommended (even though I've done this myself.)_  

### Additional notes
- If reinstalling without wiping the EFI partition, the microcode will already be present in said partition, hence causing some "file already exists" type conflicts with pacman. This can be mitigated most easily by specifying the `--overwrite` option (i.e. `pacman -S --overwrite amd-ucode`) or by simply not installing the package.  
- Optionally, `openssh-openrc` can be installed and the system can be set up remotely once the daemon is running. I do not do this however, so configuration for this is omitted.
- When rebooting, you will need to exit the `artix-chroot` environment in order to perform the `reboot` or `poweroff` commands from the command line.
- For the sake of technicality, I consider setting the root password to be a better fit for [system configuration](./02-config.md) except that the system is "not independently bootable" without one set.
- Though the system is now bootable, it is recommended to complete [hardware configuration](./03-hardware.md) before rebooting.
- The root password can be "re-reset" by accessing the system via the installation medium and running the `passwd` utility again.
