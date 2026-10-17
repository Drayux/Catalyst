pragma Singleton

import QtQuick
import Quickshell

Singleton {
	id: service_Power

	enum PowerState {
		Persist,   	// Default: analogous to "cancel"
		Sleep, 		// 
		Hibernate,  // 
		Shutdown    // 
	}

	property bool menuActive: false
	property int menuSelection: PowerService.PowerState.Persist

	function _invokeSleep() {
		console.info("Invoking sleep command")
		Quickshell.execDetached(["power-state", "sleep"])
	}

	/* NOTE: Not currently supported by any of my systems
	 * 	function _invokeHibernate() {
	 *		Quickshell.execDetached(["power-state", "hibernate"])
	 * 	}
	 */

	function _invokeShutdown() {
		console.info("Invoking shutdown command")
		Quickshell.execDetached(["power-state", "shutdown"])
	}

	function invokeAction() {
		const selected = service_Power.menuSelection

		// TODO: Not sure if the design makes more sense where one function
		// handles both states or if the button should be responsible for its
		// own behavior.
		if (!menuActive) {
			console.warn("Power mode invoked while menu closed")
			// service_Power.menuActive = true
			return
		}

		/* Reset the menu first, if we're lucky, we'll watch it animate as the
		 * machine changes power states. */
		service_Power.menuSelection = PowerService.PowerState.Persist
		service_Power.menuActive = false

		if (selected == PowerService.PowerState.Sleep) {
			_invokeSleep()
		}
		/* 	else if (selected == PowerState.Hibernate) {
		 * 		return _invokeHibernate
		 * 	}
		 */
		else if (selected == PowerService.PowerState.Shutdown) {
			_invokeShutdown()
		}
	}

	// TODO: Move these to theme variables once I've confirmed they work
	/* function getActiveColor() {
		if (service_Power.menuSelection == PowerState.Sleep) {
			return "#d4a1e7"
		}
		if (service_Power.menuSelection == PowerState.Hibernate) {
			return "#a9b578"
		}
		if (service_Power.menuSelection == PowerState.Shutdown) {
			return "#ea9a97"
		}
		return "#93cee9"
	} */
	readonly property color activeColor: {
		if (!service_Power.menuActive) {
			return "#282339"
		}
		// --- 
		if (service_Power.menuSelection == PowerService.PowerState.Sleep) {
			return "#93cee9"
		}
		if (service_Power.menuSelection == PowerService.PowerState.Hibernate) {
			return "#a9b578"
		}
		if (service_Power.menuSelection == PowerService.PowerState.Shutdown) {
			return "#ea9a97"
		}
		return "#d4a1e7"
	}
}
