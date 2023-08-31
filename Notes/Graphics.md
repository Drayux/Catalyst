# Placeholder for graphics-related notes
### Troubleshooting EDID issues (needs testing to determine if this is a viable fix) 
[Reddit Thread](https://www.reddit.com/r/archlinux/comments/oujnxs/new_amdgpu_unable_to_set_edid_on_one_monitor/)  

A potential fix for the monitor EDID error (display)  
`video=DP-1:D video=DP-2:d`  
https://wiki.archlinux.org/title/kernel_mode_setting#Forcing_modes  

### Kernel parameters
`amdgpu.sg_display=0`  
Unfortunately upon further testing, this parameter seems to have no effect.    

### _**TODO:**_ Fan config