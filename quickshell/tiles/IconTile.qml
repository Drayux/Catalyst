import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.VectorImage

/* Implicit sizes can be used to indicate the the preferred size of the icon.
 * The intended use is to set either implicit width or implicit height and the
 * icon will be scaled to match that dimension.
 *
 * NOTE: If your spacing is weird, width / height was probably set directly.
 * /// LEAVE WIDTH / HEIGHT UNTOUCHED /// */
Item {
	required property string iconName

	property color iconColor: "white"
	property int iconMargin: 0
	property int implicitWidth: 0
	property int implicitHeight: 0

	readonly property string _iconPath: "../icons/" + iconName + ".svg"
	readonly property int _iconSize: (implicitWidth > implicitHeight) ?
		implicitWidth : implicitHeight

	width: _iconSize
	height: _iconSize

	VectorImage { // players (speaker) icon itself
		id: icon

		// TODO: Untested if this works as expected with non-square sources
		// I could also use simply `anchors.centerIn: parent` and manually
		// set a source width and height (parent._iconSize - parent.iconMargin)
		anchors {
			fill: parent
			leftMargin: parent.iconMargin / 2
			rightMargin: parent.iconMargin / 2
			topMargin: parent.iconMargin / 2
			bottomMargin: parent.iconMargin / 2
		}

		source: parent._iconPath
		fillMode: Image.PreserveAspectFit
		preferredRendererType: VectorImage.CurveRenderer

		layer.enabled: true
		layer.effect: MultiEffect {
			brightness: 1.0
			colorization: 1.0
			colorizationColor: parent.iconColor
		}
	}
}
