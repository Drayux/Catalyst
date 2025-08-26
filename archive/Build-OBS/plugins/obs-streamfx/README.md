# Setup
_**TODO:**_ Determine if there exist any additional build dependencies
Copy the following modified files:
- CMakeLists.txt
- source/ui/ui.cpp

# Install
_**TODO:**_ Verify correctness of these steps (update accordingly)  
`git clone --depth 1 --recursive git@github.com:Xaymar/obs-StreamFX.git --branch 0.12.0b299 obs-streamfx`  
`mkdir obs-streamfx/build`  
`cd obs-streamfx/build`  
`cmake configure ..`  
`cmake -DCMAKE_INSTALL_PREFIX="../" -Dlibobs_DIR="<OBS clone dir>/build/libobs" ..`  
  
Assuming that succeeds...  
  
`make && make install`  
  
"Drag and drop" the contents of install to its respective location within the OBS files (more info in parent README.md)  
I like to rename StreamFX.so (and the plugin folder) to obs-streamfx.so for the sake of consistency  
  
# Notes
### General
The repo will recursively clone OBS so that it can reference libobs I guess?? (_**TODO:**_ Check if this is the case when building)  
This isn't much of an issue other than being annoying  
It appears that `ffmpeg` and `AOM`?? are dependencies
  
### Modifications
StreamFX is a pain because it's not consistent  
It adds a QMenu entry called StreamFX that adds no useful options (with respect to operating OBS)  
It also attempts to show the user a popup when OBS launches  
Though I apprecaite this plugin, I really only want to use a small subset of the features  
The modified files disable the UI quirks and prevent the building of unusued tools (like NVidia-only filters)
  
The shader filter/source elements have also be disabled in favor of building obs-shaderfilter instead