import Quickshell
import QtQuick
import QtQuick.Layouts

Rectangle {
	property int wsMargin: 16

	implicitWidth: ws_list.width + wsMargin * 2
	height: parent.height / 1.3333
	color: "transparent"

	Rectangle { // Workspaces background
		width: parent.width
		height: parent.height

		antialiasing: true
		transform: Shear {
			xAngle: -24
		}
		bottomRightRadius: 10

		color: "#121221"
		// opacity: 0.66667
		opacity: 0.50
	}

	Rectangle {
		width: parent.width
		height: parent.height

		color: "transparent"

		antialiasing: true
		transform: Shear {
			xAngle: -24
		}
		border.pixelAligned: false
		border.color: "#3F395D" // Niri is "#393552" try to visually match
		border.width: root.barBorder
		bottomRightRadius: 10

		RowLayout {
			id: ws_list

			anchors {
				left: parent.left
				leftMargin: wsMargin
				verticalCenter: parent.verticalCenter
			}
			spacing: -1.5
			height: parent.height

			Repeater {
				// id: ws_list_icons
				model: niri.workspaces // niri: Global import in shell.qml

				Rectangle {
					width: 36
					height: parent.height
					antialiasing: true
					radius: 5

					color: model.isActive ? "#3F395D" : "transparent"
					// visible: model.output == "DP-2"
					opacity: model.output == "DP-2" ? 1.0 : 0.5

					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						onClicked: niri.focusWorkspaceById(model.id)
					}

					Text {
						anchors.centerIn: parent
						anchors.horizontalCenterOffset: -3.5
						text: model.index

						// color: "#93cee9"
						color: model.isActive ? "#d4a1e7" : "#93cee9"
						font {
							family: "JetBrainsMono Nerd Font"
							pixelSize: 17
							weight: 800
							letterSpacing: -0.20
						}
						transform: Shear {
							// Slightly unslant the text
							xAngle: 15
						}
					}
				}
			}
		}
	}
}
