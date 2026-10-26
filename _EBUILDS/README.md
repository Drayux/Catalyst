# PORTAGE EBUILDS

~~TODO: I gotta write up how to use these; they're not just drag-and-drop.~~  
^^ _Since improved slightly, now the ebuilds are the "correct" structure, but
the root dir still can't quite be linked directly. Link each package category
instead._

TLDR: Use `equery select` to create a new repository, I've named mine
cyberwing _"for all cyberwing ebuilds."_ Then you'll get a structure in the
repositories database: `/var/db/repos/cyberwing/`. This directory is the root
of an ebuilds repo, so now all the contents are `directory/subdirectory`
matching the name of a package atom. I.E. `app-misc/neofetch`.

Within the subdirectory, include the `.ebuild` file for that package.  

Additionally, a `files` directory may be provided for patches that should come
by default with the package. (My dracut config includes this. Also worth note
is that multiple patches can be included, I've just opted to merge all five
patches into one file so it's easier to install via commandline.)

Also, for something like dracut, since the goal is to allow for an otherwise
antiquated version, it's important to mask `>sys-kernel/dracut-106-r2` in
`/etc/portage/package.mask` so that it doesn't get updated automatically.

### EBUILDS to make

- kacau-wall (maybe -- I like it quite a bit but it's vibe-coded as fuck)
  [Codeberg](https://codeberg.org/touto/kacau/src/branch/master/apps/kacau-wall)
- overlayfs-tools (super clutch for the overlay setup, might as well make a package to get it system-wide)
  [GitHub](https://github.com/kmxz/overlayfs-tools)
- Katana (and also maybe contribute one for the OG libresplit to be a G, since it'll be similar)
  [GitHub](https://github.com/Drayux/Katana)
