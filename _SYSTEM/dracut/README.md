# Dracut configs

### `configs/`
Target directory: `/etc/dracut.conf.d/`

#### `rootfs-overlay.conf`

Extra drop-in config to enable my custom overaly module. (See `dracut/modules/`)

#### `uki.conf`

A half gig of extra boot partition space is inconsequential on my system. This has the added effect of allowing me to build a UKI, which I find much cleaner and easier to audit.

_NOTE: Creating the UKI image requires additional configuration in `/usr/lib/kernel/install.conf` but this is handled by the `installkernel` package when the `uki` USE flag is provided, so no additional action is necessary here._

Note that UKI generation appears broken on any version greater than 106-r2 right now. Refer to the dracut ebuild in `EBUILDS/` for details on installation.

### `modules/`
Target directory: `/usr/lib/dracut/modules.d/`

Pairs with the custom GRUB configs to read in the `fsmode` parameter passed to the kernel at boot to determine the mounting rules for `/dev/nvme1n1p3`.

**Important installation step:** I have deferred the logic of performing the overlayfs merge to the program [overlayfs-utils -- GitHub](https://github.com/kmxz/overlayfs-tools) to seek to avoid challenges that may be subtly introduced as a result of my naivity. I'd love my script to "neatly do it all in one package" but in the interim, this seems the best solution.

As the target is a compiled binary, I have not included it here. As of writing this, I cloned and compiled commit `950d0cf` and simply copied the executable to `.../modules.d/99rootfs-overlay/overlayfs-tools`. This must be present in order for the module configuration to be correctly assembled.
