import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../tiles"
import "../../vars"

Item {
	id: component_Dock
	required property int position
	property var activeDisplay

	Item {
		id: _RO
		readonly property int position: parent.position
		readonly property int clockBorder: STYLE.g_MainBorderWidth
		readonly property int clockHeight: {
			var _height = STYLE.dock_ClockHeight;
			if (!_height || _height <= 0 || _height > parent.height) {
				// max height by default
				return parent.height;
			}
			return _height;
		}
		readonly property int clockRadius: clockHeight == parent.height?
			0 : (clockHeight == trayHeight ? // pointy if full size
			0 : STYLE.g_AccentBorderRadius) // pointy if tray is same size
		readonly property int trayBorder: STYLE.g_MainBorderWidth
		readonly property int trayHeight: {
			var _height = STYLE.dock_TrayHeight;
			if (!_height || _height <= 0 || _height > clockHeight) {
				// max height by default
				return clockHeight;
			}
			return _height;
		}
		readonly property int trayRadius: trayHeight == parent.height?
			0 : STYLE.g_AccentBorderRadius // pointy if full size
	}

	SystemClock {
		id: service_Clock
		precision: SystemClock.Seconds
	}

	anchors {
		horizontalCenter: (position == TYPES.TilePosition.Center) ?
			parent.horizontalCenter : undefined
		left: (position == TYPES.TilePosition.Left) ?
			parent.left : undefined
		right: (position == TYPES.TilePosition.Right) ?
			parent.right : undefined
	}

	/* DEV NOTE:
	 * The dock is a particularly special component because we want explitly to
	 * center it as though the clock portion is the center of the entire
	 * component.
	 *
	 * Thus, my chosen implementation is to set the component width to only
	 * that of the clock, the tray and workspaces will overhang. This solution
	 * feels scuffed, but it is also compatible with left / right alignments. */
	height: parent.height // height of root bar panel
	width: obj_Clock.width
	clip: false

	/* --- TRAY --- */
	ChipTile {
		id: obj_Tray

		anchors {
			right: position == TYPES.TilePosition.Left? obj_Clock.left : undefined
			rightMargin: -_RO.clockBorder
			left: position == TYPES.TilePosition.Right? obj_Clock.right : undefined
			leftMargin: -_RO.clockBorder
			top: OPTS.isTopBar? component_Dock.top : undefined
			topMargin: -_RO.trayBorder
			bottom: OPTS.isTopBar? undefined : component_Dock.bottom
			bottomMargin: -_RO.trayBorder
			/// TODO: Considering making the above into an option to show the border or not
		}
		position: (component_Dock.position == TYPES.TilePosition.Left) ?
			TYPES.TilePosition.Right : TYPES.TilePosition.Left

		height: _RO.trayHeight + _RO.trayBorder
		implicitWidth: 24 // relatively arbitrary (TODO)
		radius: _RO.trayRadius
		outside: true

		color {
			r: STYLE.color_TrayBackground.r
			g: STYLE.color_TrayBackground.g
			b: STYLE.color_TrayBackground.b
			a: STYLE.dock_TrayOpacity
		}
		borderColor: STYLE.color_AccentBorder
		borderWidth: _RO.trayBorder

		RowLayout {
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
			 * Workspace doesn't necessarily pull the mouse, so keeping the overlap
			 * is relatively intuitive. Extra click spacing is nice when it does
			 * pull the mouse.
			 *
			 * The ideal is likely 0 spacing, item width is absolute, then the
			 * "overlap" negative margins can be as well. Finally, squeeze into
			 * the spacers with the aformentioned Layout property.
			 * >> Alas, this is very low-priority right now */
			ChipTile { // spacer
				Layout.fillHeight: true
				position: obj_Tray.position
				implicitWidth: 4 /// TODO: Possible spot for a global style var
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
							a: model.isFocused? 1.0 : 0.0 /// TODO: also here...if I ever want it ^^
						}
						transform: Shear {
							xAngle: obj_Tray.skewAngle
						}

						Behavior on color.a {
							PropertyAnimation {
								duration: 150 /// TODO: another one ^^
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
							cursorShape: Qt.PointingHandCursor
							onClicked: service_Niri.focusWindow(model.id)
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
	}

	/* --- WORKSPACES --- */
	ChipTile {
		id: obj_Workspace

		// Only visible if placement on right of clock is available
		visible: component_Dock.position == TYPES.TilePosition.Center
		anchors {
			left: obj_Clock.right
			leftMargin: -_RO.clockBorder
			//
			top: OPTS.isTopBar? component_Dock.top : undefined
			topMargin: -_RO.trayBorder
			bottom: OPTS.isTopBar? undefined : component_Dock.bottom
			bottomMargin: -_RO.trayBorder
			/// TODO: Considering making the above an option to show the border or not
		}
		position: TYPES.TilePosition.Right

		height: _RO.trayHeight + _RO.trayBorder
		implicitWidth: 24 // relatively arbitrary since this should never be empty
		radius: _RO.trayRadius
		outside: true

		color {
			r: STYLE.color_TrayBackground.r
			g: STYLE.color_TrayBackground.g
			b: STYLE.color_TrayBackground.b
			a: STYLE.dock_TrayOpacity
		}
		borderColor: STYLE.color_AccentBorder
		borderWidth: _RO.trayBorder

		RowLayout {
			height: parent.height /// TODO: does this or obj_Workspace.height make more sense?
			anchors {
				// don't use fill, it skips calculating a width (and becomes 0)
				left: parent._skewRight? parent.left : undefined
				right: parent._skewLeft? parent.right : undefined
				// leftMargin: -_RO.trayBorder // obsolete, using spacers instead
				// rightMargin: -_RO.trayBorder
			}
			spacing: -1.5

			ChipTile { // spacer
				Layout.fillHeight: true
				Layout.rightMargin: 14
				position: obj_Workspace.position
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

					width: 36
					height: parent.height

					antialiasing: true
					radius: 4 /// TODO: Possible config option, though it doesn't
							  /// seem to visually match the tray rounding?

					visible: !component_Dock.activeDisplay || !OPTS.onAllScreens || _sameScreen
					opacity: _sameScreen? 1.0 : 0.5
					color {
						r: STYLE.color_Accent.r
						g: STYLE.color_Accent.g
						b: STYLE.color_Accent.b
						a: model.isActive? 1.0 : 0.0 /// TODO: also here...if I ever want it ^^
					}
					transform: Shear {
						xAngle: obj_Workspace.skewAngle
					}

					Behavior on color.a {
						PropertyAnimation {
							duration: 150 /// TODO: another one ^^
							easing.type: Easing.Linear
						}
					}

					Text {
						anchors.centerIn: parent
						anchors.horizontalCenterOffset: obj_Workspace._skewLeft? -2.75 : 1.75
						text: model.index

						color: model.isActive?
							STYLE.color_SelectText : STYLE.color_ActiveText
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
							xAngle: obj_Workspace.skewAngle / -2
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
				position: obj_Workspace.position
				implicitWidth: 4 /// TODO: another possible setting
				outside: true
				radius: _RO.trayRadius
				color {
					r: STYLE.color_Accent.r
					g: STYLE.color_Accent.g
					b: STYLE.color_Accent.b
					a: STYLE.dock_SpacerOpacity
				}
			}
		}
	}

	/* --- CLOCK --- */
	// TODO: The left, right, center config needs a bit of love, still
	Rectangle {
		id: obj_Clock

		width: obj_ClockShapeLeft.totalWidth * 2 + obj_ClockContents.width
		height: _RO.clockHeight + _RO.clockBorder
		anchors {
			top: OPTS.isTopBar? parent.top : undefined
			topMargin: -_RO.clockBorder
			bottom: OPTS.isTopBar? undefined : parent.bottom
			bottomMargin: -_RO.clockBorder
		}
		color: "transparent"
		layer.enabled: true

		/* Left side shape */
		ChipTile {
			id: obj_ClockShapeLeft

			// Anchor line is relative to largest contained rect
			anchors.left: obj_Clock.left
			anchors.leftMargin: accentWidth
			position: TYPES.TilePosition.Left

			height: parent.height
			implicitWidth: STYLE.dock_ClockPadding
			radius: _RO.clockRadius
			outside: true

			color: STYLE.color_ClockBackground
			borderWidth: _RO.clockBorder
			borderColor: STYLE.color_ClockBorder
		}
		/* Right side shape */
		ChipTile {
			id: obj_ClockShapeRight

			// Anchor line is relative to largest contained rect
			anchors.right: obj_Clock.right
			anchors.rightMargin: accentWidth
			position: TYPES.TilePosition.Right

			height: parent.height
			implicitWidth: STYLE.dock_ClockPadding
			radius: _RO.clockRadius
			outside: true

			color: STYLE.color_ClockBackground
			borderWidth: _RO.clockBorder
			borderColor: STYLE.color_ClockBorder
		}
		/* Center block */
		Rectangle {
			id: obj_ClockShapeBase

			anchors {
				left: obj_ClockShapeLeft.right
				leftMargin: -_RO.clockBorder
				right: obj_ClockShapeRight.left
				rightMargin: -_RO.clockBorder
			}
			height: parent.height
			// width: obj_ClockContents.width (implied if my math is correct)

			color: STYLE.color_ClockBackground

			// Special stuff to hide the "middle borders"
			clip: true
			Rectangle {
				anchors {
					fill: parent
					leftMargin: -_RO.clockBorder
					rightMargin: -_RO.clockBorder
				}
				color: "transparent"
				border {
					width: _RO.clockBorder
					color: STYLE.color_ClockBorder
				}
			}
		}
	}
	Text {
		id: obj_ClockContents

		anchors.centerIn: obj_Clock
		anchors.verticalCenterOffset: OPTS.isTopBar? -1 : 1

		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 22
		font.weight: 800
		font.letterSpacing: -0.20
		color: STYLE.color_ActiveText
		text: Qt.formatDateTime(service_Clock.date, "HH:mm")
	}
}
