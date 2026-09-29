import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.VectorImage
import Quickshell.Services.Notifications // Requires notifications USE flag

// TODO: Menu for expired notifications
// Make the bell icon gray if there are none

Rectangle {
	anchors.bottom: parent.bottom
	anchors.bottomMargin: -root.barBorder

	// 64 is the "empty" size; 34 is the total nonempty margin; 12 is the clipping offset
	// TODO: Consider a maximum width condition
	// readonly property int totalBarWidth: toast_contents.width + bell_icon.width
	readonly property int totalBarWidth: toast_bg.width + bell_icon.width + toast_sender_bg.width
	// width: ((totalBarWidth > 64) ? totalBarWidth : 64) + 12
	width: totalBarWidth + 14
	height: parent.height / 1.2
	clip: true
	color: "transparent"

	Behavior on width {
		PropertyAnimation {
			duration: 350
			easing.amplitude: 2.0
			easing.type: Easing.InOutQuart
		}
	}

	// --- HANDLER LOGIC --- //
	// TODO: Consider alternative logic for urgent notifications
	// (does not expire, pulses between pink and blue, etc.)

	QtObject {
		id: toast_data

		property var current: null
		property bool expired: true // maybe better named !timer_active
			// ^^ as they should always be paired
		property var pending: []
	}
	// TODO: Determine if I can move this into the shell root like Niri (???)
	NotificationServer {
		id: toasts
		onNotification: function(n) {
			// console.info("received notification", n.summary)

			n.tracked = true

			if (toast_data.expired) {
				// destroy old notification
				if (toast_data.current !== null) {
					toast_data.current.expire()
				}

				toast_data.current = n
				toast_data.expired = false // TODO: check for race condition
				toast_timeout.start()
				toast_debounce.start()
			} else {
				toast_data.pending.push(n)
			}
		}
	}
	Timer {
		id: toast_timeout
		interval: 20000
		repeat: false
		onTriggered: {
			// roll to next or indicate expiration
			if (toast_data.pending.length > 0) {
				toast_data.current = toast_data.pending.shift()
				toast_data.expired = false
				toast_timeout.start()
			} else {
				toast_data.expired = true
			}
		}
	}
	Timer {
		id: toast_debounce
		interval: 750
		repeat: false
	}

	// --- //


	Rectangle { // notification application name background slice
		id: toast_sender_bg

		readonly property bool appNameExists: (toast_data.current !== null && toast_data.appName !== null)

		anchors.left: toast_bg.right
		// anchors.leftMargin: 20

		height: parent.height
		width: this.appNameExists ? toast_sender_contents.width + 14 * 2 + 1 : 0
		
		antialiasing: true
		transform: Shear {
			xAngle: -24
		}

		color: "#3F395D"
	}
	Text {
		id: toast_sender_contents
		anchors.verticalCenter: parent.verticalCenter
		anchors.verticalCenterOffset: root.barBorder / (-2)
		anchors.left: toast_contents.right
		anchors.leftMargin: 28

		text: toast_sender_bg.appNameExists ? toast_data.current.appName : ""
		textFormat: Text.PlainText

		color: "#d4a1e7"
		font {
			family: "JetBrainsMono Nerd Font"
			pixelSize: parent.height / 2.8
			weight: 300
			letterSpacing: -0.25
		}
	}
	Rectangle { // Notifications background
		id: toast_bg

		x: 12 + bell_icon.width
		width: (toast_contents.width > 0) ?toast_contents.width + 24 : 0
		height: parent.height + root.barBorder

		antialiasing: true
		transform: Shear {
			xAngle: -24
		}
		topLeftRadius: 10

		color: "#121221"
		// opacity: 0.66667
		opacity: 0.50
	}
	Text {
		id: toast_contents

		anchors.left: bell_icon.left
		anchors.leftMargin: 40
		anchors.verticalCenter: parent.verticalCenter
			anchors.verticalCenterOffset: root.barBorder / (-2)

		// text: toast_data.current === null ? ""
			// : (toast_data.appName !== null ? toast_data.current.appName + " ─ " : "")
				// + toast_data.current.summary
		text: toast_data.current === null ? "" : toast_data.current.summary
		textFormat: Text.PlainText

		// WIP attempt at animation
		Behavior on color {
			PropertyAnimation {
				duration: 300
			}
		}
		// Behavior on text {
			// OpacityAnimator {
				// from: 1.0
				// to: 0.0
				// duration: 175
			// }
			// OpacityAnimator {
				// from: 0.0
				// to: 1.0
				// duration: 175
			// }
			// ScriptAction {
				// script: {
					// var oldWidth = notifText.implicitWidth
					// notifText.text = notifBox.pendingText
					// var newWidth = notifText.implicitWidth
					// fadeInPause.duration = (newWidth > oldWidth) ? 300 : 0
				// }
			// }
		// }

		// color: "#93cee9"
		color: toast_data.expired ? "#3F395D" : "#d4a1e7"
		font {
			family: "JetBrainsMono Nerd Font"
			pixelSize: parent.height / 2
			weight: 400
			letterSpacing: -0.65
		}
	}

	Rectangle { // Notifications border
		x: 12
		width: parent.width - this.x
		height: parent.height + root.barBorder

		color: "transparent"

		antialiasing: true
		transform: Shear {
			xAngle: -24
		}
		border.pixelAligned: false
		border.color: "#3F395D" // Niri is "#393552" try to visually match
		border.width: root.barBorder
		topLeftRadius: 10

		MouseArea {
			anchors.fill: parent
			anchors.leftMargin: bell_icon.width
			enabled: toast_data.current !== null // TODO
			cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

			onClicked: {
				if (toast_data.current === null) {
					// TODO: previous notifications panel
					return
				}
				if (toast_debounce.running) {
					// prevent automatically clear brand new notification
					return
				}

				toast_data.current.dismiss()

				if (toast_data.pending.length > 0) {
					toast_data.current = toast_data.pending.shift()
					toast_data.expired = false
					toast_timeout.start()
					toast_debounce.start()
				} else {
					toast_data.current = null
					toast_data.expired = true // TODO: check for race condition
					toast_timeout.stop()
				}
			}
		}
	}

	// Drawn down here to make mouse areas easier
	Rectangle { // bell icon bg
		id: bell_icon

		anchors.left: parent.left
		anchors.leftMargin: 12 

		height: parent.height
		width: 34 // hard code for icon for now
		antialiasing: true
		transform: Shear {
			xAngle: -24
		}
		topLeftRadius: 10 // needs to match the border above

		color: "#3F395D"

		MouseArea {
			anchors.fill: parent
			// enabled: toast_data.current !== null // TODO
			cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

			onClicked: {
				console.info("TODO: expired notifications menu")
			}
		}
	}
	VectorImage { // bell icon itself
		anchors.centerIn: bell_icon
		anchors.verticalCenterOffset: -1
		anchors.horizontalCenterOffset: -3

		source: "../icons/bell.svg"
		width: parent.height - 15
		height: parent.height - 15
		preferredRendererType: VectorImage.CurveRenderer

		layer.enabled: true
		layer.effect: MultiEffect {
			brightness: 1.0
			colorization: 1.0
			colorizationColor: "#d4a1e7"
		}
	}
}
