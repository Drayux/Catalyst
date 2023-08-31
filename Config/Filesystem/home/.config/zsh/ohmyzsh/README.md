## This is not the entire OH-MY-ZSH program!
_It must still be cloned from the repository_  

`ZSH="$HOME/.config/zsh/ohmyzsh" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`  


## Additional Notes
I need to determine if any plugins were installed externally, I cannot remember if my current configuration comes included with oh-my-zsh or not.  
It has been confirmed, zsh-autosuggestions is an external plugin

_**TODO:**_ Add feature to `config.sh` to check if we are in a TTY and select the theme accordingly (as the agnoster characters don't render well in the TTY)  
