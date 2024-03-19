# Miscellaneous System Notes, Projects, Fixmes, and Discoveries

# Troubleshooting
_Generic issues without their own breakdown file._

## Networking
### mt7921e \<serial\>: driver own failed
> _Archived content._

The majority of modern motherboards appear to be equpped with networking hardware that requires the mt7921e driver. Frequently, I would start my system and see many "driver own" messages, suggesting that the device failed to initialize.  

The cause of this seems to be something related to Windows (naturally) supposedly regarding storing the device state for fast boot. Alas, the only fix I've yet found is after launching (and then closing) a Windows install, the computer must be fully disconnected from power to reset the state. This is not an issue when launching Linux on its own.  

# Projects
## Virtual displays
> _Archived content._

### Original Support Question
Create multiple "screens" on one display (PBP emulation of sorts?)  
  
I'm on somewhat of a quest to craft the perfect Linux setup for streaming. I've recently purchased an ultrawide monitor and it's proven to be an incredible addition to my setup. That said, you can probably imagine why it's not perfect for streaming as I need to play my games in a 16:9 aspect ratio. The monitor supports this, but it changes the display mode leaving a great deal of unused screen space. I'm left wondering if there's a better solution to this!  
  
I'd like to know how to create "virtual" screens within the same monitor. I have to admit I'm not very knowledgeable on the windowing system, which is why I sought to ask here. I saw a post awhile back by a user who had a broken laptop screen, and could customize the display settings such that the broken half wasn't used. This suggested to me what I hope to accomplish is obtainable.  
  
![<image>](virtual-displays.png)
  
The goal would be to create three "screens" all of which would map to the same monitor. The middle screen would be a 2560x1440, and the space that's otherwise unused would become their own 440x1440 screens. These oddly-proportioned screens would prove perfect for things such as chat and stream stats.  
  
My setup supports both the XOrg and Wayland display servers no problem, so I can use either for this configuration. If anyone is able to point me in the right direction on how to configure this, that would be greatly appreciated. Thank you!  

### Resources
https://chipsenkbeil.com/notes/linux-virtual-monitors-with-xrandr/  
https://www.reddit.com/r/archlinux/comments/k5l9ox/using_xrandr_to_block_out_part_of_my_screen/  
