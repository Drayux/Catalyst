import Quickshell
import QtQuick
import QtQuick.Layouts

import "dock/"

import "../../tiles/"
import "../../vars/"
import "../../services"

Item {
	id: component_Dock
	required property int position
	property int sideMargin
	property var activeDisplay

	Item {
		id: _RO
		readonly property int position: parent.position
		readonly property int clockBorder: STYLE.g_MainBorderWidth
		readonly property int clockHeight: {
			var _height = STYLE.dock_ClockHeight;
			if (!_height || _height <= 0 || _height > parent.height) {
				// max height by default
				return parent.height;
			}
			return _height;
		}
		readonly property int clockRadius: clockHeight == parent.height?
			0 : (clockHeight == trayHeight ? // pointy if full size
			0 : STYLE.g_AccentBorderRadius) // pointy if tray is same size
		readonly property int trayBorder: STYLE.g_MainBorderWidth
		readonly property int trayHeight: {
			var _height = STYLE.dock_TrayHeight;
			if (!_height || _height <= 0 || _height > clockHeight) {
				// max height by default
				return clockHeight;
			}
			return _height;
		}
		readonly property int trayRadius: trayHeight == parent.height?
			0 : STYLE.g_AccentBorderRadius // pointy if full size
	}

	SystemClock {
		id: service_Clock
		precision: SystemClock.Seconds
	}

	anchors {
		horizontalCenter: (position == TYPES.TilePosition.Center) ?
			parent.horizontalCenter : undefined
		left: (position == TYPES.TilePosition.Left) ?
			parent.left : undefined
		right: (position == TYPES.TilePosition.Right) ?
			parent.right : undefined
		leftMargin: sideMargin
		rightMargin: sideMargin
	}

	/* DEV NOTE:
	 * The dock is a particularly special component because we want explitly to
	 * center it as though the clock portion is the center of the entire
	 * component.
	 *
	 * Thus, my chosen implementation is to set the component width to only
	 * that of the clock, the tray and workspaces will overhang. This solution
	 * feels scuffed, but it is also compatible with left / right alignments. */
	height: parent.height // height of root bar panel
	width: obj_Clock.width
	clip: false

	/* --- POWER --- */
	PowerButtonComponent {
		id: obj_PowerButton

		anchors {
			right: position == TYPES.TilePosition.Left? obj_Clock.left : undefined
			rightMargin: -_RO.clockBorder
			left: position == TYPES.TilePosition.Right? obj_Clock.right : undefined
			leftMargin: -_RO.clockBorder
			top: OPTS.isTopBar? component_Dock.top : undefined
			topMargin: -_RO.trayBorder
			bottom: OPTS.isTopBar? undefined : component_Dock.bottom
			bottomMargin: -_RO.trayBorder
		}

		visible: (component_Dock.position != TYPES.TilePosition.Center)
		height: _RO.trayHeight + _RO.trayBorder
		position: (component_Dock.position == TYPES.TilePosition.Left) ?
			TYPES.TilePosition.Left : TYPES.TilePosition.Right
		radius: _RO.trayRadius
		outside: true
	}
	// PowerComponent {
		// id: obj_PowerMenu
		// master: false

		// visible: (component_Dock.position != TYPES.TilePosition.Center)
		// height: _RO.trayHeight + _RO.trayBorder
		// position: (component_Dock.position == TYPES.TilePosition.Left) ?
			// TYPES.TilePosition.Left : TYPES.TilePosition.Right
		// radius: _RO.trayRadius
		// outside: true
	// }

	/* --- TRAY --- */
	ChipTile {
		id: obj_Tray

		anchors {
			right: position == TYPES.TilePosition.Left? obj_Clock.left : undefined
			// rightMargin: -_RO.clockBorder /// TODO: borders visible should be configurable
			left: position == TYPES.TilePosition.Right? obj_Clock.right : undefined
			// leftMargin: -_RO.clockBorder /// TODO: borders visible should be configurable
			top: OPTS.isTopBar? component_Dock.top : undefined
			topMargin: -_RO.trayBorder
			bottom: OPTS.isTopBar? undefined : component_Dock.bottom
			bottomMargin: -_RO.trayBorder
			/// TODO: Considering making the above into an option to show the border or not
		}

		height: _RO.trayHeight + _RO.trayBorder
		implicitWidth: 24 // relatively arbitrary (TODO)
		position: (component_Dock.position == TYPES.TilePosition.Left) ?
			TYPES.TilePosition.Right : TYPES.TilePosition.Left
		radius: _RO.trayRadius
		outside: true

		color {
			r: STYLE.color_TrayBackground.r
			g: STYLE.color_TrayBackground.g
			b: STYLE.color_TrayBackground.b
			a: STYLE.dock_TrayOpacity
		}
		borderColor: STYLE.color_AccentBorder
		borderWidth: _RO.trayBorder

		/* -- CONTENTS -- */
		Item {
			height: parent.height
			width: obj_TrayWindows.width + obj_TrayWorkspaces.width + obj_TrayPowerMenu.width

			Behavior on width {
				PropertyAnimation {
					duration: 240
					// easing.type: Easing.InOutCubic
					easing.type: Easing.OutBack
				}
			}

			WorkspacesComponent {
				id: obj_TrayWorkspaces
				opacity: PowerService.menuActive? 0 : 1.0

				anchors.right: parent.right
				width: PowerService.menuActive? 0 : implicitWidth
				refTile: obj_Tray 
				inline: true
				Behavior on opacity {
					PropertyAnimation {
						duration: 240
					}
				}
			}
			TrayComponent {
				id: obj_TrayWindows
				opacity: PowerService.menuActive? 0 : 1.0

				anchors.left: parent.left
				width: PowerService.menuActive? 0 : implicitWidth
				clip: true
				Behavior on opacity {
					PropertyAnimation {
						duration: 240
					}
				}
			}
			PowerMenuComponent {
				id: obj_TrayPowerMenu
				opacity: PowerService.menuActive? 1.0 : 0

				anchors.centerIn: parent
				width: PowerService.menuActive? implicitWidth : 0
				height: parent.height
				Behavior on opacity {
					PropertyAnimation {
						duration: 240
					}
				}
			}
		}
	}

	/* --- WORKSPACES --- */
	ChipTile {
		id: obj_Workspace

		// Only visible if placement on right of clock is available
		visible: component_Dock.position == TYPES.TilePosition.Center
		anchors {
			left: obj_Clock.right
			leftMargin: -_RO.clockBorder
			//
			top: OPTS.isTopBar? component_Dock.top : undefined
			topMargin: -_RO.trayBorder
			bottom: OPTS.isTopBar? undefined : component_Dock.bottom
			bottomMargin: -_RO.trayBorder
			/// TODO: Considering making the above an option to show the border or not
		}

		height: _RO.trayHeight + _RO.trayBorder
		implicitWidth: 24 // relatively arbitrary since this should never be empty
		position: TYPES.TilePosition.Right
		radius: _RO.trayRadius
		outside: true

		color {
			r: STYLE.color_TrayBackground.r
			g: STYLE.color_TrayBackground.g
			b: STYLE.color_TrayBackground.b
			a: STYLE.dock_TrayOpacity
		}
		borderColor: STYLE.color_AccentBorder
		borderWidth: _RO.trayBorder

		/* --- CONTENTS --- */
		WorkspacesComponent { }
	}

	/* --- CLOCK --- */
	// TODO: The left, right, center config needs a bit of love, still
	Rectangle {
		id: obj_Clock

		width: obj_ClockShapeLeft.totalWidth * 2 + obj_ClockContents.width
		height: _RO.clockHeight + _RO.clockBorder
		anchors {
			top: OPTS.isTopBar? parent.top : undefined
			topMargin: -_RO.clockBorder
			bottom: OPTS.isTopBar? undefined : parent.bottom
			bottomMargin: -_RO.clockBorder
		}
		color: "transparent"
		layer.enabled: true

		/* Left side shape */
		ChipTile {
			id: obj_ClockShapeLeft

			// Anchor line is relative to largest contained rect
			anchors.left: obj_Clock.left
			anchors.leftMargin: accentWidth
			position: TYPES.TilePosition.Left

			height: parent.height
			implicitWidth: STYLE.dock_ClockPadding
			radius: _RO.clockRadius
			outside: true

			color: STYLE.color_ClockBackground
			borderWidth: _RO.clockBorder
			borderColor: STYLE.color_ClockBorder
		}
		/* Right side shape */
		ChipTile {
			id: obj_ClockShapeRight

			// Anchor line is relative to largest contained rect
			anchors.right: obj_Clock.right
			anchors.rightMargin: accentWidth
			position: TYPES.TilePosition.Right

			height: parent.height
			implicitWidth: STYLE.dock_ClockPadding
			radius: _RO.clockRadius
			outside: true

			color: STYLE.color_ClockBackground
			borderWidth: _RO.clockBorder
			borderColor: STYLE.color_ClockBorder
		}
		/* Center block */
		Rectangle {
			id: obj_ClockShapeBase

			anchors {
				left: obj_ClockShapeLeft.right
				leftMargin: -_RO.clockBorder
				right: obj_ClockShapeRight.left
				rightMargin: -_RO.clockBorder
			}
			height: parent.height
			// width: obj_ClockContents.width (implied if my math is correct)

			color: STYLE.color_ClockBackground

			// Special stuff to hide the "middle borders"
			clip: true
			Rectangle {
				anchors {
					fill: parent
					leftMargin: -_RO.clockBorder
					rightMargin: -_RO.clockBorder
				}
				color: "transparent"
				border {
					width: _RO.clockBorder
					color: STYLE.color_ClockBorder
				}
			}
		}
	}
	Text {
		id: obj_ClockContents

		anchors.centerIn: obj_Clock
		anchors.verticalCenterOffset: OPTS.isTopBar? -1 : 1

		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 22
		font.weight: 800
		font.letterSpacing: -0.20
		color: STYLE.color_ActiveText
		text: Qt.formatDateTime(service_Clock.date, "HH:mm")
	}
}
