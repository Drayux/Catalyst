 # Install
_**TODO:**_ Verify correctness of these steps (update accordingly)  
`git clone --depth 1 git@github.com:exeldro/obs-shaderfilter.git obs-shaderfilter`  
`cd obs-shaderfilter`  
`cmake -S . -B build -DBUILD_OUT_OF_TREE=On && cmake --build build`  
`make && make install`  
  
"Drag and drop" the contents of install to its respective location within the OBS files (more info in parent README.md)  
  
# Notes
### General
This plugin orignially compiled with no issues!  
Some of the pre-supplied shaders seem a bit buggy/unstable

### Building
This uses a different cmake command, ensure that it is acceptable that this does not include libobs  
By default, compiled binaries appear inside of build/rundir/...  
  
