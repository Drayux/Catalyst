# Setup
###### All depenencies are referred to as their pacman package names
### Make dependencies
- asio
- ~~cef-minimal-obs~~ (local download for build)
- cmake
- git
- make
- nlohmann-json
- websocketpp  
====================
- libfdk-aac (optional)
- luajit (optional)
- jack (optional)
- ~~libajantv2~~ (optional - not building aja)
- python (optional)
- sndio (optional)
- swig (optional - needed for scripting?)
- ~~systemd-libs~~ (optional - hopefully supplied by something in S6...needed for v4l?)
- v4l-utils (optional)
- v4l2loopback-dkms (optional)

### Run Dependencies (*not a dep of obs-studio package)
- *alsa-lib
- *at-spi2-core (dbus; hopefully a suitable S6 replacement exists)
- curl
- *dbus (hopefully a suitable S6 replacement exists)
- *expat
- ffmpeg (prefer ffmpeg-obs from AUR)
- *fontconfig
- *freetype2
- ~~*ftl-sdk~~ (does not appear to be necessary?)
- *gcc-libs
- *glib2
- *glibc
- jansson
- *libcups
- *libdrm
- *libglvnd
- *libpipewire
- *libpulse
- *librist
- *libva (check that this is not satisfied by libva-mesa-driver?? ...looks like its an opt depend of libva)
- *libx11
- *libxcb
- libxcomposite
- *libxdamage
- *libxext
- *libxfixes
- libxkbcommon
- *libxrandr
- mbedtls
- *mesa
- *nspr
- *nss (some of these seem like they might just be for other packages??)
- pciutils
- *qt6-base (this feels like a make dependency...)
- qt6-svg
- *qt6-wayland
- rnnoise
- *speexdsp (required for alsa so like)
- *srt (secure video transport ig?)
- *util-linux-libs
- ~~*vlc-luajit~~ (was not necessary when I compiled--this is a compatibility package)
- *wayland (probably optional tbh)
- x264
- *zlib  
====================
- ~~decklink~~ (optional - not building decklink)
- ~~intel-media-driver~~ (optional - no intel hardware)
- ~~libva-intel-driver~~ (optional - no intel hardware)
- libva-mesa-driver (optional)
- v4l-utils (optional)
- v4l2loopback-dkms (optional)

### Mystery dependencies
- onevpl (dependency of ffmpeg-obs so that checks out)
- libdatachannel (seems to be necessary for building the websocket, hence the absense from the AUR pkgbuild)

### Extra note: Packages installed from mostly fresh install to build OBS
(Many graphics-dependent things installed already such as wayland, steam, etc.)
- ffmpeg-obs
- swig
- nlohmann_json
- websocketpp
- asio
- _carla_
- _lsp-plugins-lv2_

# Install
### Clone the repo
`git clone --recursive --depth 1 --branch 29.1.3 git@github.com:obsproject/obs-studio.git ./29.1.3`  
  
### Download CEF framework
`wget --directory-prefix=deps https://cdn-fastly.obsproject.com/downloads/cef_binary_5060_linux64.tar.bz2`  
`tar -xjf deps/cef_binary_5060_linux64.tar.bz2`  
  
### Prepare Carla patch
_**TODO:**_ There likely exists a way to pull just the changes and call it a day, I have yet to figure how to do that  
This solution seems promising: https://stackoverflow.com/questions/19630320/pull-changes-from-fork-to-original-repository-in-git  
^^In testing, it seemed that I could not do a --depth 1 clone for the auto merge solution to work, pending trying the second version  
  
`git clone --recursive --depth 1 --branch carla-v3 git@github.com:falkTX/obs-studio.git ./29.1.3_carla`  
`(Alternatively, the modified files are saved in ./plugins/carla-v3, excluding README.md)`  
  
"Drag and drop" the following files/directories:
- cmake/
- plugins/carla/
  
Modify plugins/CMakeLists.txt with the changes apparent in the file  
^^TLDR: Add two lines of `add_subdirectory(carla)` so that the plugin can be built automatically  
  
NOTE: Building the carla plugin can be disabled by adding the flag `ENABLE_CARLA=OFF` to the build.sh script  
  
### Compile with build.sh
The repo has build.sh currently set to build the portable version of OBS, this can be changed by modifiying the variable at the top of the script to `ON`  
`cd 29.1.3`  
`./build.sh`  
  
### Build and install additional third-party plugins
./plugins contains a similar structure as this directory  
  
These plugins are all designed to be built and installed independently  
Install to ~/.config/obs-studio/plugins  
  
The directory structure should look like the following:
<pre>
plugins/
	"plugin-name-1"/
		| bin/
			| 64bit/
				| "plugin-name-1".so
		| (data/)
			| (data files)			<-- ex: example.cfg textures/
			| locale/
				| (locale.ini)		<-- ex: en_US.ini
				| ...
	"plugin-name-2"/
		| bin/
			...
		| (data/)
			...
	"plugin-name-3"/
		...
	...
</pre>

# Notes
Build Reference -> https://github.com/obsproject/obs-studio/wiki/Building-OBS-Studio  
Portable Reference -> https://github.com/obsproject/obs-studio/wiki/build-instructions-for-linux  
Plugin Template -> https://github.com/obsproject/obs-plugintemplate  
  
### Packages
Dependencies seem to include packages: onevpl, websocketpp, asio, librist*, libdatachannel  
Further, carla and liblrdf are necessary for carla plugin build  
Prefer ffmpeg-obs (from aur) over ffmpeg  
_Juce might be necessary for some audio plugins_  
  
### Compiling
Run `source /etc/profile` before \<aka at some stage during setup - _**TODO**_\> compiling
Carla PR -> https://github.com/obsproject/obs-studio/pull/8919

### Running
(Currently not in use) The VST 2.0 plugin path can be set with the variable `VST_PATH=\<path\>`  
XWayland can be forced with either the runtime parameter `-platform xcb` or the variable `QT_QPA_PLATFORM=xcb`  

### Plugins
#### The following plugins look interesting but are not currently usable
- obs-pipewire-audio-capture (mic capture currently not functional)
- obs-motion-filter (out of date / abandoned)  
  
#### Also pending exploration
- https://github.com/norihiro/obs-command-source  
- looking-glass (filter) : Consider this if I use this for my windows VM  
  
#### The best (so far) audio plugins are available here -> https://github.com/sadko4u/lsp-plugins  
*These may be packaged in extra/lsp-plugins-lv2 but this needs verification*  
^^If not they can be built from source; just clone, `make configure`, `make all`, and `make install` (needs php)  
  
#### For additional "locally-installed" plugins, search paths can be added to Carla  
Add a carla filter (patch bay or generic)  
Select "Show Custom GUI"  
Select "Configure Carla"  
Add the plugin path(s) to their respective plugin type  
Close the configuration, move to the patchbay  
Select "+ Add Plugin"  
Select "Refresh" near the search bar  
  
# To-do
### Verify and prune dependencies
### Add pacman support
Create a PKGBUILD file that allows the above process to be automated via `makepkg --install`  
Alternatively, figure out how to "spoof" the install with the pacman manual dependency thing  
