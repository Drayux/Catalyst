#!/bin/zsh
# Simple script that takes advantage of XRANDR to convert
# the 21:9 ultrawide into a 16:9 alongside two 5:18s

# Proof of concept state right now--Use to test if this is supported by your WM

xrandr --setmonitor virtL 1720/395x1440/330+0+0 DP-1
xrandr --setmonitor virtR 1720/395x1440/330+1720+0 none
