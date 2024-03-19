# Virtual Machines (QEMU)

---
> _Archived content._

### This is still pending setup!
For Catalyst.V3 (writing this as of the end of Catalyst.V2) I wish to fully remove windows from my setup. It is with great pride that I can claim I have used it so little in the last few months that I am confident removing it from my system will have no negative impacts.  

As it currently stands, the only thing I use my current windows install for is--running proprietary USB configuration utilities like Corsair iCUE (which I should note...no longer even works on my windows install) and modifying the files that I created while it was my primary operating system (i.e. finishing up an Adobe Premiere project.)  

## Goals
There are three things I want out of my Windows VM:
- Isolated from the rest of the filesystem and bootloader (this is the nature of a VM so this much should be trivial)
- Set up with direct USB access so that I can run the proprietary configuration utilities
- Set up with PCI-E passthrough so that I can run certain windows games in the virtual environment (*\*cough\** and painlessly spoof my HWID *\*cough\**)
	- Still determining if I want to install a second GPU so I can maintain access to the host or not (I believe that this is required for looking glass - Currently I'm not sure this is worth it; It would be if I had a windows-heavy workflow...but I do not; That may change however, if I determine that I cannot reliably speedrun games from the linux install thanks to the absence of livesplit support)
	- **NOTE:** The more I consider it, I probably want to use a second GPU (unless it works server-side\*, where I'd then move the GPU into the server) as with the hypothetical scenario: I want to boot up my windows VM to play some DBD. In between some games, I think to do something on my host machine. To free my GPU, I need to completely quit out of my VM, which would mostly defeat the purpose of it being a VM anyway.

## Resources
### [Looking Glass](https://looking-glass.io)
For a system with a dedicated VM video card (i.e. 2+ GPUs, one running the `vfio-pci` module) the issue becomes that the host directly controls this card, which means that I have to swap inputs on my monitor or otherwise have a dedicated secondary monitor. The goal of looking glass is to copy the framebuffer on the passthrough card such that it can be rendered within a window on the host machine--basically allowing a VM to use a dedicated GPU and yet retain the functionality of a standard isolated VM. More information described in [this video](https://www.youtube.com/watch?v=U44lihtNVVM).  

**Hot new questions that this brings me:**
- The video showcases that the host machine actually runs headless, suggesting that a secondary machine with a display is necessary to connect to it. As a result, I am curious if I can host my Windows machine on my local server and what the implications of that would be.
	- Should I try to use PCI-E passthrough on the server VM, or should I use a card on the "user" machine?
	- Regardless, how would I set up looking glass for the "correct" scenario?
	- Does direct USB access work in this case? (Assuming no, but it's worth knowing for sure for the sake of my understanding.)
	- I have found [this form post](https://forum.level1techs.com/t/connect-client-to-remote-vm/155914) suggesting it is theoretically possible but practically impossible - Also PCI-E passthrough would not be possible if the card is on the client, but the instance were on the server (kinda obvious but to check it off the list)  
- What does a headless VM look like (and how to connect to it?)
	- So far I've found [this blog post](https://unixcop.com/how-to-run-a-vm-headless-in-qemu-kvm/)

**Some thinking "out loud":**  
In trying to visualize a headless VM in a similar format to that of the video, I'm attempting to step back and go piece-by-piece. Starting with hypervisor software (think of setting up the machine like a server instance) one could specify 6 instances across 12 cores, giving each instance 2 cores. All of these could be headless and specified to boot by the HV software when the system is booted. These would be real systems present on the network, and I could whip out my laptop and SSH into any of them (of course on the assumption that the SSH service is set up.) Further, all of these virtual machines should be able to SSH into eachother as well, for all intensive purposes.  

On that same theme, it is likely that one of these instances could also be allocated the system's GPU, and it would follow that when the HV goes to boot that instance, the output would show up on the connected displays (taking some liberty to assume that it would auto-detect headless mode or not, and the like.)  

To extend this to a desktop VM use, it would make sense that any number of VM instances could be running on a system, and then the host system need only "SSH" into them to connect to the output. Granted, I am not sure what network protocol this would need for SSH as it likely would have its own subnetwork(?) and also, the interface by which we render the video output of the VM is very likely not SSH anyway. Even with this as an abstraction, however, I believe that the concept remains the same.  

Where this turns into one of the above questions, is that if this instance is hosted on a remote machine, does whatever protocol necessary to view the output still exist?  

**I have to write this down so I stop losing brain cells:**  
Looking glass would be useless on a single GPU machine as its only benefit is copying the framebuffer to a GPU that is not trapped using passthrough. A single GPU setup is guaranteed to trap the GPU, so looking glass would have no where to copy the framebuffer, and the user would further have no access to the host machine to use that framebuffer anyway. Rather, the _only_ output is required to be viewed in the way that looking glass seeks to provide a solution where this would not be.  

### Single GPU passthrough resources
#### [Tutorial by Some Ordinary Gamers](https://www.youtube.com/watch?v=BUSrdUoedTo)
#### [Guide by joeknock90](https://github.com/joeknock90/Single-GPU-Passthrough)
#### [Community Contribution by titakv](https://www.reddit.com/r/VFIO/comments/titakv/my_fully_almost_automatic_single_gpu_passthrough/)

## Additional Resources
#### [Arch Wiki - PCI passthrough via OVMF](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)