# Setup
## Launch Parameters
**Enable Wayland**  
`--enable-features=UseOzonePlatform --ozone-platform=wayland`  
  
**Unsure of function - Found with pre-existing .desktop entry**  
`--no-sandbox --unity-launch %F`  

## Program Title
Change title to `Codium` (as opposed to `VSCodium`)  

## Program Icon
Prefer icon `icon.svg`  

# Extensions
## Styling
### Pink Candy (Theme)
**ID:** kuba-p.theme-pink-candy  
**Marketplace:** https://open-vsx.org/extension/kuba-p/theme-pink-candy  

### Neofloss (Theme)
**ID:** radiolevity.neofloss  
**Marketplace:** https://open-vsx.org/extension/radiolevity/Neofloss  

### Catppuccin (Theme)
Not my top pick, but a very safe bet for synchronizing colors across platforms  
**ID:** Catppuccin.catppuccin-vsc  
**Marketplace:** https://open-vsx.org/extension/Catppuccin/catppuccin-vsc  

## GlassIt-VSC*
Allows transparency within the window without the use of compositor tricks  
_\*Skip installation if not necessary with your window manager/compositor_
**ID:** s-nlf-fh.glassit  
**Marketplace:** https://open-vsx.org/vscode/item?itemName=s-nlf-fh.glassit  

## Language Support
### CMake
**ID:** twxs.cmake  
**Marketplace:** https://open-vsx.org/extension/twxs/cmake  

### Data-pack Helper Plus
**ID:** SPGoding.datapack-language-server  
**Marketplace:** https://open-vsx.org/vscode/item?itemName=SPGoding.datapack-language-server  

## Functionality
### Open Remote - SSH*
_\*Supposedly no longer necessary in VSCodium version 1.75+...perhaps I've misunderstood and this is merely a portion of the installation process that is no longer necessary_
**ID:** jeanp413.open-remote-ssh  
**Marketplace:** https://open-vsx.org/vscode/item?itemName=jeanp413.open-remote-ssh  
  
**Installation**  
Thanks to some EULA bullshit or something, the remote connection is disabled in the microsoft branding-removed version of VSCode (VSCodium.) Though this is certainly the preferable version, it means that the built-in remote editor as well as the "officially supported" extensions are non functional.  
  
When installing this plugin, it must be downloaded from "source" and manually installed into Codium.  
(_**TODO:**_ If this is still necessary, write the instructions here.)  

### Thunder Client
**ID:** rangav.vscode-thunder-client  
**Marketplace:** https://open-vsx.org/vscode/item?itemName=rangav.vscode-thunder-client  

## Recommendations
_From [this](https://youtube.com/shorts/Tulknj4xIUA) youtube short._  
### GitLens : Improved Git UI
### Better Comments : Color-code differnent comment directives (TODO, NOTE, etc.)
### Prettier : Useful code formatter (when I need my C code to obey kernel formatting or something smh)
### Live Server : Local web server w/ live page updates

# Settings
_Similar to many other config files, only make note of the significant settings that are changed from their default._  
**Workbench > Editor:** Enable Preview  
**Editor > Font Family:** `"editor.fontFamily": "'JetBrainsMonoNL Nerd Font Mono', 'Droid Sans Mono', 'monospace', monospace"`  
**Insert Spaces:** _Disabled_  
**Format on Paste:** _Enabled_  
**Format on Save:** _Enabled_  
**Minimap > Enabled:** _Disabled_  
**Startup Editor:** None  
**Trust > Enabled:** Disabled  
**Trust > Untrusted Files:** Open  
  
(_**TODO:**_ Determine if there is a setting that allows the Tab key to always indent the current line unless the cursor is at the end or if I hold shift or something)  
