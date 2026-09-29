import Quickshell
import QtQuick
import Niri

import "modules/"

ShellRoot {
	Niri {
		id: niri
		Component.onCompleted: connect()
		// onConnected: console.info("Connected to niri")
		onErrorOccurred: function(error) {
			console.error("Error connecting to niri:", error)	
		}
	}

	PanelWindow {
		// property real margin: 8
		property int barBorder: 3
		property int barRadius: 16

		id: root
		implicitHeight: 36

		screen: {
			for (const s of Quickshell.screens) {
				if (s.x === 0 && s.y === 0) {
					return s
				}
			}
			return Quickshell.screens[0]
		}

		anchors {
			top: true
			left: true
			right: true
		}
		margins {
			left: 12
			right: 12
		}
		color: "transparent"

		// PopupWindow {
			// id: test_popup
			// anchor.window: root
			// anchor.rect.x: 10
			// anchor.rect.y: 10
			// implicitWidth: 300
			// implicitHeight: 300
			// color: "red"
			// visible: true
		// }

		// --- Base bar background ---
		Rectangle {
			anchors.fill: parent

			color: "#232137"
			opacity: 0.80
			// opacity: 0.87

			bottomLeftRadius: root.barRadius
			bottomRightRadius: root.barRadius
		}

		// --- Left widget: 'media' ---
		Media {
			id: media

			anchors {
				left: parent.left
				leftMargin: 24
				right: dock.left
				rightMargin: 24

				bottom: parent.bottom
				top: parent.top
			}
		}

		// --- Right widget: 'system' ---
		Toast {
			anchors.right: power.left
			anchors.rightMargin: 5 // intentional gap to avoid creating confusing buttons
		}
		Power {
			id: power
			anchors.right: parent.right
			anchors.rightMargin: 24
		}

		// --- Center widget: 'workspace' ---
		Dock {
			id: dock
			anchors.right: clock.left
			// anchors.rightMargin: -20
			y: -root.barBorder
		}
		Spaces {
			anchors.left: clock.right
			y: -root.barBorder
		}
		Clock {
			id: clock
			anchors.centerIn: parent
			// opacity: 0.5
			MouseArea {
				anchors.fill: parent
				onClicked: {
					test_popup.visible = true
				}
			}
		}

		// --- Base bar border ---
		Rectangle {
			width: parent.width
			height: parent.height + border.width
			y: -border.width

			color: "transparent"
			bottomLeftRadius: root.barRadius
			bottomRightRadius: root.barRadius
			border.color: "#3F395D" // Niri is "#393552" try to visually match
			border.width: root.barBorder
		}
	}
}
