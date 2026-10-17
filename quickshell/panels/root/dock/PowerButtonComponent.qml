import Quickshell
import QtQuick

import "../../../tiles"
import "../../../vars"
import "../../../services"

ChipTile {
	color {
		r: STYLE.color_Accent.r
		g: STYLE.color_Accent.g
		b: STYLE.color_Accent.b
		a: 1.0 // STYLE.dock_TrayOpacity
	}

	IconTile {
		implicitHeight: parent.height
		iconName: "power"
		iconColor: PowerService.activeColor
		iconMargin: 14

		Behavior on iconColor {
			PropertyAnimation {
				duration: 150
			}
		}

		MouseArea {
			anchors.fill: parent
			cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

			onClicked: {
				if (PowerService.menuActive) {
					PowerService.invokeAction()
				} else {
					PowerService.menuActive = !PowerService.menuActive
				}
			}
		}
	}
}
