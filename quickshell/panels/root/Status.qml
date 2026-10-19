import Quickshell
import QtQuick

import "status/"

import "../../tiles" // TODO: check if I can remove this!
import "../../vars"

/*
 * This item holds all of the dynamic "system status" items in an ordered
 * list that grows. This includes simple integrations like wifi and bluetooth,
 * but also items with detailed status, such as the active media, system
 * notifications, etc.
 */

Item {
	id: component_Status
	required property int position
	property int sideMargin: 0

	anchors {
		horizontalCenter: (position == TYPES.TilePosition.Center) ?
			parent.horizontalCenter : undefined
		left: (position == TYPES.TilePosition.Left) ?
			parent.left : undefined
		right: (position == TYPES.TilePosition.Right) ?
			parent.right : undefined

		leftMargin: sideMargin
		rightMargin: sideMargin
	}

	/* Set the component to fill the entire height of the parent (the root bar)
	 * so that its children may have mismatched heights */
	height: parent.height
	width: obj_StatusContent.width

	/* placeholder for child content widget */
	Row {
		id: obj_StatusContent

		anchors.verticalCenter: parent.verticalCenter
		anchors.verticalCenterOffset: STYLE.bar_BorderWidth / -2.0
		width: implicitWidth
		height: STYLE.status_ItemHeight
		spacing: 12

		readonly property int position: TYPES.TilePosition.Left

		NotificationStatus { }
		MediaStatus { }
		// DummyStatus { }

		// Rectangle {
			// width: 80
			// height: parent.height
			// color: "transparent"
		// }
	}
}
