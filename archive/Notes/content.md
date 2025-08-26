# Content Creation
> ### Streaming/Editing Utilities: Setup and Configuration

---
# Resolve
**Flatpak: [`Resolve-Flatpak`](https://github.com/pobthebuilder/resolve-flatpak)**  
_This flatpak must be bundled manually as Resolve defys some policy of Flathub._  

## Installation
> `git clone --recursive https://github.com/pobthebuilder/resolve-flatpak.git`

As of writing this, there is currently a library dependency issue with `libcrypt.so.1`  
_Supposedly a newer version is packaged with flatpak._  

The easiest fix is to manually patch [this pull request](https://github.com/pobthebuilder/resolve-flatpak/pull/30) by "merging" the changed files (`com.blackmagic.Resolve.yaml` and `com.blackmagic.ResolveStudio.yaml`.)  
_The first entry, com.blackmagic.Resolve.yaml is technically unnecessary since we are only worried about the studio version._  

I have yet to do my due diligence on how building Flatpaks works, so admittedly I just blindly followed the commands provided by the repository:

> `flatpak-builder --force-clean --repo=repo build-dir com.blackmagic.ResolveStudio.yaml`  
_This one took about 8m30s to run._  

> `flatpak build-bundle repo resolve.flatpak com.blackmagic.ResolveStudio`  
_This command takes nearly 40m to complete._  

> `flatpak install ./resolve.flatpak`  
_Assumes that you are in the Git repo directory; Install the generated Flatpak._

## Overrides
Finally, the flatpak demands a few additional environment overrides.  
_**TODO:** I should just edit the `.yaml` file so that these edits are default, but this provides a reference in the meantime._  

> `flatpak override -u --env='OCL_ICD_VENDORS=rusticl.icd' --env='RUSTICL_ENABLE=radeonsi' com.blackmagic.ResolveStudio`  
Enable RustICL (so that the graphics will render) - [From this issue comment](https://github.com/pobthebuilder/resolve-flatpak/issues/27#issuecomment-2002211123)  

**Devices:** Replace `dri` with `all` (For USB license key / Control panels, such as the speed editor)  
**Allow:** `bluetooth`, `canbus`, and `per-app-dev-shm` _(**TODO:** The latter two may be uncesssary, needs testing)_  
**Filesystem:** `xdg-data:rw`, `home` _(**TODO**: ALL OF THIS!)_  
**Portals:** `Background, Notifications, and Camera _(**TODO:** Simliarly, these may not be relevant options.)_  

## Fixes
### Speed Editor
The speed editor does have native Linux support!

Out of the box, udev assumes that the speed editor is a USB storage device, so it loads it with the `xhci_hcd` module. However, the speed editor is _actually_ an HID device, and requries the `hidraw` module. To fix this, we need to [set a udev rule](https://linuxconfig.org/tutorial-on-how-to-write-basic-udev-rules-in-linux) for the speed editor.

[Davinci Resolve in Linux Guide - Tal](https://www.tal.org/tutorials/blackmagic-davinci-resolve-linux)  

> `cp .../System/Config/Misc/60-speed-editor.rules /etc/udev/rules.d/`  
Copy [the udev rule](/System/Config/Misc/60-speed-editor.rules); Requires permissions elevation

### OBS
_**TODO:** A note more relevant for OBS (when I get around to it) is that Resolve [does **not** support AAC audio codec](https://documents.blackmagicdesign.com/SupportNotes/DaVinci_Resolve_18_Supported_Codec_List.pdf?_v=1658361163000)....which of course is the codec I've used for the last 6 months worth of streams. :)_

### Archived
The following are issues I've had historically, but no longer demanded consideration when moving to the Flatpak for one reason or another.

**LD_PRELOAD error**  
> `LD_PRELOAD=/usr/lib64/libglib-2.0.so`  
> https://unix.stackexchange.com/questions/743572/fedora-38-davinci-resolve-no-longer-opens-after-updating-from-fedora-37-to-38#answer-744205

**Audio device issues:**  
> Davinci resolve audio interfaces directly with alsa, which means that a default alsa device needs to exist, even without alsa installed(?).  
> My system has alsa configuration files, I presume that they come from pipewire... `pacman -Ql alsa-lib` --> *required by* `pipewire-audio`  
> To set the default: `sudo ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d`

**Graphics driver issues:**  
> The AMD proprietary driver appears to work fine! Launch resolve by wrapping it in command `/usr/bin/progl`  
> _**TODO:** I need to document exactly which package provides this. It sets the relevant environment so that the pro driver is used instead of mesa. (Something something Arch Wiki: `AMDGPU`)_

## Notes
- As a result of using the Flatpak portal, Resolve uses the pulseaudio API despite being an ALSA application (although this only makes our config easier)

---

> ### _Archived content._

# OBS todo
- Complete OBS configuration:
- Generic scenes for a couple different generic configurations (inside aptly-named profile)
- Find a way to reinitalize a camera v4l2 source without restarting OBS
- Set up mic filters ([EQ reference video](https://www.youtube.com/watch?v=pjMCyLsRNig))
- Determine a good video transcoding solution (going from mkv to something resolve supports)
- Find good music playlists 
	- Alternatively find a music requests system (this likely requires me to add functionality to the web server script)
- PBP Emulation (possible with xrandr but KDE ignores most xrandr config)
	- Alternatively, it seems that gamescope might offer a good workaround here
- Customize (or really, remake) obs-toolbar. It would be awesome if it were customizable 
- [Once local server is built] Setup new content creation workflow
	- Auto-transcode raw footage to resolve-friendly container and copy onto server (perhaps something with a folder that I manually drag and drop stream files into?)
		- Script should ensure that only certain file extensions are modified
		- Script should verify the copied file on the server before removing its counterpart in the folder
	- Set up Resolve to allow for local network video resources
	- Set up Resolve to allow encoding to take place on server\*
	- Reorganize `/home/Content` and set up NextCloud (or similar) to allow for remote access to footage
	- Set up tiered disk caching so that the relevant footage can be accessed quickly (Memory Disk -> SSD -> Unraid array)
	- Look into Unraid and if the features it provides could prove effective for my desired storage solution (TLDR: Plenty of space for backups and old files, and then the remaining space for the stream archive) - Alternatively, lvm2 might offer enough functionality for this

# Plugins of Interest (Third-party)
- [obs-toolbar](https://obsproject.com/forum/resources/obs-toolbar.1650/)
- [obs-audio-pan-filter](https://obsproject.com/forum/resources/audio-pan-filter.1042/) (technically obsolete with carla, but alas)
- [obs-streamfx](https://obsproject.com/forum/resources/streamfx-for-obs%C2%AE-studio.578/)
- [obs-shaderfilter](https://obsproject.com/forum/resources/obs-shaderfilter.1736/)
- [input-overlay](https://obsproject.com/forum/resources/input-overlay.552/)
- carla-v3 (build from [source tree](https://github.com/falkTX/obs-studio/tree/carla-v3))
- *[looking-glass](https://looking-glass.io/docs/B6/obs/) (if I determine that this is a useful application)*
- *[obs-pipewire-audio-capture](https://obsproject.com/forum/resources/pipewire-audio-capture.1458/) (mic capture currently not functional)*
- *[obs-motion-filter](https://obsproject.com/forum/resources/motion-effect.668/) (out of date / abandoned??)*