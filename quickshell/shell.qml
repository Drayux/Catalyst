import Quickshell
import QtQuick
import Niri

import "vars"
import "panels"
// import "services" // TODO: Test if I can just include this once here or even not at all

ShellRoot {
	Variants {
		/* Heuristic to select only the "main" monitor by assuming that the
		 * main monitor's position is unconditionally (0, 0) */
		model: {
			const screens = Quickshell.screens
			const selected = screens.filter(s =>
				OPTS.onAllScreens
				|| (s.x === 0 && s.y === 0)
			)
			return (selected.length > 0 ? selected : [ screens[0] ])
		}
		delegate: RootPanel { }
	}
}
