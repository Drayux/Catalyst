import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.VectorImage
import QtQuick.Effects

Rectangle {
	width: power_actions.width + power_button.width
	height: parent.height

	color: "transparent"

	Rectangle { // power actions background
		id: power_actions
		enabled: false // init state

		anchors.bottom: parent.bottom
		anchors.bottomMargin: -root.barBorder
		anchors.right: power_button.left

		readonly property int originalWidth: 250;
		width: 0
		height: parent.height / 1.2

		antialiasing: true
		transform: Shear {
			xAngle: -24
		}

		color: "#3F395D"
		Behavior on width {
			PropertyAnimation {
				duration: 350
				easing.amplitude: 2.0
				easing.type: Easing.InOutQuart
			}
		}

		function acceptAction() {
			// Menu open, perform steps to close / invoke power-state if set
			if (this.enabled) {
				this.enabled = false
				this.width = 0
				fade_out_delay.duration = 0
				power_action_buttons.opacity = 0.0
				power_action_buttons.spacing = -20

				if (cancel_button.selected) {
					// reset the color just in case we get flipped
					// (shouldn't happen but i'm not quite sure how race conditions are handled rn)
					power_action_icon.activeColor = "#d4a1e7"
					cancel_button.selected = false // just so it looks the same as the others...
					// console.log("power action cancelled")
				}
				else if (sleep_button.selected) {
					sleep_button.selected = false // in case something goes wrong sleeping
					console.info("Invoking sleep command")
					Quickshell.execDetached(["power-state", "sleep"])
				}
				else if (poweroff_button.selected) {
					poweroff_button.selected = false // in case something goes wrong shutting down
					console.info("Invoking shutdown command")
					Quickshell.execDetached(["power-state", "shutdown"])
				}
			}
			// Menu closed, perform steps to open
			else {
				fade_out_delay.duration = 200
				power_action_buttons.opacity = 1.0
				power_action_buttons.spacing = 20
				power_action_buttons.selectOption(cancel_button)
				this.enabled = true
				this.width = originalWidth
			}
		}
	}

	RowLayout {
		id: power_action_buttons

		anchors.fill: parent
		anchors.rightMargin: 54
		anchors.leftMargin: 20
		spacing: -20

		// I'm not actually a genius
		// this just looks sick as fuck by accident
		opacity: 0.0
		Behavior on opacity {
			SequentialAnimation {
				PauseAnimation {
					id: fade_out_delay
					duration: 200
				}
				PropertyAnimation { duration: 200 }
			}
		}
		Behavior on spacing {
			PropertyAnimation {
				// finish just before the container is full size so it doesn't
				// look like it's lagging
				duration: 280
			}
		}

		readonly property font sharedFont: ({
			family: "JetBrainsMono Nerd Font",
			pixelSize: parent.height / 2.8,
			weight: 700,
			letterSpacing: -0.25,
		});

		// programattically, better solutions certainly exist, but this is
		// good enough for now since there's only three buttons
		function selectOption(btn) {
			if (btn == poweroff_button) {
				cancel_button.selected = false
				sleep_button.selected = false
				poweroff_button.selected = true
			}
			else if (btn == sleep_button) {
				cancel_button.selected = false
				poweroff_button.selected = false
				sleep_button.selected = true
			}
			else {
				poweroff_button.selected = false
				sleep_button.selected = false
				cancel_button.selected = true
			}

			power_action_icon.activeColor = btn.activeColor
		}

		Text {
			id: poweroff_button
			property bool selected: false
			readonly property color activeColor: "#ea9a97"

			text: "POWEROFF"
			Layout.fillWidth: false
			Layout.preferredWidth: 64
			Layout.alignment: Qt.AlignBottom
			Layout.bottomMargin: 4

			font: parent.sharedFont
			color: this.selected? this.activeColor : "#121221"
			Behavior on color {
				PropertyAnimation {
					duration: 150
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: power_action_buttons.selectOption(parent)
				cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
			}
		}
		Text {
			id: sleep_button
			property bool selected: false
			readonly property color activeColor: "#d4a1e7"

			text: "SLEEP"
			Layout.fillWidth: false
			Layout.preferredWidth: 44
			Layout.alignment: Qt.AlignBottom
			Layout.bottomMargin: 4

			font: parent.sharedFont
			color: this.selected? this.activeColor : "#121221"
			Behavior on color {
				PropertyAnimation {
					duration: 150
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: power_action_buttons.selectOption(parent)
				cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
			}
		}
		Text {
			id: cancel_button
			property bool selected: true
			readonly property color activeColor: "#93cee9"

			text: "CANCEL"
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignBottom
			Layout.bottomMargin: 4

			font: parent.sharedFont
			color: this.selected? this.activeColor : "#121221"
			Behavior on color {
				PropertyAnimation {
					duration: 150
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: power_action_buttons.selectOption(parent)
				cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
			}
		}
	}

	Rectangle {
		id: power_button

		width: parent.height + 19
		height: parent.height + root.barBorder
		y: -root.barBorder
		anchors.right: parent.right
		antialiasing: true
		transform: Shear {
			xAngle: -24
		}

		color: "#121221"

		border.pixelAligned: false
		border.color: "#3F395D" // Niri is "#393552" try to visually match
		border.width: root.barBorder
		topLeftRadius: 5
		bottomRightRadius: 5

		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: power_actions.acceptAction()
		}
	}

	VectorImage {
		id: power_action_icon

		property color activeColor: "#d4a1e7" // cancel color on init

		source: "../icons/power.svg"
		width: parent.height - 16
		height: parent.height - 16
		y: 5
		anchors.right: parent.right
		anchors.rightMargin: 26
		preferredRendererType: VectorImage.CurveRenderer

		layer.enabled: true
		layer.effect: MultiEffect {
			brightness: 1.0
			colorization: 1.0
			colorizationColor: power_actions.enabled? power_action_icon.activeColor : "#93cee9"
			Behavior on colorizationColor {
				PropertyAnimation {
					duration: 150
				}
			}
		}
	}
}
