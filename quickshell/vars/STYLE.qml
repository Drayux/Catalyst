pragma Singleton

import QtQuick
import Quickshell

Singleton {
	readonly property   int g_MainBorderRadius: 16   // roundness of elements
	readonly property   int g_MainBorderWidth: 3     // border thickness of primary elements
	readonly property   int g_AccentBorderRadius: 10 // roundness of accent elements
	readonly property   int g_AccentBorderWidth: 2   // border thickness of accent elements
	readonly property  real g_SkewAngle: 24          // amount of skew for the chip tiles (degrees)
	readonly property  real g_SkewScalar: Math.tan(g_SkewAngle * Math.PI / 180) // (input is radians)
	readonly property string g_FontName: "JetBrainsMono Nerd Font"

	/* bar -- The base quickshell panel */
	readonly property   int bar_Height: 36           // maximum effective height of any bar widget
	readonly property   int bar_EdgeMargin: 12       // spacing from edge of screen
	readonly property   int bar_BackgroundOffset: 20 // shift the vertical center of the gif bg
	readonly property  real bar_BackgroundOpacity: 0.80
	readonly property   int bar_BorderWidth: 3      // match niri config
	readonly property  real bar_GifBackgroundOpacity: 0.70

	/* dock -- Main bar widget, right-aligned by default */
	readonly property   int dock_ClockHeight: 30
	readonly property   int dock_TrayHeight: 26 
	readonly property   int dock_ClockPadding: 32 // space around the time text
	readonly property  real dock_ClockOpacity: 1.0
	readonly property  real dock_TrayOpacity: 0.75
	readonly property  real dock_SpacerOpacity: 0.0

	/* status -- System information widget, left-aligned by default */
	readonly property   int status_ItemHeight: 26 

	/* globalish colors */
	readonly property color color_Base: "#232137"
	readonly property color color_Accent: "#3F395D" // Chip tile color (unless special use)
	readonly property color color_MainBorder: "#3F395D" // Niri is "#393552" try to visually match
	readonly property color color_AccentBorder: "#3F395D" // TODO: considering pink
	readonly property color color_ActiveText: "#93cee9"
	readonly property color color_SelectText: "#d4a1e7"

	/* specific colors */
	// TODO: Modules that use these should have a default value of one of the
	// above (internally)
	readonly property color color_ClockBackground: "black" // "#121221"
	readonly property color color_ClockBorder: "black" // "#93cee9"
	// readonly property color color_Foreground: "#3F395D"
	readonly property color color_TrayBackground: "#121221"
}
