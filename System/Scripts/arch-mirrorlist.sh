#!/bin/sh
# Download the Arch Linux mirrorlist and rank the results
# NOTE: There's a lot of mirrors so ranking takes time!

# TODO: This would be nice to have a few parameters like Artix/Arch mirrors and the output destination

curl https://gitlab.archlinux.org/archlinux/packaging/packages/pacman-mirrorlist/-/raw/main/mirrorlist -o /tmp/mirrorlist-arch

echo "Testing mirrors (this will take a few minutes!)"
awk '/## United States/{f=1;next}/^$/{f=0}f' /tmp/mirrorlist-arch | sed -e '/Server/s/^#//g' | rankmirrors -n 5 -r extra - > /etc/pacman.d/mirrorlist-arch
echo "Done!"
