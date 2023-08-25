# Aliases to reboot with specific OS
alias reboot-uefi="systemctl reboot --firmware-setup"
alias reboot-win="systemctl reboot --boot-loader-entry=00-windows.conf"

# Aliases for debugging utilities
alias debug-kwin="qdbus org.kde.KWin /KWin org.kde.KWin.showDebugConsole"

# Miscellaneous aliases
# alias de="startplasma-wayland" # (Moved to scripts.zsh)
