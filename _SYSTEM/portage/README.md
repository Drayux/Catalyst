# Portage Configs
Target directory: `/etc/portage/`

_FOR REFERENCE ONLY_

System packages regularly evolve with time, thus at no point is this configuration guaranteed complete. Occasional snapshots of the portage config state are stored here as a sane starting point; usually a package functioning on my system depends on a certain set of USE flags I'd otherwise have disabled by default.

### `env`

`gcc-build.conf` - Clang is the default toolchain. GCC is for fallback builds, so we drop to -O2 to try to assure stability.

_If my memory serves me right, no packages currently use this. The quickshell fix would have required that libcxx be compiled with GCC which would trigger a rebuild of almost any C++ software on my system._

### `package.accept_keywords` / `package.mask` / `package.use`

_Just making an extra note that these are due for extra cleanup. Refer to my WIP config targets note in obsidian:_ `gentoo-configs`

### `repos.conf/`

These should be set up via the eselect command. This one is particularly for reference.

(_**TODO:** For some point in the future, once I've split this repo into separate subrepos for dotfiles and ebuilds, the `cyberwing` repo can be set up with that as a sync URI._)
