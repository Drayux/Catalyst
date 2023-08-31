### [Pacman Man Page](https://man.archlinux.org/man/pacman.8)

# Setup
### Adding package repositories
From the [Arch Wiki](https://wiki.archlinux.org/title/Official_repositories#multilib)  
Located inside of `/etc/pacman.conf`:  
```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

### **TODO:** Set up cache auto-maintenance
Ideally, determine if it is possible to specify that pacman should cache only the newest two revisions of a package per package (the one just downloaded for the upgrade, and the one that was just upgraded.) This would still allow for maintenance backups, but will prevent the user from needing to clean the cache as part of routine system maintenance.  

# Modes (an overview)
## Sync ( `-S` )
Any parameter following the `-S` flag will apply to the sync mode:  
Meaning that the command will operate from/on the public repositories.  

**`-s` -> Search**  
This will search for packages amongst the publicly-available ones (the typical use case here is seeking packages _to_ install.)  

**`-i` -> Info**  
This will provide the metadata of a package--notably, all of its dependencies across the entire public repositories will be listed.  

## Query ( `-Q` )
Any parameter following the `-Q` flag will apply to the query mode:  
Meaning that the command will operate from/on locally-installed packages. 

**`-s` -> Search**  
This will search for packages amongst the locally-installed ones (so that the result returned will only ever be packages that are already installed.)  

**`-i` -> Info**  
This will provide the metadata of a package--notably, only its dependencies also installed on the system will be listed.  

**`-n` _versus_ `-m`**  
When querying packages, their origin can be inspected as well.  
Use `-n` to specify that we are interested in _native_ packages, and `-m` to specify _non-native_ packages (i.e. AUR.)  

# Tips and Tricks
### "Proper" way to upgrade packages
	pacman -Syu

Installing packages with just `-Su` for example, may attempt to install an out-of-date package, which can quickly become problematic. Avoid this unless absolutely necessary!  

### "Proper" way to remove a package
	pacman -Rs

Similarly to upgrading packages (but with much less severe implications) removing a package with just `-R` will leave its dependencies untouched, which can abandon packages installed as a sole dependency of the installed package, consuming unnecessary disk space.  

Further, the `-n` flag can be specified to additionally remove application config files. (_**TODO:**_ Needs verification)  

### Refresh the database cache
	pacman -Syy

Sometimes the database cache can be finnicky and have corrupt links to packages (this notably happened for me once while trying to install `meson`.) A good first step in troubleshooting this is to _force_ a cache refresh with the above command.  

### List just package names (excluding versions)
	pacman -Qq

### List package dependencies *and* depends
	pacman -Qii

Quite literally expands to `pacman -Q --info --info`. The second info parameter suggests that it should output an additional "layer" of package metadata.  
_On further inspection, it seems that this may no longer be necessary?_  

### Ignore a package upgrade
When upgrading packages, the `--ignore=` flag can be specified to skip problematic packages. Notably, this has been of signifcant use when there were kernel bugs that had not been patched for a few versions. For example:  

	pacman -Syu --ignore=linux,linux-headers

### Clean up orphans
Taken directly from the [Arch Wiki](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Removing_unused_packages_(orphans))  

	pacman -Qqdt | pacman -Rns -

Optionally, `-Qqdtt` can be specified instead to also remove extraneous optional dependencies.

### Clearning the cache
By default, pacman will store every downloaded package in `/var/cache/pacman/pkg/` which can begin to quickly fill disk space with respect to the nature of rolling release.  

Simply delete the contents of this folder periodically to save on the storage space.  

This can also be done with the command:

	pacman -Scc

### Specify that a package should be installed as a dependency
In the case of building a package from source, it may be necessary to manually install some of its dependencies. A potential beneficial practice is to specify that this package is a dependency (aka not explicitly installed) such that it can be removed when pruning orphaned packages.  

	pacman -S --asdeps <package>
	
Alternatively, the `--asexplicit` flag can be used to force the opposite.  

This can also be applied to packages that are already installed:

	pacman -D --asexplicit <packages>

### Find which package to which a file belongs
**Locally Installed**  

	pacman -Qo <path/to/package>

**Global Database Search**  

	pacman -Fy <path/to/package>

### Show the files associated with a given (installed) package

	pacman -Ql <package>

### Read list of packages (upon which to operate) from stdin
	pacman <operation> -

For example to install packages from a list in a file:  

	cat packages.txt | pacman -S -

### Install a local package
	pacman -U <path/to/package>

### _**TODO:**_ Mark a package as installed
If I have to manually install what a package should provide, there should exist a way to specify to pacman that the binaries necessary to satisfy a package that depends on it are available on the system.  

# Commands from [pacman-contrib](https://archlinux.org/packages/extra/x86_64/pacman-contrib/)
Pacman-contrib [GitLab Repository](https://gitlab.archlinux.org/pacman/pacman-contrib)  

### paccache
Utility for managing the pacman cache  
_**TODO:**_ Look into available functionality and document it here  

### pactree
Outputs a pretty (visual) package dependency tree

# Additional Resources
### AUR Helper
I personally prefer `yay` as my AUR helper of choice. See the install notes in `../Build/yay/`  
