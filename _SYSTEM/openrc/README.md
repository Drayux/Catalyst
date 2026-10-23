# OpenRC config
Target directory: `/etc/conf.d`

Note that this config merges with any number of defaults already present in this directory.

### `bootmisc`

Found this one out of curiousity. Since catalyst uses tmpfs for tmp partitions, cleaning it first is an extraneous operation.

### `display-manager`

Simple configuration setting for the `display-manager` target to know which well-known display manager executable to run. (Interally it's just fed to a bash switch statement.)

### `net`

Configures wired networking. Obviously, this needs to be changed to match your network topography or otherwise omitted for systems that will roam networks.
