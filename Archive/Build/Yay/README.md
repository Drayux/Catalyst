# Installation
Yay is an AUR helper which, amusingly, is only available on the AUR. This means that it will be our one-and-only manual AUR package in order to effortlessly handle all the rest. (Unless we create custom `PKGBUILD`s for other compiled applications.)  

> [**GitHub Repo**](https://github.com/Jguer/yay)  
_The installation is very well-documented here!_  

**Quick and dirty summary**  
1) Generate the package  
	```
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
	```

	> `makepkg -s` : sync dependencies  
	> `makepkg -i` : install  

	_So alternatively, we can run:_
	```
	makepkg -s
	sudo pacman -U yay-*.pkg.tar.zst  # Ideally specify the current version
	```

2) Perform first-run setup  
`yay -Y --gendb` will update the database for AUR packages installed before yay (Probably worth doing even if yay was first so that yay is definitely in the database.)  
`yay -Y --devel --save` _appears_ to specify the `"devel": true` flag in the config file  

3) Copy the configuration from `../Config/Filesystem/home/.config/yay`  