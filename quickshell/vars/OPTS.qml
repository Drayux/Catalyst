pragma Singleton

import QtQuick
import Quickshell

Singleton {
	readonly property bool isTopBar: true
	readonly property bool gifBackground: true
	readonly property bool onAllScreens: false
	// consider tristate opt for which workspaces to show
}
