# Placeholder for networking notes

# Network Packages
I still haven't quite figured out the different types of network-related packages. Originally I had an issue with having too many packages that all combated eachother, but my final solution still used some combination of `wireless_tools` and `NetworkManager`.  

It would seem that `iw` is a direct replacement for `wireless_tools` and it can supposedly also replace `NetworkManger` however, I am still under the impression that the latter may be required for easily managing network connections (such as with a GUI; like inside of KDE.)  

I also still have `wpa_supplicant` installed and at this rate I have no idea what it does. (Wireless stuff I guess? Do I need it alongside `iw`?)  

# Wifi 6/6E
### wireless-regdb
This seems to be necessary for Wifi 6 and 6E to work, but I have still not been successful yet. (I've also found a file somewhere in `/etc` that may have been important to modify for this!)  

### Additional resources
https://github.com/morrownr/USB-WiFi/blob/main/home/USB_WiFi_Adapters_that_are_supported_with_Linux_in-kernel_drivers.md  
https://github.com/morrownr/USB-WiFi/discussions/63  

# Troubleshooting
### mt7921e \<serial\>: driver own failed
The majority of modern motherboards appear to be equpped with networking hardware that requires the mt7921e driver. Frequently, I would start my system and see many "driver own" messages, suggesting that the device failed to initialize.  

The cause of this seems to be something related to Windows (naturally) supposedly regarding storing the device state for fast boot. Alas, the only fix I've yet found is after launching (and then closing) a Windows install, the computer must be fully disconnected from power to reset the state. This is not an issue when launching Linux on its own.  