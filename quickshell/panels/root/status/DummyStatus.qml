import Quickshell
import QtQuick

import "../../../tiles"
import "../../../vars"

PillTile {
	id: obj_DummyStatusRoot

	position: parent.position
	height: parent.height

	property bool contentVisible: false

	label: IconTile {
		implicitHeight: parent.height 
		iconName: "sources"
		iconColor: "#93cee9"
		iconMargin: 8
	}

	content: Rectangle {
		width: obj_DummyStatusRoot.contentVisible? 100 : 0
		color: "transparent"
	}

	// NumberAnimation on contentWidth {
		// from: 0; to: 100
		// duration: 500
		// easing.type: Easing.InOutQuart
	// }

	// property int test: 0
	MouseArea {
		anchors.fill: parent
		// onClicked: {
			// parent.test++;
			// if (parent.test == 1) dummy.contentText = "hello";
			// else if (parent.test == 2) dummy.contentText = "world";
			// else if (parent.test == 3) dummy.contentText = "";
			// else if (parent.test == 4) dummy.contentText = "OOGIE BOOGIE BOOGIE WOOGIE";
			// else {
				// dummy.contentText = ""
				// parent.test = 0;
			// }
		// }
		onClicked: {
			parent.contentVisible = !parent.contentVisible
		}
	}
}
