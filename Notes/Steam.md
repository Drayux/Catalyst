# Setup
The steam package is available in the Pacman multilib repo (the 32-bit stuff).  
See the [Arch Wiki entry](https://wiki.archlinux.org/title/Steam) for additional information.  
  
### Dependencies
(the nvidia versus amd library stuff)  
  
### Launch Parameters
Edit the .desktop entry to run steam with the `-console` parameter to enable the additional tab in the GUI.  
This can be a useful tool for debugging misbehaving games.  
  
### Steam Native Runtime
(_**TODO:**_ Understand the native runtime and then describe it here)  
  
My current understanding is that steam will use the "Steam Linux Runtime" for any application it manages by default. The executable script for this is named `steam-runtime` and is what `steam` aliases to.  
  
"Steam Native Runtime" on the other hand (also referred to as `steam-native`) is what is supplied by the package, which effectively translates to `STEAM_RUNTIME=0 /usr/lib/steam/steam %command%` and therefore disabling the containerization feature present with `steam-runtime.` Using this may enable some newer features such as OpenAL, however it is not recommended as there are more likely to be dependency incompatibilities. (Think of the steam linux runtime as the LTS version.)  
  
[steam-native-runtime](https://archlinux.org/packages/multilib/x86_64/steam-native-runtime/)  
[Arch Wiki Entry](https://wiki.archlinux.org/title/Steam/Troubleshooting#Steam_runtime_issues)  
  
### Protontricks
This a python wrapper for winetricks that detects and enumerates the relevant settings for changing the steam game prefixes.  
[Github Repository](https://github.com/Matoking/protontricks)  
  
At one point, the application was crashing upon launch mysteriously. (_**TODO:**_ I can't remember the details on this fix: update this if it happens again!) The solution appeared to involve uninstalling and reinstalling (rather clean building) the `python-vdf` package as there was some form of version mismatch.  
  
### Gamescope
(_**TODO:**_ This is an interesting tool that I need to look into!)  
[gamescope](https://archlinux.org/packages/extra/x86_64/gamescope/)  
  
### Additional Interesting Packages (AUR)
- steamrun  
- steamcmd  
- steamlink  
  
# Troubleshooting
### No sound in proton games
The wine (proton) prefix can be modified to force the use of a specific sound library.  
1) Open Protontricks  
2) Select the game of interest  
3) Select default prefix (_**TODO:**_ Determine if every game has its own set of prefixes or not)  
4) Select change settings  
5) Check `sound=pulse` (alternatively `sound=alsa`)  
6) Press OK / Close (multiple times) to apply and exit  
  
### Games are unexpectedly crashing
_(See the note on dependencies in #setup)_  
  
Otherwise, searching for the game of interest on [protondb](https://protondb.com) has proven itself an effective resource.  

### Faster shader pre-compilation
Steam can be configured to use more threads when pre-compiling shaders, see the wiki entry:  
https://wiki.archlinux.org/title/Steam#Faster_shader_pre-compilation  

### Mesa Driver Environment Variables
Many of the variables used to troubleshoot steam games are documented here:  
https://docs.mesa3d.org/envvars.html  

# Game Configuration
### Alien: Isolation
**Launch parameters**  
`DXVK_FRAME_RATE=130 __GLX_VENDOR_LIBRARY_NAME=mesa MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink %command%`  
  
**Notes**  
Alien's native port has an incompatibility with NVidia drivers, causing the game to crash during a malloc() routine on launch.  
  
On the AMD side however, there is an incompatibility with the newer drivers (necessary for modern AMD cards) which does not crash the game, but introduces some near-unplayable bugs. To fix this, vulkan can be forced using the variables `MESA_LOADER_DRIVER_OVERRIDE=zink` and `GALLIUM_DRIVER=zink`. (See [this protondb post](https://www.protondb.com/app/214490#qmV9v6Ztp8) for additional context.) 
  
In my experience, running alien in this way gave me about a third to a half the performance of the proton version, but it was playable!
  
### Getting over it wwith Bennett Foddy
**General settings**  
Force use of a specific compatibility tool: Proton \<any\> (Linux port is an out of date version) 
  