### **WIP:** Reorganization general idea
I'm working to split my Linux notes and my Linux configuration. This repo will now be a dedicated project for ensuring a consistent configuration across all of my systems.

That said, some systems feature unique hardware or use cases from others, most notably, my work PC has many unique "overrides" that must be in place. For configuration that does not support conditional logic, committing those to the same files as my personal computer only causes issues. Furthermore, when setting up a new system, many "system-level" configuration files must be updated as well. This can be annoying to do manually, as well as easy to miss certain files. Symlinking system files to this repository raises any number of security concerns as well.

Thus, this project is being reformatted to a set of scripts that I can use to "install" my configuration.

Big ol todo list:
- I need to determine if I want to link files or copy and spot differences
- Some configuration has dependencies, and I want to provide checks if those seem to be met (i.e. ZSH config and starship)
- System-specific overrides
- The final solution will likely be a mix of Bash and Lua
---
Had a thought regarding the system spec:
- Allow system names to be specified as a feature selection keyword within the CLI (i.e. KOKORO (itg pc) -> nvim, weston (+login scripts))
- Specify overrides via selecting a system via the options; this will also preset the selected features
- Thus the selected features option becomes an override to this behavior

Once installed, consider the upgrade/removal process:
- It can help to know what was installed already
 - Consider a cache of sorts
 - OR it would be possible to check if the spec still existed
- This changes when an spec change happens (likely only major changes?)
 - Wiping out specific files can lead to files removed from the spec to be skipped
 - Therefore I'm thinking of the cache containing the install_root directory, and wiping out the entire thing
 - This would also track system edits and files outside of install_root individually
- A similar feature would be up in the air now
 - I could create a "check" mode that can determine if the current form of a spec is installed
 - Should spec files explicitly specify version numbers?
  - This would be a pain to maintain unless it were automated!

Misc notes of things I keep losing track of from the development perspective:
- The dotfiles/ directory is strictly files (data) that would be put into the system (usually linked). The spec/ directory is strictly the rules on how to install it. There exists a temptation to merge these, and while possible, I think this will complicate the organization.
 - If we move feature spec into its dotfile dir (at say dotfiles/\<feature\>/init.lua) then where do we put system/ and depend/?
 - We could remove system entirely and nest it within the feature spec, but then adding a new system would be far more tedious, requiring that we manually include/omit every feature. Simliarly, shared soft dependencies would most likely just be duplicated into any feature that calls for them.
 - There is also the implication that doing this adds another directory from which we execute lua. The split structure means that no file in dotfiles/ is ever loaded as a chunk by the interpreter.

Some extra notes for the new README:
- The "installation" works by generating a bash script: ./install (gitignored)
 - This is so that the install command can be manually inspected first because it might use scary commands
- Refer to spec/features/zsh as the verbose, reference spec file--the ZSH config contains a little bit of everything

# About
This repository is my attempt at a creating a comprehensive collection of everything major I've learned about linux since I dove down the rabbit hole a year ago as well as all of my configuration files, scripts, and the like.

This is still a **work in progress** (and probably always _will_ be to some extent) as I still have many steps remaining to "perfect" my setup. The vast majority of configuration files will likely only be added after I have "completed" that portion of the setup to the full extent of my intention.

# Discussions
I highly encourage you to use the github discussions feature for any configuration changes you wish to suggest, typos on my readmes, questions left unanswered, or even if you're facing a similar issue to me! I love hearing feedback, and perhaps I may be a helpful resource to you.

# To-do
- Write a script that runs through `Config/Filesystem/` and checks for differences between the files located here and those on the system (ensure script ignores any files with the name of README.md)
- Some of the packages on the install guide can (and probably should) be moved to later phase as many are not immediately necessary
- Finish this To-do list  

# Directory Structure
### OUT OF DATE--still figuring the new hierarcy
## Build
Manually compiled applications (not handled by package manager)  
Includes references to specific Git repo / branch, notes on dependencies and build troubleshooting  
Includes copies of any modified files, and additional build files (like OBS -> build.sh)  
  
## Config
Any program configuration files (basically a directory clone of /etc/ and /home/.config)  
_^^These will be located in `./Filesystem`_  
Also includes notes to miscellaneous things such as links to KDE themes, fonts, etc.  
Finally, customization resources will be available here as well (such as desktop wallpapers)  
  
## Install
Notes regarding installation and initial setup of the OS (include microsoft in EFI partition, useradd options)  
List of systemd services to enable (or disable)  
Includes files such as a comprehensive list of packages to explicitly install  
  
## Notes
Miscellaneous notes of various tricks and troubleshooting (ex. finding the package responsible for a file w/ pacman or launch parameters for steam games)  
Also included are things like a "system TODO list"  
  
## Scripts
Personal, system-management scripts (/home/Documents/scripts)  

---

## _Misc_
A collection of incompleted drafts of various things; unorganized and unsuitable for being "published" to the primary configuration  
