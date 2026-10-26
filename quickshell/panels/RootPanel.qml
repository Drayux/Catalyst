import Quickshell
import QtQuick
import QtQuick.Effects

import Niri

import "root/"
import "../vars"

Scope {
	required property var modelData

	// TODO: This possibly might give us no main panel if the screens get weird.
	// Consider defaulting to true and only setting false if both are defined.
	property var mainScreen
	readonly property bool mainPanel: mainScreen == modelData

	Item {
		id: _RO
		readonly property real topRadius: OPTS.isTopBar? 0 : STYLE.g_MainBorderRadius
		readonly property real bottomRadius: OPTS.isTopBar? STYLE.g_MainBorderRadius : 0
		readonly property var screen: modelData
		readonly property int sideMargin: 200
	}

	// TODO: I think the "singleton" portion is held by the plugin interally
	// Thus, this should be the correct implementation for the variants...but 
	// I would like to confirm that assertion
	Niri {
		id: service_Niri
		Component.onCompleted: connect()
		onConnected: console.info("Connected to niri")
		onErrorOccurred: function(error) {
			console.error("Error connecting to niri:", error)	
		}
	}

	/* === VISIBLE COMPONENTS === */

	Loader {
		active: true
		sourceComponent: PanelWindow {
			id: panel_Root

			// 0.2.1 does not have the overview value, so we add an extra check
			visible: (service_Niri.overview? !service_Niri.overview.isOpen : true)
			color: "transparent"
			margins {
				left: STYLE.bar_EdgeMargin
				right: STYLE.bar_EdgeMargin
				// top: (service_Niri.overview? !service_Niri.overview.isOpen : true) ?
					// 0 : -STYLE.bar_Height
			}
			anchors {
				top: OPTS.isTopBar
				left: true
				right: true
				bottom: !(OPTS.isTopBar)
			}
			implicitHeight: STYLE.bar_Height
			screen: _RO.screen

			/* --- BASE --- */
			Rectangle {
				anchors.fill: parent
				color: "transparent"

				/* -- BACKGROUND -- */
				MultiEffect {
					// Base rect is rendered when gifBackground is FALSE
					Rectangle {
						id: obj_BackgroundShape

						visible: false
						anchors.fill: parent
						color: STYLE.color_Base
						layer.enabled: true

						topLeftRadius: _RO.topRadius
						topRightRadius: _RO.topRadius
						bottomLeftRadius: _RO.bottomRadius
						bottomRightRadius: _RO.bottomRadius
					}

					// Loader item is rendered when gifBackground is TRUE
					Loader {
						id: obj_GifBackground

						active: OPTS.gifBackground
						anchors.fill: parent
						visible: false

						// Item wrapper to offset source gif before applying effects (corner mask)
						sourceComponent: Item {
							clip: true
							AnimatedImage {
								source: "../icons/cyber.gif"
								width: parent.width
								y: -STYLE.bar_BackgroundOffset
								fillMode: Image.PreserveAspectCrop
								smooth: false // source is pixel art so we want to keep the pixels
								speed: 0.80
							}
						}
					}

					anchors.fill: parent
					opacity: OPTS.gifBackground?
						STYLE.bar_GifBackgroundOpacity : STYLE.bar_BackgroundOpacity

					maskEnabled: OPTS.gifBackground
					source: OPTS.gifBackground?
						obj_GifBackground : obj_BackgroundShape
					maskSource: obj_BackgroundShape
					maskThresholdMin: 0.5 // cleanup tiny bit of bg x border underhang
					maskSpreadAtMin: 1.0
				}

				/* -- CONTENTS -- */
				Status {
					position: TYPES.TilePosition.Left
					sideMargin: _RO.sideMargin / 2
				}

				Dock {
					// TODO: Special positioning stuff for secondary screens
					// position: TYPES.TilePosition.Center

					position: TYPES.TilePosition.Right
					sideMargin: _RO.sideMargin
					activeDisplay: panel_Root.screen.name
				}

				/* import "../tiles" // TODO: Remove this when done testing
				ChipTile {
					position: TYPES.TilePosition.Left
					x: 30
					color: "green"

					height: parent.height
					implicitWidth: 40

					ChipTile {
						color: "red"
						position: parent.position
						implicitWidth: 20
						height: parent.height
					}
				} */

				/* -- BORDER -- */
				Rectangle {
					anchors {
						fill: parent
						topMargin: OPTS.isTopBar? -STYLE.g_MainBorderRadius : 0
						bottomMargin: OPTS.isTopBar? 0 : -STYLE.g_MainBorderRadius
					}
					color: "transparent"

					topLeftRadius: _RO.topRadius
					topRightRadius: _RO.topRadius
					bottomLeftRadius: _RO.bottomRadius
					bottomRightRadius: _RO.bottomRadius

					border {
						color: STYLE.color_MainBorder
						width: STYLE.bar_BorderWidth
					}
				}
			}
		}
	}
}
