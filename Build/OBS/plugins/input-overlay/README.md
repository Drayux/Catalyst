 # Install
_**TODO:**_ Verify correctness of these steps (update accordingly)  
`git clone --depth 1 --recursive git@github.com:univrsal/input-overlay.git --branch v5.0.4 input-overlay`  
`mkdir input-overlay/build`  
`cd input-overlay/build`  
`cmake configure ..` (this may or may not be necessary?)  
`cmake -DCMAKE_INSTALL_PREFIX="../install" -Dlibobs_DIR="<OBS clone dir>/build/libobs" ..`  
`make && make install`  
  
"Drag and drop" the contents of install to its respective location within the OBS files (more info in parent README.md)  
  
# Notes
### General
This plugin orignially compiled with no issues!  
This also serves as a good reference for QT includes if other plugins are having dependency skill issues  
Note that this plugin is currently non-functional under Wayland as it disallows interprocess keypress sharing  
This folder also includes a copy of my personal configuration files  

### Building
It may be possible to install libuiohook from pacman and omit the necessity of the recursive clone  
It appears that `curl` may be a make dependency  
_**TODO:**_ Existing install was never `make install`ed, check that the make install works as expected or remove the command  
