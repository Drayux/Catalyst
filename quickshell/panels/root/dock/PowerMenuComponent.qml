import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../../services"
import "../../../vars"

/* TODO: This entire file still needs variables and proper organization */

RowLayout {
	height: parent.height
	spacing: -4

	Text {
		id: poweroff_button
		readonly property bool selected: PowerService.menuSelection == PowerService.PowerState.Shutdown

		text: "POWEROFF"
		Layout.fillWidth: false
		Layout.alignment: Qt.AlignCenter
		Layout.leftMargin: 16
		Layout.rightMargin: 16

		font.family: STYLE.g_FontName
		font.weight: 800
		font.pixelSize: 13
		color: this.selected? PowerService.activeColor : "#282339"
		Behavior on color {
			PropertyAnimation {
				duration: 150
			}
		}

		MouseArea {
			anchors {
				fill: parent
				// slightly shrink the click zone
				leftMargin: 4 /// TODO: here maybe? ^^
				rightMargin: 4
			}
			onClicked: PowerService.menuSelection = PowerService.PowerState.Shutdown
			cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
		}
	}
	Text {
		id: sleep_button
		readonly property bool selected: PowerService.menuSelection == PowerService.PowerState.Sleep

		text: "SLEEP"
		Layout.fillWidth: false
		Layout.alignment: Qt.AlignCenter
		Layout.leftMargin: 16
		Layout.rightMargin: 16

		font.family: STYLE.g_FontName
		font.weight: 800
		font.pixelSize: 13
		color: this.selected? PowerService.activeColor : "#282339"
		Behavior on color {
			PropertyAnimation {
				duration: 150
			}
		}

		MouseArea {
			anchors {
				fill: parent
				// slightly shrink the click zone
				leftMargin: 4 /// TODO: here maybe? ^^
				rightMargin: 4
			}
			onClicked: PowerService.menuSelection = PowerService.PowerState.Sleep
			cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
		}
	}
	Text {
		id: cancel_button
		readonly property bool selected: PowerService.menuSelection == PowerService.PowerState.Persist

		text: "CANCEL"
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignCenter
		Layout.leftMargin: 16
		Layout.rightMargin: 16

		font.family: STYLE.g_FontName
		font.weight: 800
		font.pixelSize: 13
		color: this.selected? PowerService.activeColor : "#282339"
		Behavior on color {
			PropertyAnimation {
				duration: 150
			}
		}

		MouseArea {
			anchors {
				fill: parent
				// slightly shrink the click zone
				leftMargin: 4 /// TODO: here maybe? ^^
				rightMargin: 4
			}
			onClicked: PowerService.menuSelection = PowerService.PowerState.Persist
			cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
		}
	}
}
