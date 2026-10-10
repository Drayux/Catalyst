import Quickshell
import QtQuick
import Niri

import "vars"
import "panels"
// import "services" // TODO: Test if I can just include this once here or even not at all

ShellRoot {
	id: root

	/* Heuristic to select only the "main" monitor by assuming that the
	 * main monitor's position is unconditionally (0, 0) */
	readonly property var mainScreen: {
		const screens = Quickshell.screens
		const id = OPTS.primaryScreen
		var best = null
		for (var i = 0; i < screens.length; i++) {
			const _s = screens[i]
			if (id) {
				if (_s.serialNumber === id
					|| _s.name === id) {
					return _s
				} else if (_s.x === 0 && s.y === 0) {
					best = _s
				}
			} else {
				/* Return right away if no name/id was given */
				if (_s.x === 0 && _s.y === 0) {
					return _s
				}
			}
		}
		return best || screens[0]
	}

	Variants {
		model: OPTS.onAllScreens? Quickshell.screens : [ root.mainScreen ]
		delegate: RootPanel {
			/* Used to determine layout of bar */
			mainScreen: root.mainScreen
		}
	}
}
