# Hardware configuration
> ### Additional configuration for uncommon hardware support

**\[ [⇽ Previous](./02-config.md) | [Next ⇾](./04-environment.md) \]**  

_As the hardware varies significantly across both machines, this file is formatted slightly differently: The major headers are used to differentiate which hardware configuration is relevant to each system, respectively._  

#### **Repo clone dir indicated as `.../` (`/usr/src/catalyst/` if continuing from [02-config.md](./02-config.md))**

# Common
## DKMS
DKMS stands for "Dynamic Kernel Module Support" and is a toolchain to automate the inclusion of out-of-tree modules (aka kernel-level drivers) in the system. Linux is described as a "monolithic" kernel which mostly refers to how drivers are handled: All Linux drivers (that have succeeded the necessary checks and standards) are compiled directly into the kernel itself. That said, it is not unable to support modules that it does not already include. These modules are built "out-of-tree" against each kernel version. Naturally this can become cumbersome for every kernel update. The role of DKMS is to automate this process.  

> `pacman -S dkms`  

[Arch Wiki - Dynamic Kernel Module Support](https://wiki.archlinux.org/title/Dynamic_Kernel_Module_Support)  

## Bluetooth
Drivers are included in-tree, but a service and userspace tool are necessary to actually use bluetooth. _**TODO:** I'm still having some issues with bluetooth which need to be diagnosed and updated here!_  

> `pacman -S bluez-openrc`  
> `rc-update add bluetoothd default`  
Enable the bluetooth service  
_This is a completely optional component, as bluetooth support is not at all required for a functional desktop._  

[Arch Wiki - Bluetooth](https://wiki.archlinux.org/title/Bluetooth)  

### Userspace front-end
**TODO:** Currently set on using `gnome-bluetooth-3.0` but I haven't actually done any real bluetooth setup yet.  

## Networking Extras
### `wireless-regdb`
Optional additional package with configuration regarding regional bandwidth regulations. _**TODO:** Admittedly I don't know much about how this works, but supposedly it's necessary to get the full connection speed out of Wifi 6 stuff? I additionally do not know if this is configured automatically or not._  

[Arch Wiki - Wireless](https://wiki.archlinux.org/title/Network_configuration/Wireless#Respecting_the_regulatory_domain)  

## Monitor Firmware (EDID)
**TODO:** Not sure what I'm doing yet! I've attempted to create a custom EDID for my MacBook display to remove the 2800x1800 entry, and even booting with the new 2560x1600 firmware confirmed to have been loaded, the TTY uses the oversized resolution anyway.  

The current EDID (provided by the GPU) can be found in `/sys/class/drm/*/edid` **if available**. _Some monitors will not provide one at all._  

Specify an EDID firmware override with the kernel parameter `drm.edid_firmware=...`. The binary path is relative to `/usr/lib/firmware` and the optional video parameter (`[video:]<path>`) can be determined by running: `for p in /sys/class/drm/*/status; do con=${p%/status}; echo -n "${con#*/card?-}: "; cat $p; done`.  

[Arch Wiki - Kernel Mode Setting](https://wiki.archlinux.org/title/Kernel_mode_setting#Forcing_modes_and_EDID)  

### Utility programs
[EDID Binary Decoding Utility (`edid-decode`)](https://github.com/a1ive/edid-decode)  
[EDID Generator Utility (`edid-generator`; Depends on `edid-decode` and `dosfstools`)](https://github.com/akatrevorjay/edid-generator)  

The generator is a bit unwieldy. First create an Xorg.conf modeline (there are examples in the repo) alongside the output of `hwinfo --monitor` (requires `hwinfo` to be installed as well) and run it through `modeline2edid`. A new `.S` file with the resolution in the modeline will be created. Ensure `edid-decode` is on the PATH and compile it with `make`.  

## Power Management (TLP)
The Linux kernel provides numerous options--set during runlevel 3 (aka the default multi-user mode)--that control its behavior and the subsequent behavior of the managed devices. Many of these options will affect the power consumption of the system, with a notable example being CPU frequency scaling. The role of TLP is to abstract the task of setting these options, as the location of these options depends on the system configuration (such as the connected hardware) and because they are not preserved across subsequent boots.

> `pacman -S tlp-openrc`  
> `rc-update add tlp default`  
Enable the power management service  
_This is an optional component, though its absence is immediately apparent in laptops, which will run unusually hot even at idle._  

[TLP Introduction](https://linrunner.de/tlp/introduction.html)  

### Configuration
> **CHITIN ONLY**  

> `micro /etc/tlp.conf`  

    > +   | USB_DENYLIST="05ac:8600"
Explicitly prevent the iBridge from autosuspending, consistent with `usbhid` devices.  
_**TODO:** This technically may not be necessary as the iBridge is an HID device. That said, it requires an additional platform module to function, and therefore might act up. Adding this rule enforces the expected autosuspend policy._  

## Swapfile
_This procedure applies to either system...although with 128GB of memory in Catalyst, I skip this step on that machine._  

> `dd if=/dev/zero of=/mnt/swap bs=1M count=8196`  
Create empty 8GiB file at `/mnt/swap`  
_Change `count` to specify an alternative size._  

> `chmod 600 /mnt/swap`  
Set read/write permissions for owner only (aka root)  

> `mkswap /mnt/swap`  
Convert the `/mnt/swap` into a swapfile  

> `echo '/mnt/swap	none	swap	sw	0 0' >> /etc/fstab`  
Add the swapfile to the filesystem table so that it is mounted on system boot  
_Can be tested with `mount -a && swapon -a`._

# Desktop (`catalyst`)
## Razer Tartarus V2 Keypad
The Razer Tartarus V2 is a gaming-focused perhipheral that improves upon the keyboard/mouse input format by offering a one-handed keypad with improved ergonomics and supplemental keymapping features. The curse of this device is that its advanced functionality depends upon a userspace tool with exclusive Winows support. `Tartarus` is a kernel-space device driver that restores this configurability, customizable via the provided "Linapse" python script. This module is built out-of-tree and therefore depends on DKMS.  

> `git clone https://github.com/Drayux/Tartarus.git /usr/src/tartarus-0.1`  
> `sudo dkms install -m tartarus -v 0.1`  
Build and install the `tartarus` module with DKMS  
_The linapse tool will can be moved from /usr/src/tartarus-0.1 to an arbitrary location, as it uses sysfs to communicate with the device._  

[Github - Tartarus](https://github.com/Drayux/Tartarus)  

## Focusrite Scarlett 18i20 Audio Interface
Akin to standard programs, kernel modules can additionally accept parameters that impact their behavior at runtime. The Focusrite Scarlett 18i20 is supported by the `snd_usb_audio` module but it needs the `device_setup` parameter to function properly.  

### Set modprobe parameters
> `micro /etc/modprobe.d/scarlett.conf`  

    > +   | options	snd_usb_audio vid=0x1235 pid=0x8215 device_setup=1
_Note that `options` is followed by a tab character._  

# Macbook (`chitin`)
## Broadcomm Wireless Adapter
Out of the box, the wireless adapter _mostly_ works. However on some networks (notably newer ones featuring Wifi 6 access points) I was continuously presented with the error: 

    > Error: Connection activation failed: (7) Secrets were required, but not provided

This issue was resolved with the additional firmware context found in [brcmfmac43602-pcie.txt](/System/Firmware/brcmfmac43602-pcie.txt).  

> `cp .../System/Firmware/brcmfmac43602-pcie.txt /usr/lib/firmware/brcm`   
Places the firmware parameters file into the system firmware directory  

[Macbook Pro POP_OS](https://github.com/Cliffback/POP_OS_22.04-mbp-2016)  

## Cirrus Audio
The Macbook's Cirrus 8409 HDA audio chip does not have an in-tree module, so it is necessary to build one from source. This patch seems to require DKMS despite not appearing to work with DKMS properly.  

_**TODO:** Currently, this module is a kernel patch and needs to be manually rebuilt upon every kernel update. At some point, I hope to refactor the source into a dedicated module that can be installed with DKMS and forgotten about._  

Currently, the system needs to be restarted to observe the functional audio, though this could be as simple as restarting the sound server. (I've done minimal testing so far.)  

> `git clone https://github.com/davidjo/snd_hda_macbookpro.git /usr/src`  
> `/usr/src/snd_hda_macbookpro/install.cirrus.driver.sh`  
Install the Cirrus HDA module with the included script  

[Github - snd_hda_macbookpro](https://github.com/davidjo/snd_hda_macbookpro)  

## Apple SPI (keyboard and touchpad)
As of kernel version 5.3, the `applespi` module is included in-tree, requiring no additional steps. This is the module responsible for the functionality of the keyboard and trackpad.  

[Kernel Source Tree - applespi.c](https://elixir.bootlin.com/linux/latest/source/drivers/input/keyboard/applespi.c)  

### Libinput local overrides
Optionally, the touchpad behavior can be configured through `libinput` with the local overrides file.  
_**TODO:** I haven't tweaked this yet._  

> `micro /usr/share/libinput/local-overrides.quirks`  

    > +   | [Apple Laptop Touchpad (SPI)]       # possibly [...(SPI) applespi driver] instead
    > +   | MatchUdevType=touchpad
    > +   | MatchBus=spi
    > +   | MatchVendor=0x05AC                  # possibly 0x06CB instead
    > +   | ModelAppleTouchpad=1
    > +   | AttrSizeHint=104x75
    > +   | AttrTouchSizeRange=150:130
    > +   | AttrPalmSizeThreshold=1600
The values here are the current defaults provided by libinput (found in `/usr/share/libinput/50-system-apple.quirks`)  

### Backlight brightness
The keyboard backlight can be controlled with the sysfs entry: `/sys/bus/spi/drivers/applespi/spi-APP000D\:00/leds/spi\:\:kbd_backlight/brightness`  
_A sane default is set at boot via a [custom OpenRC service](#configuration-service)._  

## Apple iBridge (touchbar, light sensor(/maybe fingerprint sensor), and webcam)
Getting the touchbar to work was one of the most difficult parts of the Artixbook setup, as it required the most manual intervention.  

The iBridge is a T1 chip that is visible to the kernel as an HID device. It exposes four interfaces, each of which are different devices, which demand different drivers. The `apple-ibridge` module is a muxing module, connecting the interfaces to their own platform modules (specifically `apple-ib-tb` for the touchbar, and `apple-ib-als` for the ambient light sensor.)  

The applespi fork that includes the touchbar driver (by Roadrunner) provides functional modules, but does not immediately build as a result of changes to the kernel API. Further, it includes the `applespi` module which is no longer necessary to build. Included in this repo, [apple-ib-0.1](/System/Firmware/apple-ib-0.1) is a tweaked version of a fork to the Roadrunner repo that excludes `applespi` and updates the DKMS config accordingly. It builds as of kernel 6.7.5.  

> `cp -r .../System/Firmware/apple-ib-0.1 /usr/src`  
> `dkms install -m apple-ib -v 0.1`  
Install the iBridge (+touchbar and als) modules with DKMS  
_If all was successful, the touchbar should turn on immediately upon running `modprobe apple-ib-tb`._  

[Applespi Fork with Touchbar Driver](https://github.com/roadrunner2/macbook12-spi-driver)  
[Touchbar Driver Fork with 5.18 Kernel Support](https://github.com/BrianValente/macbook12-spi-driver/tree/touchbar-driver-hid-driver)  
[iBridge Module Overview](https://github.com/roadrunner2/macbook12-spi-driver/blob/touchbar-driver-hid-driver/apple-ibridge.c#L11)  
[Touchbar Issue Report](https://github.com/roadrunner2/macbook12-spi-driver/issues/42#issuecomment-602160740)  
[usbmuxd Incompatibility](https://github.com/libimobiledevice/usbmuxd/issues/138)  

### Libinput local overrides
> `micro /usr/share/libinput/local-overrides.quirks`  

    > +   | [MacBookPro Touchbar]
    > +   | MatchBus=usb
    > +   | MatchVendor=0x05AC
    > +   | MatchProduct=0x8600
    > +   | AttrKeyboardIntegration=internal

### Usbmuxd configuration
Currently, `usbmuxd` believes it necessary to hook _every_ Apple USB device, which includes the iBridge. This unbinds the iBridge module when the udev rule is ran, which prevents the touchbar from functioning. This can be fixed by removing the VID:PID match in `/usr/lib/rules.d/39-usbmuxd.rules`: `|5ac/8600/*` (which corresponds to 05AC:8600.)  
_This match is present four times in the file._  

> `cp .../System/Config/Devices/39-usbmuxd.rules /usr/lib/rules.d/`  
Overwrite the existing udev rule  

### Touchbar function mode
The touchbar function state can be changed with the sysfs entry: `/sys/bus/hid/drivers/apple-ibridge-hid/0003:05AC:8600:0001/fnmode`.  
_Interface two is the ambient light sensor._  

    > 0 ➤ "Disable" the <fn> key; Touchbar will display only function buttons
    > 1 ➤ Touchbar defaults to utility keys; Holding <fn> will display function buttons
    > 2 ➤ Touchbar defaults to function keys; Holding <fn> will display utility buttons
    > 3 ➤ "Disable" the <fn> key; Touchbar will display only utility buttons
_I set this to my preference of `mode 2` in [custom OpenRC service](#configuration-service)._  

## Apple Firmware
In order for the iBridge to initalize properly, Apple's propreitary EFI loader (somewhat the equivalent to the BIOS on a traditional desktop) first loads firmware from the ESP partition. **This is why it is important not to overwrite the existing partition table!**  

Alas, if you're like me, you saw this memo after wiping the partition table and are short on some firmware. I have put my firmware into this repo under the [apple-efi](/System/Firmware/apple-efi) directory...probably breaking many rules. That said, fuck em. It's staying here until I get reprimanded. **This firmware is for my 14,2 Macbook Pro.** I have no clue if it will work on your system. The "proper" way to obtain the firmware for _your_ system is detailed [below](#recovery-mode).  

To use the included firmware, the sub-tree of `apple-efi` should be placed into the `EFI` directory in the ESP partition (i.e. `/boot/EFI/<APPLE/...>`.)  

System sleep is another thing of note: Currently suspend seems fully functional, with the strange caveat that waking from sleep takes nearly two minutes. The device is otherwise responsive, too. Hibernate does _not_ seem to work out of the box.  

### Configuration service
Many sensible defaults or otherwise preferable hardware settings on the laptop are managed via sysfs entries, and are not preserved across boots. The [appleconf](/System/Config/Services/appleconf) service is a custom OpenRC service which applies some more desirable parameters on boot.  

> `cp .../System/Config/Services/appleconf /etc/init.d/`  
> `rc-update add appleconf default`  
Install and enable the custom `appleconf` service  

### Backlight brightness
The display backlight brightness can be modified with the sysfs entry: `/sys/class/backlight/acpi_video0/brightness`. Setting this to 90 appears to be the maximum, and 0 completely turns off the display.  
_This is set to a medium-low brightness of 25 in [custom OpenRC service](#configuration-service)._ 

[Arch Wiki - Backlight](https://wiki.archlinux.org/title/Backlight#ACPI)  

### Recovery mode
_**TODO:** I need to make this more verbose, my memory is a bit foggy on the exact process but it's relatively intuitve._
- Reboot the device and hold `Option + R`
- _This functionality is always available with the onboard EFI firmware (aka the "BIOS".)_
- Select Recovery Mode with Internet
- Connect to a wireless network
- Use the disk management option and wipe your drive
- Use the freed space to perform a fresh install of Mac OS
- _This will boot you into the new install._
- Upon completion, the device can be shut down and Linux reinstalled
- _**This time, use extra caution to format only the partition to which OSX is installed.**_

### Additional resources
The Linux on Macbook project has a number of extraordinarily benefical resources from other enthusiasts. Unfortuantely some of the information is out of date and finding the information you need can require a great deal of sifting and a decent comprehension of the inner-workings of Linux. That said, most answers can be found through some combination of the following:  

[State of Linux on the MacBook Pro - Github](https://github.com/Dunedan/mbp-2016-linux)  
[Linux on MBP (Late 2016)](https://gist.github.com/roadrunner2/1289542a748d9a104e7baec6a92f9cd7)  
[t2linux Wiki](https://wiki.t2linux.org/)  
