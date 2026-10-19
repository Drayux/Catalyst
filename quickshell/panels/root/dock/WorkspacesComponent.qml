import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../../tiles"
import "../../../vars"

RowLayout {
	property bool inline: false // true if merged with the tray
	property var refTile: parent // Component assumed child of a ChipTile, populate if not

	height: parent.height /// TODO: does this or obj_Workspace.height make more sense?
	spacing: 0

	ChipTile { // spacer
		visible: !inline
		Layout.fillHeight: true
		// Layout.leftMargin: refTile.position == TYPES.TilePosition.Left? 14 : 0
		// Layout.rightMargin: refTile.position == TYPES.TilePosition.Right? 14 : 0
		Layout.leftMargin: 14
		Layout.rightMargin: 14
		position: refTile.position
		implicitWidth: 4 /// TODO: Possible spot for a global style var
		color {
			r: STYLE.color_Accent.r
			g: STYLE.color_Accent.g
			b: STYLE.color_Accent.b
			a: STYLE.dock_SpacerOpacity
		}
	}
	Repeater {
		model: service_Niri.workspaces
		delegate: Rectangle {
			readonly property bool _sameScreen: model.output == component_Dock.activeDisplay

			width: 40 /// 36
			height: parent.height

			antialiasing: true
			// radius: 4 /// TODO: Possible config option, though it doesn't
			/// seem to visually match the tray rounding?

			visible: parent.inline? (!component_Dock.activeDisplay || _sameScreen)
				: (!component_Dock.activeDisplay || !OPTS.onAllScreens || _sameScreen)
			opacity: _sameScreen? 1.0 : 0.5
			color {
				r: STYLE.color_Accent.r
				g: STYLE.color_Accent.g
				b: STYLE.color_Accent.b
				// a: model.isActive ? 1.0 : 0.0 /// TODO: also here...if I ever want it ^^
				a: model.isActive ? 1.0 : 0.625 /// TODO: also here...if I ever want it ^^
			}
			transform: Shear {
				xAngle: refTile.skewAngle
			}

			Behavior on color.a {
				PropertyAnimation {
					duration: 125 /// TODO: another one ^^
					easing.type: Easing.Linear
				}
			}

			Text {
				anchors.centerIn: parent
				anchors.horizontalCenterOffset: refTile._skewLeft? -2.75 : 1.75
				text: model.index

				color: model.isActive?
				STYLE.color_ActiveText : STYLE.color_SelectText
				font {
					family: STYLE.g_FontName
					/// TODO: Possible spot for a global style var
					pixelSize: 17
					weight: 800
					letterSpacing: -0.20
					///
				}
				transform: Shear {
					// slightly unslant the text
					xAngle: refTile.skewAngle / -2
				}
			}
			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: service_Niri.focusWorkspaceById(model.id)
			}
		}
	}
	ChipTile { // spacer
		Layout.fillHeight: true
		position: refTile.position

		// NOTE: In inline mode, this width doesn't seem to quite add up at a
		// glance. I think this is because the border overlaps it, then paired
		// with the offset to hide the border, the first borderWidth pixels
		// will never be seen.
		//
		// Also, the leftMargin is because we are not using chip tiles here,
		// so the spacer tile overlaps when the icon does not. (TODO) It might
		// be prudent to make this symmetrical with the other spacers (here and
		// TrayComponent) but it's not priority right now.
		implicitWidth: 3 /// TODO: another possible setting
		Layout.leftMargin: 11 /// TODO: This can be calculated with g_SkewScalar

		outside: !inline
		radius: _RO.trayRadius
		color {
			r: STYLE.color_Accent.r
			g: STYLE.color_Accent.g
			b: STYLE.color_Accent.b
			// a: STYLE.dock_SpacerOpacity
			a: 1.0
		}
	}
}
