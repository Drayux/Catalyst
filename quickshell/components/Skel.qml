import Quickshell
import QtQuick
import QtQuick.Layouts

import "../vars"

/*
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
*/

Item {
	id: component_Dock
	required property int direction
	required property int implicitHeight

	/* DEV NOTE:
	 * Usually we'd want the parent to specify the position of its children.
	 * However, these elements are composite components intended for the bar,
	 * thus, they are given the required direction property.
	 *
	 * This property can be used to resolve the positioning, such that I need
	 * specify only one property in the parent, rather than a matching pair. */
	anchors {
		horizontalCenter: (direction == TYPES.TileDirection.Center) ?
			parent.horizontalCenter : undefined
		left: (direction == TYPES.TileDirection.Left) ?
			parent.left : undefined
		right: (direction == TYPES.TileDirection.Right) ?
			parent.right : undefined
		top: OPTS.isTopBar? parent.top : undefined
		bottom: OPTS.isTopBar? undefined : parent.bottom
	}

	height: implicitHeight
	width: obj_DockLayout.implicitWidth;

	/* Composite clock shape container */
	RowLayout {
		id: obj_DockLayout

		Rectangle {
			// anchors.fill: parent
			height: component_Dock.implicitHeight
			width: height * 2
			color: {
				return "red"
			}
		}
		Rectangle {
			// anchors.fill: parent
			height: component_Dock.implicitHeight
			width: height
			color: "blue"
		}
	}
}
