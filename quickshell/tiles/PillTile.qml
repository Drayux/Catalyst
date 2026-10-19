import Quickshell
import QtQuick

import "../tiles"
import "../vars"

/* PillTile describes an expandable "pill" shape mostly used for the status
 * component. It may be displayed in a collapsed format or an expanded one for
 * pertinent information. Use the `content` property to declare a widget
 * that will be displayed. Said widget needs to have a width defined so that
 * the pill can be sized correctly. */

Item {
	id: root

	required property int position
	property int radius: STYLE.g_AccentBorderRadius /// TODO: style var
	property Component label
	property Component content

	// Simpler version of the chiptile logic
	// (for now, can be changed if I have reason, of course)
	readonly property bool _skewLeft: position != TYPES.TilePosition.Right
	readonly property bool _skewRight: !_skewLeft
	readonly property int _boxExpand: STYLE.g_SkewScalar * height
	readonly property int _contentVisible: obj_content.width > 0
	
	width: base.width + container.width
		- (_contentVisible? _boxExpand / 2 : 0)
	// ^^ The goal is to center the chip on the edge of the "target width"
	//
	// This is so that the label component appears centered whether the
	// tile is expanded or not, without shifting.
	//
	// Thus, we need to simultaneously track the actual rendered width as
	// well as specify a shorter width so that it overlaps the content
	// component.

	/* -- child[0] - background container -- */
	/* NOTE: Currently duplicated the end so the border is overtop.
	 * Should be reasonably doable to give the label its own border by placing
	 * this at the bottom and then doing the clock trick, but I won't
	 * implement that unless I know I want it. */
	Rectangle {
		id: background

		anchors.fill: parent

		topLeftRadius: parent.radius
		bottomLeftRadius: parent.radius
		topRightRadius: parent.radius
		bottomRightRadius: parent.radius
		color {
			r: STYLE.color_TrayBackground.r
			g: STYLE.color_TrayBackground.g
			b: STYLE.color_TrayBackground.b
			a: STYLE.dock_TrayOpacity
		}
	}

	/* -- child[1] - < CONTENT > -- */
	// Rectangle { // for debugging
		// color: "yellow"
	Item {
		id: container

		anchors {
			left: _skewRight? parent.left : undefined
			right: _skewLeft? parent.right : undefined
		}
		height: parent.height
		width: obj_content.width
		clip: true

		Behavior on width {
			PropertyAnimation {
				duration: 240 /// TODO: style var
				// easing.type: Easing.InOutCubic
				easing.type: Easing.OutBack
			}
		}

		Loader {
			id: obj_content
			anchors {
				left: _skewRight? parent.left : undefined
				right: _skewLeft? parent.right : undefined
				top: parent.top
				bottom: parent.bottom
			}

			active: true
			sourceComponent: content
		}
	}

	/* -- child[2] - base tile -- */
	Item {
		id: base

		readonly property int labelWidth: label? obj_label.width : 0
		readonly property int minWidth: height * 2
		readonly property int targetWidth: ((labelWidth > minWidth) ? labelWidth : minWidth)

		anchors {
			left: _skewLeft? parent.left : undefined
			right: _skewRight? parent.right : undefined
		}
		height: parent.height
		width: targetWidth

		Rectangle {
			width: parent.targetWidth / 2
			height: parent.height
			color: STYLE.color_ClockBackground /// TODO: Maybe different var name
			// border {
				// width: 3
				// color: parent.color
			// }

			topLeftRadius: root.radius
			bottomLeftRadius: root.radius

			// Filler rect
			// This guy only appears if there's no content to display
			Rectangle {
				anchors.left: parent.right
				width: parent.width - (_contentVisible? (_boxExpand / 4) : 0)
				height: parent.height
				color { /// TODO: Maybe different var name
					r: STYLE.color_ClockBackground.r
					g: STYLE.color_ClockBackground.g
					b: STYLE.color_ClockBackground.b
					// a: _contentVisible? 0.0 : 1.0
					a: 1.0
				}

				Behavior on width {
					PropertyAnimation {
						duration: 120 /// TODO: another one ^^
						easing.type: Easing.OutCubic
					}
				}

				topRightRadius: root.radius
				bottomRightRadius: root.radius

				ChipTile {
					// visible: false
					anchors {
						right: parent.right
						rightMargin:  _contentVisible? _boxExpand / 4 : _boxExpand * 2 
						// rightMargin:  _contentVisible? 0 : _boxExpand * 2 
					}
					implicitWidth: _boxExpand
					height: parent.height
					position: root.position

					// borderWidth: 3
					// borderColor: root.color
					color { /// TODO: Maybe different var name
						r: STYLE.color_ClockBackground.r
						g: STYLE.color_ClockBackground.g
						b: STYLE.color_ClockBackground.b
						a: _contentVisible? 1.0 : 0.0
						// a: 1.0
					}

					// Behavior on color.a {
						// PropertyAnimation {
							// duration: 240 /// TODO: another one ^^
							// easing.type: Easing.OutCubic
						// }
					// }
					Behavior on anchors.rightMargin {
						PropertyAnimation {
							duration: 120 /// TODO: another one ^^
							easing.type: Easing.OutCubic
							// easing.type: Easing.Linear
						}
					}
				}
			}
		}

		Loader {
			id: obj_label
			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top
				bottom: parent.bottom
			}

			active: true
			sourceComponent: label
		}
	}

	// TODO: Border around the whole thing!
	// Rectangle {
		// id: border

		// anchors.fill: parent

		// topLeftRadius: parent.radius
		// bottomLeftRadius: parent.radius
		// topRightRadius: parent.radius
		// bottomRightRadius: parent.radius
		// color: "transparent"
		// border {
			// width: STYLE.g_AccentBorderWidth /// TODO: style var
			// width: STYLE.g_MainBorderWidth /// TODO: style var
			// color: STYLE.color_AccentBorder /// TODO: style var
		// }
	// }
}
