import Quickshell
import QtQuick
import QtQuick.Shapes

Shape {
	// TODO: Consider making these a required property and calculating the tray margin in the root config
	property real accentHeight: parent.height
	property real accentWidth: parent.height / 2.25
	// ^^ 2.25 equates to ~24 degrees ;; 1: 45; 1.5: 33.5; 2: 26.5; 3: 18.5; 4: 14

	preferredRendererType: Shape.CurveRenderer

	SystemClock {
		id: sysClock
		precision: SystemClock.Seconds
	}

	ShapePath {
		strokeWidth: 2 // parent.border.width
		strokeColor: "#3F395D"
		// strokeColor: "#272542"
		fillColor: "#121221"
		capStyle: ShapePath.FlatCap
		joinStyle: ShapePath.RoundJoin
		pathHints: ShapePath.PathSolid

		// top-left: (0, 0)
		startX: clockText.width + accentWidth * 2
		startY: 0
		PathLine {
			// bottom-right
			x: clockText.width + accentWidth
			y: accentHeight
		}
		PathLine {
			// bottom-left
			x: accentWidth
			y: accentHeight
		}
		PathLine {
			// top-left (again)
			x: 0
			y: 0 
		}
	}

	Text {
		id: clockText

		anchors.centerIn: parent
		anchors.verticalCenterOffset: -1.5
		text: Qt.formatDateTime(sysClock.date, "HH:mm")
		leftPadding: 32
		rightPadding: 32

		color: "#93cee9"
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 22
		font.weight: 800
		font.letterSpacing: -0.20
		// font.preferShaping: false
	}
}
// }
