 # Install
_**TODO:**_ Verify correctness of these steps (update accordingly)  
`git clone --depth 1 git@github.com:norihiro/obs-audio-pan-filter.git --branch 0.2.3 obs-audio-pan-filter`  
`mkdir obs-audio-pan-filter/build`  
`cd obs-audio-pan-filter/build`  
`cmake -DCMAKE_INSTALL_PREFIX="../install" -Dlibobs_DIR="<OBS clone dir>/build/libobs" ..`  
`make -j2 && make install`  
  
"Drag and drop" the contents of install to its respective location within the OBS files (more info in parent README.md)  
  
# Notes
### General
This plugin orignially compiled with no issues!  
I probably no longer need this in light of Carla, however it still provides a simple and reliable solution when necessary  
  
