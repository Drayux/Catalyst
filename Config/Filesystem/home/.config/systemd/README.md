# This is a service for **systemd**
### _**That means that it will not work out of the box with something like S6 - My new choice of init system.**_ 

## Purpose
This is a custom service responsible for launching the desktop environment upon TTY login. It is a user service so that this only happens for specific users (i.e. happens for my main account but not `root`.) Essentially, this is a "budget display manager."  

## Installation
**Enable the service:** `systemctl --user enable de-autostart.service`  
**Disable the service:** `systemctl --user disable de-autostart.service`  
  
This command will either create or remove the symlink to `~/.config/systemd/user/plasma-autostart.service` indicating to systemd that the service should be initalized.  
  
The symlink will be placed in `~/.config/systemd/user/default.target.wants`  

## Additional Notes
_The service will likely need to be modified to work properly._  
Inside the service file, the ExecStart parameter needs to point to the path of the script that will launch the desktop environment. This can be as simple as the `/usr/bin/` entry, however, I prefer to use a script that can check if the exectuable is already running for the sake of being a failsafe.  
  
Additionally, the launch script itself will need to be modified depending on the desktop environment that one seeks to launch.  
  
(_**TODO:**_ Consider creating the folder `~/.config/systemd/scripts` to hold a copy of the launch scripts relative to the service files.)  
(_**TODO:**_ Modify the launch-de script to take a parameter for the .desktop entry, allowing the script to work for any DE.)  
