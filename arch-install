Relatively comprehensive list of instructions used to get arch to its (probably) current state
This includes all the major steps to get to the same configuration, but less so the specific setup 
(so installing steam would not be included here, for example)


Not sure where to put this yet:
  Pacman recursive remove: pacman -Rscnd [package] <-- dangerous


Arch things TODO:
  > Customize GRUB menu names
      - Potentially specify where to check for windows and disable os-prober (for easily updating the config)
  > Desktop Environment! (preferably with Wayland instead of X11)
  > Get pipewire (and necessary utilities like alsa?, jack?, wireplumber?) installed
  > Fancy loading screen during boot (mpv?)
  > Troubleshoot: dhcpcd seems to stop randomly?


---------------
Base Install:
Follow the tutorial at https://youtube.be/DPLnBPM3DhI



During filesystem setup, LVM is now 43
Only create one partition within the LVM, format XFS instead of EXT4
^^use for root system/home both (mount at root)
Use 8196 byte block sizes (instead of 1M??)

Useful disk stuff:
fdisk --list	:   Lists all drives and info
blkid		:   Lists all partitions (and their UUIDs)
mount -a	:   Mounts everything in the fstab file as configured

fstab located in /etc/fstab


To "get in to arch" (also useful for recovery with the bootable USB):
Mount the drive containing arch (currently: mount /dev/nvme0n1p2 /mnt)
Change root into mounted drive (arch-chroot /mnt)



Kernel install:
  linux (+ linux-headers)
* linux-zen (+linux-zen-headers)

Kernel config at /usr/src/[kernel]/.config



Additional packages (as listed in video):
nano base-devel openssh dialog* lvm2 amd-ucode*
*might not be necessary (for future installs)

Additional packages (for later configuration):
zsh screen linux-firmware man man-pages opengl-man-pages
^^and then run 'chsh -s /bin/zsh'


Network packages (ignore packages specified in video):
iwd dhcpcd

(IWD is my favorite config tool so far, dhcpcd was missing, but necessary to run wireless)
After booting into arch (later):
  > Enable services (systemctl enable iwd.service && systemctl enable dhcpcd.service) 

dhcpcd config located in /etc/dhcpcd.conf
^^Ensure file does not contain 'noipv4ll' flag


Graphics Driver Base Setup:
^^not in video, but this order makes more sense

Follow instructions at https://wiki.archlinux.org/title/NVIDIA - (#Custom Kernel, #DRM kernel mode setting)

Install package nvidia-dkms (pacman -S nvidia-dkms)
Check for kernel config flags (CONFIG_DRM_SIMPLEDRM=y CONFIG_DEBUG_INFO_BTF) [in /usr/src/linux-zen/.config]
Run install command if latter flag (install -Dt "$builddir/tools/bpf/resolve_btfids" /usr/src/[kernel]/tools/resolve_btfids/resolve_btfids)
^^[kernel] currently refers to linux-zen

Create pacman hook (for module early loading):
^^this will trigger 'mkinitcpio -P' automatically everytime there is an update for the nvidia drivers
Hook located at /etc/pacman.d/hooks/nvidia.hook
(use text file specified on webpage)
  >+ Target=nvidia-dkms
  >- Target=linux
  >- NeedsTargets
  >~ Exec=/usr/bin/mkinitcpio -P



Configure init scripts (I think?):
mkinitcpio located in /etc/mkinitcpio.conf

Add 'lvm2' to HOOKS (between block and filesystems)
Add 'nvidia nvidia_modeset nvidia_uvm nvidia_drm' to MODULES (default config is empty)
^^enables early loading of drivers (makes boot feel faster) [NOTE: Doing so requires the above step!]

Generate scripts (mkinitcpio -p linux) / (mkinitcpio -p linux-zen)
^^I'm pretty sure that 'mkinitcpio -P' will just run it for both automagically



User creation:
Set root password (passwd)
Create a personal group with groupadd (currently 'dragon')
Create personal account (useradd -d /home -s /usr/bin/zsh -g dragon -G wheel drayux)
^^creates home directory in /home (great if only user on system), sets shell to zsh
To remove user password run 'passwd -d drayux'



GRUB2 install:
Packages: grub efibootmgr os-prober dosfstools* mtools* ntfs-3g*
*may not be necessary for a pure linux install (but definitely if windows is on the system)

GRUB user config in /etc/default/grub
GRUB generated config in /boot/grub/grub.cfg
^^generate config with 'grub-mkconfig -o /boot/grub/grub.cfg'

Config modifications:
GRUB_DEFAULT=saved
*GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 splash nvidia-drm.modeset=1"
^^splash optional...might not work without additional configuration (but removing quiet shows the cool messages on boot)
^^previously NVidia DRM mode seemed to mess with the TTY resoltion, however it appears to work fine alongside the GFXPAYLOAD flag (also required for the window manager)

GRUB_TERMINAL_INPUT=console
GRUB_TERMINAL_OUTPUT=console
*GRUB_GFXMODE=1280x720x32,auto
^^does not work with output set to console

GRUB_GFXPAYLOAD_LINUX=3440x1440x32
^^usually 'keep' but this forces the correct resolution when grub is ran in console mode (gtx mode too slow at this resolution)

*GRUB_COLOR_NORMAL="light-cyan/black"
*GRUB_COLOR_HIGHLIGHT="light-cyan/dark-gray"
^^also only works in gtx mode (not console mode) but looks really cool if you go that route and don't want a theme

GRUB_DISABLE_OS_PROBER=false
^^only really necessary for dual-boot

For Windows to be detected:
Ensure os-prober is installed and enabled (and ntfs-3g)
Mount windows EFI partition (currently /mnt/windowsEFI)
Run grub-mkconfig

To determine supported video modes:
Launch into GRUB
Press 'c' (before the menu timer expires)
Run 'videoinfo'
^^supposedly 'hwinfo --framebuffer' from inside arch works as well....it worked once and not again and so I'm unsure (guessing I had drm mode on the first time I ran it)



-- ARCH CAN BE REBOOTED NOW --



Configure Network:
Useful IWD commands:
List devices	:   device list
Scan LAN	:   station [interface (currently wlan0)] scan
Results of ^^	:   station [interface] get-networks
Connect to LAN	:   station [interface] connect "[network name]"

Full CLI example (iwd --passphrase=7205159043 station wlan0 connect "16144 WiFi")
Show connection info (ip addr)
Test connection (ping -c 4 8.8.8.8)
^^pings Google's primary DNS server



*Create SWAP file:
Create empty file (dd if=/dev/zero of=/mnt/swap bs=1M count=8196)
^^8196 * 1M = 8GiB; Swapfile cannot be put into /dev lmao
Change permissions (chmod 600 /mnt/swap)
Convert to swapfile (mkswap /mnt/swap)
Add to fstab configuration (nano /etc/fstab)
  >+ /mnt/swap   none   swap   sw   0 0
Can be tested with (mount -a && swapon -a)
---------------



---------------
Desktop Environment (and simliar services):
Packages: wayland xorg-xwayland wayland-docs* wayland-utils* glfw-wayland*

Reference of components:
Display Server	:   Server (kinda like pulseaudio for GUIs) that handles GUI I/O and events (such as clicking the mouse)
			^^Necessary for any desktop environment; Options are Xorg (on the X11 protocol) and Wayland
Window Manager	:   Software that handles the placement and appearance of application windows
			^^Can run standalone alongside a display server, though many require session/launcher applications
** Compositor	:   A type of Window Manager that introduces an API enabling 2D and 3D effects, transparency, animation, etc.
			^^All Wayland Window Managers are *also* compositors (aka Compositing Window Managers)
Display Manager	:   Basically a login screen that automates the process of starting the window manager (and display server) after a successful login
			^^Somewhat akin to how grub can support a GFX mode without the OS being initalized yet
Desktop Env.	:   A composite of any of the following software
			- Window Manager
			- Display Manager
			- Interface Applications (such as a dock, taskbar, or titlebar)
			- Standard Applications (like calculator, settings, etc.)


-- TODO: THIS WILL BE DIFFERENT --
Custom Desktop Environment Config:
Display Server - Wayland (configure by setting EnableWayland=true in /run/gdm/custom.conf)
~~Window Manager - Mutter (paired with gnome-shell/gnome-session and handled by GDM)
Better Window Manager - KWin
Launcher/Desktop - Gnome Shell

Start desktop environment (from this point in the install) with 'gnome-shell --wayland'
To change configuration, run 'systemctl restart gdm'

TODO: Set up DE scripts
  > Allow for launch (from GDM) either in Wayland or X11
  > When logging in as root, disable the Display server and run as a TTY (and re-enable on log out)



Audio Config:
Packages: pipewire pipewire-docs wireplumber
