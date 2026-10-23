# PORTAGE EBUILDS

TODO: I gotta write up how to use these; they're not just drag-and-drop.

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
