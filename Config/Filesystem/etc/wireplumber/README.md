# Directories
### Dev
Development scripts written either with the intent of collecting information about the Pipewire/Wireplumber graph, or for experimenting with the Lua features.  
  
Nothing in this folder is ran by the wireplumber core, though `wpexec \<script\>` can be used to run these scripts independently.  
  
### main.lua.d
This is used to apply properties to the components within the graph. Notably, we specify to alsa that the Focusrite Scarlett 18i20 should be configured to run with a 96000hz sample rate.  
  
### policy.lua.d
The policy directory specifies rules to wireplumber how it should handle the graph itself (notably how devices interact with each other.) In this case, we currently specify that an additional policy should be loaded; the name suggesting it is relevant to the Focusrite Scarlett 18i20.  
  
### scripts
**policy-node.lua** is an override of /usr/share/wireplumber/scripts/policy-node.lua (wireplumber does this directory precedence hierarchy automatically) to implement the custom routing policy for my setup. This is the functionality that took me nearly a year to figure out. Specific changes are indicated within a comment at the top of the file.  
  
**policy-scarlett.lua** is the script loaded from the file in policy.lua.d. This is responsible for introducing additional policies to connected the virtual pipewire nodes (configured in `/etc/pipewire/pipewire.conf.d/20-virtual.conf`)