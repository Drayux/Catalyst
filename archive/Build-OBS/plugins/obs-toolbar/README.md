 # Setup
_**TODO:**_ Determine if there exist any additional build dependencies
Copy the following directories/modified files:
- CMakeLists.txt
- data/locale/en_US.ini
- forms/
- src/plugin-main.cpp
  
_It should be noted that I have no idea what I'm doing with anything QT, so some of the modified files may be extraneous_

# Install
_**TODO:**_ Verify correctness of these steps (update accordingly)  
`git clone --depth 1 git@github.com:MisutaaAsriel/obs-toolbar.git --branch 0.1.2 obs-toolbar`  
`mkdir obs-toolbar/build`  
`cd obs-toolbar/build`  
`cmake configure ..` (this may or may not be necessary?)  
`cmake -DCMAKE_INSTALL_PREFIX="../install" -Dlibobs_DIR="<OBS clone dir>/build/libobs" ..` (it seems that it may want to install to the obs directory directly as it uses `setup_plugin_target`, I haven't tested building this completely by itself yet)  
  
Assuming that succeeds...  
  
`make && make install`  
  
"Drag and drop" the contents of install to its respective location within the OBS files (more info in parent README.md)  
  
# Notes
### Modifications
The locale was missing any information, leaving the application menu entry to have no text  
^^Additionally, many names were not pushing translations correctly  
The size of the dock was a little smaller than I'd preferred  
