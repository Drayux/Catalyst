pragma Singleton

import QtQuick
import Quickshell

Singleton {
	enum TilePosition {
		Left,   // Parent will left-align the item
		Center, // Parent will center the item (ignore)
		Right   // Parent will right-align the item
	}
}
