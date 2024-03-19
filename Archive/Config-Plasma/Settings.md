*Note that this list is technically incomplete - The goal is to capture just the essential configuration.*  
  
# Appearance
## Themes
### Graphite 
[KDE Store](https://store.kde.org/p/1667594)  
[Github Repo](https://github.com/vinceliuice/Graphite-kde-theme)  
  
### Utterly Round
[Github Repo](https://github.com/HimDek/Utterly-Round-Plasma-Style)  
  
#### [Plasma Style - KDE Store](https://store.kde.org/p/1901768)  
#### [Window Decorations - KDE Store](https://store.kde.org/p/1903823)  
  
### Aura Plasma (Plasma Style)
[KDE Store](https://store.kde.org/p/1898639)  
[Github Repo](https://github.com/L4ki/Aura-Plasma-Themes)  
  
### Catppuccin (Colors)
Currently prefer mocha (consider retheme to match pink candy Codium theme)  
  
### Tela Circle - Purple Dark (Icons)
[KDE Store](https://store.kde.org/p/1359276)  
[Github Repo](https://github.com/vinceliuice/Tela-circle-icon-theme)  
**Icon Path:** `$HOME/.local/share/icons/Tela-circle-purple*/`  
  
### Arch Splash (Splash Screen)
[KDE Store](https://store.kde.org/p/1787957)  
[Github Repo](https://github.com/P3tray/1604-Arch-Splash)  
  
## Fonts
**General** -> Open Sans Light `(10pt)`  
**Fixed Width** -> Jetbrains Mono `(10pt)`  
**Small** -> Open Sans Semibold `(8pt)`  
**Toolbar** -> Open Sans `(10pt)`  
**Menu** -> Open Sans Light `(10pt)`  
**Window Title** -> Open Sans Light `(11pt)`  
  
# Workspace
## Effects (Behavior)
### Burn My Windows
[Github Repo](https://github.com/Schneegans/Burn-My-Windows)
  
[TV Glitch - KDE Store](https://store.kde.org/p/1982142)  
[Hexagon - KDE Store](https://store.kde.org/p/1884309)  
  
## Window Actions (Management -> Behavior)
### Inner Window, Titlebar and Frame Actions
**Modifier Key** -> `Meta`  
**Left Click** -> Move  
**Middle Click** -> Toggle raise and lower  
**Right Click** -> Resize  
  
## KWin Scripts (Mangement)
### Force Blur
[KDE Store](https://store.kde.org/p/1294604)  
[Github Repo](https://github.com/esjeon/kwin-forceblur)  
  
**Class Names**  
<pre>
alacritty
alacritty Alacritty
code-oss
vscodium
dolphin
cider
discord
rofi  
</pre>
_Blur only matching_
  
### Latte Window Colors
[KDE Store](https://store.kde.org/p/1290287)  
[Github Repo](https://github.com/psifidotos/kwinscript-window-colors)  
  
## Shortcuts
### Commands
**Print** -> `QT_QPA_PLATFORM_xcb flameshot gui`  
**Shift + Print** -> `QT_QPA_PLATFORM_xcb flameshot screen`  
_These commands require the flameshot package._  
  
**Meta + \`** -> Open Home (with file manager)  
**Meta + F10** -> Toggle Window Titlebar and Frame  
**Meta + F11** -> Make Window Fullscreen  
**Meta + Shift + C** -> Move Window to Center  
**Meta + Shift + Up** -> Maximize Window  
**Meta + Shift + Down** -> Maximize Window Vertically  
**Meta + PgDown** -> Minimize Window  
**Meta + PgUp** -> Show Desktop Grid  

# Personalization
_Very few relevant entries in this category, with the exception of one essential one for my typical use case_  
## Legacy X11 App Support (Applications)
**Allow legacy X11 apps to read keystrokes typed in all apps** -> Always  
_This fixes issues seen in Flameshot and OBS where keybinds do not appear to work_  
