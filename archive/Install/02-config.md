# System configuration
> ### Basic config edits (aka system install chores)

**\[ [⇽ Previous](./01-base.md) | [Next ⇾](./03-hardware.md) \]**  

_This phase does not depend upon the bootable medium, but it is most convenient to continue this phase while still in the `artix-chroot` environment._  

## Hostname
> **Catalyst:** `echo catalyst > /etc/hostname`  
> **Chitin:** `echo chitin > /etc/hostname`  

## Locale
> `micro /etc/locale.gen`

    > +   | en_US.UTF-8 UTF-8
_This locale specification can be uncommented on line 171._

> `locale-gen`  
Generates system locale information based upon the selection in `/etc/locale.gen`  
_Multiple entries may be selected for generation._

## Clock
> `ln -sf /usr/share/zoneinfo/US/Mountain /etc/localtime`  
> `hwclock --systohc`  
Sets the computer time zone  

## Environment
> `micro /etc/security/pam_env.conf`  

    > +   | XDG_CONFIG_HOME	DEFAULT=@{HOME}/.config
    > +   | ZDOTDIR			DEFAULT=@{HOME}/.config/zsh

## Sudo
> `EDITOR=/usr/bin/micro visudo /etc/sudoers`  

    > +    | %dragon ALL=(ALL:ALL) ALL
Any users with the `dragon` group will be able to use sudo with their user password  
_This follows the same format as the default with `wheel` but with the default group for my user account (created later)._  

## System image
> `micro /etc/mkinitcpio.conf`  

    > +/- | MODULES=(amdgpu)
    > +/- | HOOKS=(base udev autodetect kms modconf block filesystems)
    > +   | COMPRESSION="lz4"
_Specifying `amdgpu` as a module and `kms` as a hook is only needed for **Catalyst** as this allows for early KMS with the GPU (aka pretty graphics on boot.) The Intel GPU (i915 module) on Chitin depends on KMS for any accelerated rendering and appears to override many kernel hints anyway._  

> `mkinitcpio -P`  
Regenerate the initramfs image  
_The `-P` flag will generate an image for **every** preset, whereas the `-p [preset]` flag generates only the indicated preset._

### Lightspeed booting (optional)
If you are confident that the system will boot with the primary image, we can remove the fallback preset and have room in our EFI partition for an uncompressed image.  
_The difference between the primary preset and the fallback preset is that the autodetect hook (in HOOKS=(...) will not run, so **every** module will be placed into the image to ensure that any system should be able to boot._  
  
> `rm /boot/initramfs-linux-fallback.img`  
Remove the existing image generated when pacman runs the inital initramfs hook  

> `micro /etc/mkinitcpio.d/linux.preset`

    > +/- | PRESETS=('default')

> `micro /etc/mkinitcpio.conf`  

    > +/- | COMPRESSION="cat"

> `mkinitcpio -P`  
Regenerate the initramfs image (same process as above)  
_Even with only one preset, it's still easier to type `-P` than `-p default`._

### Additional notes
- There are many warnings for ["Possibly missing firmware..."](https://wiki.archlinux.org/title/Mkinitcpio#Possibly_missing_firmware_for_module_XXXX) which simply means that mkinitcpio sees modules to include (that are built into the kernel source tree) where there exists no corresponding firmware within `/usr/lib/firmware/`. This warning is only important if your system contains devices which would use these modules. _(This error will occur more in the fallback image as every available module is being included instead of just the relevant ones if the autodetect hook is being ran.)_
- The majority of the missing firmwares are provided by the package `linux-firmware-qlogic` and relevant for **Catalyst** and **Chitin** is the AUR package `upd72020x-fw` for the `xhci_pci` module.
- `fsck` is a filesystem check hook which can be appended to the end of HOOKS. However, the filesystem check binary does not seem to be included while autodetect is ran, which seems to cause some errors in the image.
- If something _does_ go haywire with the default image, the system can be restored with the bootable medium made in [**00-installer.md**](./00-installer.md). Mount `/dev/nvme1n1p2` to `/mnt` and subsequently `/dev/nvme1n1p1` to `/mnt/boot`, `artix-chroot`, tweak the config, and regenerate the fallback image.
- To [specify a custom default TTY font](https://wiki.archlinux.org/title/Linux_console#Persistent_configuration), adding the `consolefont` hook after the `modconf` hook will add the configuration specified in `/etc/vconsole.conf` to the image. (`powerline-console-fonts`<sup>AUR</sup> provides some great patched console fonts.)

## Bootloader
_For now, we prefer a minimal grub configuration to make troubleshooting more convenient._

> `sed -i '/OUTPUT/s/^#//' /etc/default/grub && update-grub`  
Enables grub console mode in the config and regenerates it  
_Console mode forces a constant resolution and does not try to hook video modes. In the past, I've found NVidia cards to make grub generally unresponsive in gfxmode; I speculate this is a result of their lack of KMS support._  

## Services
> `rc-update add NetworkManager default`  
Enable the Network Manager service: Required for wireless networking  
_**TODO:** I don't actually know if this is required for wired, however. I only have wireless available to me right now._  

> `rc-update add ntpd default`  
Enable the clock synchronization service: Highly recommended so pacman doesn't start wilding  
_This is the same service we used during [01-base.md](./01-base.md) to ensure the package signing behaves as expected...also having your clock out of sync is just annoying._  

### Additional notes
- All available OpenRC services can be found in the `/etc/init.d` directory. `rc-update add ...` interally creates a symlink between the service file found in the init.d directory and a directory that specifies the target run level.

---

_This portion requires an internet connection, which will be present if the system was not restarted. If it was, temporarily jump to [04-environment.md](./04-environment.md#networking) for networking setup._

## Additional files
It is finally a good opportunity to clone this repo! This is easily the easiest way to obtain the remainder of the configuration/hardware files, rather than retyping them from scratch. We will clone with HTTPS as I don't like to set up an SSH key until the user creation step (in the environment phase.)  
_If I wanted to be really cool, I'd make a script in the repo that automatically installs the system files. However, my configuration is ever changing and evolving and this would certainly prove an impractical solution._  

> git clone https://github.com/Drayux/Catalyst.git /usr/src/catalyst
Clone the repo to the designated source location  
_Note that all files generated will be owned by `root:root`. We explicitly change this at a later point. This caveat works in our favor for system-level files._  

## Pacman
#### **Config directory: [System/Config/Pacman](/System/Config/Pacman)**

### Configuration
In order to keep artix packages and arch/AUR packages seperate, I have a split configuration setup for pacman. `pacman.conf` simply points to the `artix.conf` file which contains the common settings such as the cache directory and parallel downloads. Yay is (will be\*) configured to use the `yay.conf` file which includes `artix.conf` as subsequently specifies the Arch Linux extra repository/mirrorlist as well.  

> `cp -r /usr/src/catalyst/System/Config/Pacman/* /etc`  

### Mirrorlists
Pacman performance can be substantially improved by selecting mirrors that are nearest your machine. This step is not required but it depends upon `rankmirrors (8)` which is provided by the package `pacman-contrib`.

> `rankmirrors -n 5 /etc/pacman.d/mirrorlist > mirrorlist-artix`
Generate a mirrorlist with the five fastest Artix mirrors
_Optionally remove the original mirrorlist with `rm /etc/pacman.d/mirrorlist`._

> `/usr/src/catalyst/System/Scripts/arch-mirror-list.sh`  
Download the official Arch Linux repository mirror list and generate a list of the five fastest mirrors  
_Only United states mirrors are considered. There are **many** mirrors so this command takes a few minutes to run! (Upon testing it took just over 5:30.)_  

### Keyring
Arch packages are signed with a different set of official keys. Those are available in the `archlinux-keyring` package.

> `pacman -S archlinux-keyring`  
_This won't be needed until we refresh our local database, but I like to check this box early._  
