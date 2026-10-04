// TODO: This item has a lot of hard-coded magic numbers for sizing and
// positioning as a side effect of the tweaking necessary to get it to look
// right. At some point, it would be nice to derive these values appropriately.

import Quickshell
import QtQuick
import QtQuick.Layouts

Rectangle {
	// 12 here matches 16 in workspaces because of the images not being skewed
	property int trayMargin: 12

	implicitWidth: app_list.width + trayMargin * 3.25 // 3x: account for icons not skewed
	height: parent.height / 1.3333
	color: "transparent"

	Rectangle { // App tray background
		width: parent.width
		height: parent.height

		// preferredRendererType: Shape.CurveRenderer
		antialiasing: true
		transform: Shear {
			xAngle: 24
		}
		bottomLeftRadius: 10

		color: "#121221"
		// opacity: 0.66667
		opacity: 0.50
	}

	Rectangle {
		width: parent.width
		height: parent.height

		color: "transparent"

		// preferredRendererType: Shape.CurveRenderer
		antialiasing: true
		transform: Shear {
			xAngle: 24
		}
		border.pixelAligned: false
		border.color: "#3F395D" // Niri is "#393552" try to visually match
		border.width: root.barBorder
		bottomLeftRadius: 10
	}

	RowLayout {
		id: app_list

		anchors {
			right: parent.right
			rightMargin: trayMargin
			verticalCenter: parent.verticalCenter
		}
		spacing: 4
		height: parent.height

		Repeater {
			model: niri.windows // niri: Global import in shell.qml

			Rectangle {
				// Do this whole shenanigan so the click space is slightly larger
				color: "transparent"
				height: parent.height
				width: parent.height + 4

				Rectangle {
					anchors.fill: parent
					anchors.leftMargin: -9
					anchors.rightMargin: 3
					antialiasing: true
					transform: Shear {
						xAngle: 24
					}
					radius: 5

					color: model.isFocused ? "#3F395D" : "transparent"
					// color: "#3F395D"
					// opacity: model.isFocused ? 1.0 : 0.0

					// color: "red"
					// opacity: 0.5
				}

				Image {
					anchors.centerIn: parent

					source: model.iconPath ? "file://" + model.iconPath : ""
					sourceSize.width: parent.height - 5
					sourceSize.height: parent.height - 5
					visible: model.iconPath !== ""
					smooth: true
				}

				// Fallback for missing icons (TODO)
				Rectangle {
					width: 24
					height: 24
					color: "red"
					visible: model.iconPath === ""
					radius: 4
				}

				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: niri.focusWindow(model.id)
				}
			}
		}
	}
}
