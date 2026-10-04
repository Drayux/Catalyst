import Quickshell
import QtQuick

import "../vars"

/* Implicit width is the width of the complete rectangle inside, computed
 * thus includes the width of the accent relative to the accent angle.
 *
 * The tile will resize to contain content if set, until reaching maxWidth.
 *
 * NOTE: If your spacing is weird, you probably specified width.
 * /// LEAVE WIDTH UNTOUCHED /// */
Item {
	required property int position
	property int implicitWidth: 0
	property int maxWidth: 0
	property bool outside: false // true if pinned to "outside" of bar
	property int radius: 0
	property color color: "transparent"
	property color borderColor
	property int borderWidth

	readonly property bool _skewLeft: OPTS.isTopBar?
		position == TYPES.TilePosition.Right
		: position == TYPES.TilePosition.Left
	readonly property bool _skewRight: OPTS.isTopBar?
		position == TYPES.TilePosition.Left
		: position == TYPES.TilePosition.Right
	readonly property int skewAngle: {
		var mult = 0;
		if (_skewLeft) mult = -1;
		else if (_skewRight) mult = 1;
		return mult * STYLE.g_SkewAngle;
	}

	readonly property var _internalWidth: children[1]? children[1].width : 0
	readonly property int contentWidth: {
		var w = (_internalWidth > implicitWidth) ?
			_internalWidth : implicitWidth;
		if (maxWidth <= 0) return w;
		return (w > maxWidth) ? maxWidth : w;
	}
	readonly property int accentWidth: STYLE.g_SkewScalar * height
	readonly property int totalWidth: accentWidth + contentWidth

	width: contentWidth
	// clip: true // should be false; handy to see the bounding box

	/* -- child[0] -- */
	Rectangle {
		id: tile

		/* These are weird because the a tile on the left should squew right if
		 * anchored to the top, or left if anchored to the bottom. */
		readonly property bool _topExposed: OPTS.isTopBar !== parent.outside
		readonly property int _radius: parent.radius
		readonly property int _skewAngle: parent.skewAngle

		width: parent.totalWidth
		anchors {
			left: parent._skewLeft? parent.left : undefined
			right: parent._skewRight? parent.right : undefined
			top: parent.top
			bottom: parent.bottom
		}

		antialiasing: true
		transform: Shear {
			xAngle: tile._skewAngle
		}
		color: parent.color
		border {
			width: parent.borderWidth
			color: parent.borderColor
		}

		/* If centered, both exposed corners are rounded */
		topLeftRadius: parent._skewLeft?
			(_topExposed? _radius : 0) : 0
		topRightRadius: parent._skewRight?
			(_topExposed? _radius : 0) : 0
		bottomLeftRadius: parent._skewRight?
			(_topExposed? 0 : _radius) : 0
		bottomRightRadius: parent._skewLeft?
			(_topExposed? 0 : _radius) : 0
	}
}
