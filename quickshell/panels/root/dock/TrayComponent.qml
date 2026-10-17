import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../../tiles"
import "../../../vars"

RowLayout {
	property int position: obj_Tray.position

	height: parent.height /// TODO: does this or obj_Tray.height make more sense?
	anchors {
		// don't use fill, it skips calculating a width (and becomes 0)
		left: parent._skewRight? parent.left : undefined
		right: parent._skewLeft? parent.right : undefined
		// leftMargin: -_RO.trayBorder // obsolete, using spacers instead
		// rightMargin: -_RO.trayBorder
	}
	spacing: 10

	/* NOTE (for future me)
	 * The spacing is implemented slightly differently between the Tray
	 * and Workspace components. This is mostly a result of not realizing
	 * that Layout.<side>Margin is a thing. BUT, I think it's fine (at
	 * least, the current implementation is not spaghetti.)
	 *
	 * Workspace doesn't pull away mouse focus, so keeping the overlap
	 * is relatively intuitive. Extra click spacing is nice when it does
	 * pull the mouse.
	 *
	 * The ideal is likely 0 spacing, item width is absolute, then the
	 * "overlap" negative margins can be as well. Finally, squeeze into
	 * the spacers with the aformentioned Layout property.
	 * >> Alas, this is very low-priority right now */
	ChipTile { // spacer
		Layout.fillHeight: true
		implicitWidth: 6 /// TODO: Possible spot for a global style var
		position: parent.position
		outside: true
		radius: _RO.trayRadius
		color {
			r: STYLE.color_Accent.r
			g: STYLE.color_Accent.g
			b: STYLE.color_Accent.b
			a: STYLE.dock_SpacerOpacity
		}
	}
	Repeater {
		model: service_Niri.windows
		delegate: Item {
			readonly property bool _sameScreen: {
				// TODO if possible (??)
				// https://github.com/imiric/qml-niri
				// model.isFocused
				true
			}
			visible: _sameScreen

			height: parent.height - 2 // scale the icon down a tiny bit
			width: parent.height + 4 /// TODO: here too ^^

			Rectangle {
				/* "Manual" (not ChipTile) skew so we need to do some extra math */
				// offset by half of H*tan(skew)===W on either side to visually
				readonly property real _shiftAmount: parent.height * -STYLE.g_SkewScalar * 0.5
				/* *** */
				property bool hovered: false

				anchors {
					fill: parent
					rightMargin: (obj_Tray._skewRight? -_shiftAmount : _shiftAmount)
						- (2 * _RO.trayBorder)
					leftMargin: (obj_Tray._skewLeft? -_shiftAmount : _shiftAmount)
						- (2 * _RO.trayBorder)
				}

				antialiasing: true
				radius: 2 /// TODO: here also? ^^
				color {
					r: STYLE.color_Accent.r
					g: STYLE.color_Accent.g
					b: STYLE.color_Accent.b
					/// TODO: also here...if I ever want it ^^
					a: model.isFocused? 1.0 : (hovered? 0.625 : 0.0)
				}
				transform: Shear {
					xAngle: obj_Tray.skewAngle
				}

				Behavior on color.a {
					PropertyAnimation {
						duration: 125 /// TODO: another one ^^
						easing.type: Easing.Linear
					}
				}

				MouseArea {
					anchors {
						fill: parent
						// slightly shrink the click zone
						leftMargin: 4 /// TODO: here maybe? ^^
						rightMargin: 4
					}
					acceptedButtons: Qt.LeftButton | Qt.MiddleButton
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onEntered: parent.hovered = true
					onExited: parent.hovered = false
					onClicked: (event) => {
						if (event.button == Qt.MiddleButton) {
							// Middle click action
							service_Niri.closeWindow(model.id)
						}
						else {
							service_Niri.focusWindow(model.id)
						}
					}
				}
			}
			Rectangle { // fallback icon for missing icons
				anchors {
					top: parent.top
					topMargin: 2
					bottom: parent.bottom
					bottomMargin: 2
					horizontalCenter: parent.horizontalCenter
				}
				width: height
				color: "magenta" /// TODO: actual icon, not just a color
				visible: model.iconPath === ""
				radius: 4
			}
			Image {
				anchors {
					fill: parent
					topMargin: 2
					bottomMargin: 2
				}
				source: model.iconPath ? "file://" + model.iconPath : ""
				sourceSize.width: parent.height
				sourceSize.height: parent.height
				fillMode: Image.PreserveAspectFit
				visible: model.iconPath !== ""
			}
		}
	}
	ChipTile { // spacer
		Layout.fillHeight: true
		position: obj_Tray.position
		implicitWidth: 4 /// TODO: another possible setting
		color {
			r: STYLE.color_Accent.r
			g: STYLE.color_Accent.g
			b: STYLE.color_Accent.b
			a: STYLE.dock_SpacerOpacity
		}
	}
}
