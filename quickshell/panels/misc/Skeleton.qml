import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../vars"

Item {
	id: component_
	required property int position

	anchors {
		horizontalCenter: (direction == TYPES.TileDirection.Center) ?
			parent.horizontalCenter : undefined
		left: (direction == TYPES.TileDirection.Left) ?
			parent.left : undefined
		right: (direction == TYPES.TileDirection.Right) ?
			parent.right : undefined
	}

	/* Set the component to fill the entire height of the parent (the root bar)
	 * so that its children may have mismatched heights */
	height: parent.height
	width: obj_DockLayout.implicitWidth;

	/* placeholder for child content widget */
	RowLayout {
		id: obj_

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

	/* placeholder for base widget */
	Rectangle {
		anchors: {
			top: parent.top
			bottom: parent.bottom
			right: (direction == TYPES.TileDirection.Right) ?
				parent.right : undefined
			left: (direction == TYPES.TileDirection.Left) ?
				parent.left : undefined
		}
	}
}
