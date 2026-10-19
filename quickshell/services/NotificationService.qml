pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications // Requires notifications USE flag

Singleton {
	id: service_Notifications

	// TODO: Pulled this from the original but did I ever support the app name?
	// readonly property bool appNameExists: (_state.current !== null && _state.current.appName !== null)
	readonly property var current_Message: _state.current? _state.current.summary : null
	readonly property var current_App: _state.current? _state.current.appName : null
	readonly property bool current_Expired: _state.expired

	function dismissCurrent() {
		if (_debounce.running) {
			// prevent automatically clear brand new notification
			return;
		}

		if (!_state.current) {
			console.log("No notification to dismiss");
			return;
		} 

		_state.current.dismiss();
		if (_state.pending.length > 0) {
			_state.current = toast_data.pending.shift()
			_state.expired = false

			_timeout.start()
			_debounce.start()
		} else {
			_state.current = null
			_state.expired = true // TODO: check for race condition

			_timeout.stop()
		}
	}

	Item {
		id: _state

		property var current: null
		property bool expired: true // maybe better named !timer_active
			// ^^ as they should always be paired
		property var pending: []
	}

	NotificationServer {
		onNotification: function(n) {
			// console.info("received notification", n.summary)

			n.tracked = true

			if (_state.expired) {
				// destroy old notification
				if (_state.current !== null) {
					_state.current.expire()
				}

				_state.current = n
				_state.expired = false // TODO: check for race condition
				_timeout.start()
				_debounce.start()
			} else {
				_state.pending.push(n)
			}
		}
	}
	Timer {
		id: _timeout
		interval: 20000
		repeat: false
		onTriggered: {
			// roll to next or indicate expiration
			if (_state.pending.length > 0) {
				_state.current = _state.pending.shift()
				_state.expired = false
				_timeout.start()
			} else {
				_state.expired = true
			}
		}
	}
	Timer {
		id: _debounce
		interval: 750
		repeat: false
	}
}

