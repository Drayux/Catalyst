# Dracut configs
Target directory: `/etc/dracut.conf.d/`

### `uki.conf`

A half gig of extra boot partition space is inconsequential on my system. This has the added effect of allowing me to build a UKI, which I find much cleaner and easier to audit.

_NOTE: Creating the UKI image requires additional configuration in `/usr/lib/kernel/install.conf` but this is handled by the `installkernel` package when the `uki` USE flag is provided, so no additional action is necessary here._
