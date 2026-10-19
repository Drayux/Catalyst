import Quickshell
import QtQuick

import "../../../services"
import "../../../tiles"
import "../../../vars"

PillTile {
	id: obj_NotificationStatusRoot

	position: parent.position
	height: parent.height

	label: IconTile {
		implicitHeight: parent.height 
		iconName: "bell"
		iconColor: "#93cee9"
		iconMargin: 12
	}

	content: Row {
		// visible: isContent 
		// width: isContent? implicitWidth : 0
		ChipTile {
			id: obj_AppName
			implicitWidth: NotificationService.current_App? (text_AppName.width + 36) : 0
			position: obj_NotificationStatusRoot.position
			color: STYLE.color_Accent
			height: parent.height

			Text {
				id: text_AppName

				anchors.centerIn: parent
				anchors.horizontalCenterOffset: 4
				// TODO: Clean this up, just proving it works
				text: NotificationService.current_App || ""
				textFormat: Text.PlainText

				color: "#d4a1e7"
				font {
					family: "JetBrainsMono Nerd Font"
					pixelSize: 10
					weight: 300
					letterSpacing: -0.1
				}
			}
		}
		Item {
			id: obj_Message
			width: NotificationService.current_Message? (text_Message.width + 50) : 0
			height: parent.height
			Text { // status text
				id: text_Message

				anchors.centerIn: parent
				text: NotificationService.current_Message || ""
				textFormat: Text.PlainText

				// TODO: This is slightly bugged. The volume value will be whatever
				// we last set it to, even if that was on a different player.
				// Essentially, mute one player, swap to another that isn't muted,
				// play/pause to set it active, and then the title will be gray
				// when it should be pink. Unfortunately this appears to be a bug
				// with the Quickshell Mpris implementation.
				//
				// I think a workaround to force isMuted to false when the player
				// is swapped would then fail to detect if the new player was
				// already muted, but I could stand to test this.
				color: NotificationService.current_Expired ? "#3F395D" : "#d4a1e7"
				font {
					family: "JetBrainsMono Nerd Font"
					pixelSize: 14
					weight: 600
					letterSpacing: -0.65
				}

				Behavior on color {
					PropertyAnimation {
						duration: 120
						easing.type: Easing.Linear
					}
				}
			}
		}
	}

	MouseArea {
		anchors.fill: parent
		enabled: !!NotificationService.current_Message || !!NotificationService.current_App
		cursorShape: this.enabled? Qt.PointingHandCursor : Qt.ArrowCursor

		onClicked: {
			// TODO: previous notifications panel
			// if (NotificationService.current === null) {
				// return
			// }

			NotificationService.dismissCurrent();
		}
	}
}
