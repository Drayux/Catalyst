import Quickshell
import QtQuick

import "../../../services"
import "../../../tiles"
import "../../../vars"

PillTile {
	id: obj_MediaStatusRoot

	position: parent.position
	// position: TYPES.TilePosition.Right
	height: parent.height

	label: IconTile {
		implicitHeight: parent.height 
		iconName: "music"
		iconColor: "#93cee9"
		iconMargin: 10
	}

	content: Row {
		readonly property bool isContent: MediaService.focusedPlayer !== null
		visible: isContent 
		width: isContent? implicitWidth : 0
		ChipTile {
			id: obj_Artist
			implicitWidth: text_Artist.width + 36
			position: obj_MediaStatusRoot.position
			color: STYLE.color_Accent
			height: parent.height

			Text {
				id: text_Artist

				anchors.centerIn: parent
				anchors.horizontalCenterOffset: 4
				text: MediaService.focusedPlayer !== null ?
					MediaService.focusedPlayer.trackArtists : ""
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
			id: obj_Track
			width: (text_Track.width > 0) ? text_Track.width + 50 : 0
			height: parent.height
			Text { // status text
				id: text_Track

				anchors.centerIn: parent
				text: MediaService.focusedPlayer !== null ?
					MediaService.focusedPlayer.trackTitle : ""
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
				color: MediaService.isPlaying ? "#93cee9"
					: (MediaService.isMuted ? "#3F395D" : "#d4a1e7")
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
		cursorShape: Qt.PointingHandCursor
		acceptedButtons: Qt.LeftButton | Qt.MiddleButton
		onClicked: (event) => {
			if (event.button == Qt.LeftButton) {
				MediaService.togglePlaying();
			}
			else {
				// Middle click action -- "see more" (here, bring the player to attention)
				// TODO: Possibly more things I could do here, is this intuitive
				// considering that middle click on the dock closes windows?
				MediaService.focusedPlayer?.raise();
			}
		}
		onWheel: (event) => {
			if (event.angleDelta.y > 0) {
				// scroll up
				MediaService.adjustVolume(0.1);
			}
			else if (event.angleDelta.y < 0) {
				// scroll down
				MediaService.adjustVolume(-0.1);
			}
		}
	}
}
