# Customization
adobe-source-code-pro-fonts* (inspect provided fonts for explicit install)
cantarell-fonts* (inspect provided fonts for explicit install)
cmatrix
gnu-free-fonts* (inspect provided fonts for explicit install)
~~latte-dock~~ (only install if reverting to KDE)
neofetch
~~nerd-fonts-complete~~ (AUR ; Appears to have been moved to main repo under different packaging)
noto-fonts* (inspect provided fonts for explicit install)
noto-fonts-emoji* (inspect provided fonts for explicit install)
noto-fonts-extra* (inspect provided fonts for explicit install)


# Applications
alacritty
alsa-scarlett-gui
ark* (consider alternatives moving away from KDE)
bitwarden
carla
cider* (AUR ; probably keep but I am eventually moving away from apple music probably)
davinci-resolve (AUR)
discord* (consider vencord as an alternative)
dolphin* (consider alternatives moving away from KDE)
dolphin-plugins* (touche^^)
electron
firefox* (consider firefox-appmenu-bin, though this is likely irrelevant w/out an app menu)
flameshot* (was acting up in KDE, but no superior alternives currently appear to exist)
gimp
godot
~~gwenview~~ (likely only install alongside KDE)
inkscape
kinfocenter* (probably unnecessary, but a tempting little utility that doesn't seem to require the rest of KDE)
lact* (AUR ; might depend on systemd resources)
pavucontrol* (useful for enumerating audio devices and specifying the default, though this can be done with pipewire cli)
~~plasma-desktop~~ (moving away from KDE)
~~plasma-systemmonitor~~ (very cool "task manager" I didn't know existed ; still likely avoid if not on kde)
~~plasma-wayland-protocols~~ (install if using KDE)
~~plasma-wayland-session~~ (install if using KDE)
prismlauncher-qt5-bin* (AUR ; consider qt6 alternatives)
protontricks (AUR)


# System
alsa-lib
alsa-utils*
amd-ucode
base-devel
base
cmake
coreutils
curl
dkms
dosfstools
ffmpeg-obs (AUR ; consider install as dependency)
gdb
gdbm
git
glu
gptfdisk* (not sure if I need this but gonna mark it just in case)
graphviz*
grub
hidapi* (not necessary for explicit, it will likely be useful for my tartarus project)
imagemagick* (optional for neofetch)
iniparser* (not necessary for explicit, might be useful for a future project)
iwd* (originally wireless_tools, then iw, consider exploring iwd as it supposedly replaces network manager as well?)
jre-openjdk
jre17-openjdk (for minecraft lmaooo)
ladspa
less
libdatachannel* (AUR ; originally explicit, may not be necessary for build of OBS)
liblivesplit-core (necessary for a variety of timers)
~~liblrdf~~ (originally explicit, unsure of use case)
librist* (AUR ; originally explicit, seems necessary for build of OBS)
~~libtool~~ (originally explicit, unsure of use case)
~~libuiohook~~ (originally explicit, unsure of use case)
libusb-compat (necessary for build of ITGMania, install as dependency)
libva-mesa-driver (optional but likely enables GPU acceleration in OBS and similar software)
libyaml* (not necessary for explicit, might be useful for a future project)
linux
linux-api-headers (originally as dependency, certainly useful for future projects)
linux-firmware
linux-headers
lua
luajit
lv2
lz4 (optional for mkiniticpio)
man-db
man-pages
md4c* (originall as dependency, might be useful for future projects)
mesa
mesa-utils* (likely not necessary for explicit)
mesa-vdpau (optional for mesa)
meson
micro
mkinitcpio
mtools
~~networkmanager~~ (unusure if this is necessary alongside iwd)
~~networkmanager-qt~~ (unusure if this is necessary alongside iwd)
nlohmann-json (install as dependency ; required for build of OBS)
ninja
nodejs
npm (optional for nodejs)
ntfs-3g
opencl-amd (AUR)
openssh
pacman-contrib (optional for pacman ; originally installed for pactree functionality)
parted
perl (will be included as dep of base-devel ; set to explicit install)
pipewire
pipewire-alsa* (determine for sure if I need this before installing)
pipewire-audio (optional for pipewire)
pipewire-docs (optional for pipewire)
pipewire-jack (optional for pipewire)
pipewire-pulse (optional for pipewire ; hopefully there is a replacement for the systemd dependency)
~~pkgconf~~ (explicit install, unsure of use case)
python
python-appdirs* (originally a dep for inkscape, might be useful in a future project)
python-cffi* (originally a dep for something, might be useful in a future project)
python-gobject* (originally a dep for inkscape, might be useful in a future project)
python-matplotlib
python-numpy
python-packaging
python-pillow
~~python-platformdirs~~ (sounds the same as `python-appdirs` but a different package?)
python-psycopg2* (might be useful for a future project)



python-pyalsa
python-pycparser
python-pydantic
python-pyliblo
python-pyparsing
python-pyqt5
python-pyqt5-sip
python-pyserial
python-pyudev
python-rdflib
python-requests
python-scipy
python-setuptools
python-six
python-soupsieve
python-tomli
python-tqdm
python-trove-classifiers
python-typing_extensions
python-urllib3
python-validate-pyproject
python-vdf
python-zstandard
~~qalculate-qt~~ (explore alternatives, this interface is unwieldy)
qca-qt5
qhull
qpdf
qpwgraph
qqc2-desktop-style
qrencode
qt5-base
qt5-declarative
qt5-graphicaleffects
qt5-imageformats
qt5-location
qt5-multimedia
qt5-quickcontrols
qt5-quickcontrols2
qt5-sensors
qt5-speech
qt5-svg
qt5-tools
qt5-translations
qt5-wayland
qt5-webchannel
qt5-webengine
qt5-webkit
qt5-websockets
qt5-x11extras
qt6-base
qt6-declarative
qt6-svg
qt6-translations
qt6-wayland
quazip-qt5
ragel
raptor
rav1e
re2
readline
rhash
rnnoise
rofi
rtkit
rust
sbc
scour
screen
sddm
sdl2
sed
semver
serd
shaderc
shadow
shared-mime-info
signon-kwallet-extension
signon-plugin-oauth2
signon-ui
signond
slang
smbclient
snappy
sndio
solid
sonnet
sord
sound-theme-freedesktop
source-highlight
speex
speexdsp
spirv-tools
sqlite
sratom
srt
startup-notification
steam
strace
sudo
suil
suitesparse
svt-av1
swig
syndication
syntax-highlighting
systemd
systemd-libs
systemd-sysvcompat
systemsettings
taglib
talloc
tar
tcl
tdb
tevent
texinfo
thin-provisioning-tools
threadweaver
tk
tpm2-tss
tracker3
tslib
ttf-hack
ttf-liberation
ttf-opensans
tzdata
udisks2
unzip
upower
usbmuxd (I think this is responsible for supporting using my iphone as a hotspot)
usbutils
util-linux
util-linux-libs
v4l-utils
v4l2loopback-dkms
vid.stab
vlc
vmaf
volume_key
vscodium-bin
vulkan-headers
vulkan-icd-loader
vulkan-radeon
vulkan-tools
wayland
wayland-protocols
wayland-utils
webkit2gtk
webrtc-audio-processing
websocketpp
wget
which
wine
wine-mono
winetricks
wireless-regdb
wireplumber
woff2
wpa_supplicant
wpebackend-fdo
wqy-zenhei
x264
x265
xcb-proto
xcb-util
xcb-util-cursor
xcb-util-image
xcb-util-keysyms
xcb-util-renderutil
xcb-util-wm
xcb-util-xrm
xdg-dbus-proxy
xdg-desktop-portal (base package, requires an implimentation: likely either kde or hyprland)
~~xdg-desktop-portal-kde~~ (only install with KDE)
xdg-user-dirs
xdg-utils
xf86-input-libinput
xfsprogs
xkeyboard-config
xmlsec
xorg-docs
xorg-font-util
xorg-fonts-100dpi
xorg-fonts-alias-100dpi
xorg-fonts-encodings
xorg-server
xorg-server-common
xorg-setxkbmap
xorg-xauth
xorg-xdpyinfo
xorg-xkbcomp
xorg-xmessage
xorg-xprop
xorg-xrandr
xorg-xrdb
xorg-xset
xorg-xsetroot
xorg-xwayland
xorgproto
xvidcore
xz
yasm
yay
zenity
zeromq
zimg
zlib
zsh
zsh-doc
zstd
zxing-cpp
