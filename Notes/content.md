# Content Creation (Streaming/Editing) Utilities and Setup

---
> _Archived content._

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