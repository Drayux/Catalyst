import GLib from "gi://GLib"
const notifications = await Service.import("notifications")

// Create the alert object
function _createAlert(id) {
	const _data = notifications.getNotification(id)
	// if (!(notif !== undefined)) return null

	const content = Widget.Box({
		css: "width: 200px;",
		className: "content",
		children: [
			// TODO: Icon
			Widget.Box({
				// Title, timestamp, (optional close button)
				hexpand: true,
				vertical: true,
				children: [
					Widget.Label({
						className: "summary",
						
						hexpand: true,
						justification: "left",
						
						max_width_chars: 24,
						truncate: "end",
						label: _data.summary.trim(),
						useMarkup: true
					}),
					Widget.Label({
						className: "timestamp",
						vpack: "start",
						label: GLib.DateTime
							.new_from_unix_local(_data.time)
							.format("%H:%M")
					})
					// TODO: Close button if desired
				]
			})
		]
	})

	const container = Widget.EventBox({
		className: "alert",
		vexpand: false,
		child: content,

		// Current UI design...
		// Notifications are meant to be stored and accessed from the overview applet
		// They can be "quick-closed" with a right click
		// TODO: The related app can be opened with left click (also closing the notification)
		onSecondaryClick: _data.close
	})
	
	return container
}

// Create alert animator
function _createAnimator(notif) {
	// notif = Widget.Label({ label: "SNIDDY SANDWICH" })
	const inner = Widget.Revealer({
		css: "border: 1px solid magenta;",
		transition: "slide_left",
		transition_duration: 200,
		child: notif,
	})

	const outer = Widget.Revealer({
		css: "border: 1px solid yellow;",
		transition: "slide_down",
		transition_duration: 200,
		child: inner,
	})

	const box = Widget.Box({
		// hpack: "end",
		child: notif,
	})

	Utils.idle(() => {
		outer.reveal_child = true
		Utils.timeout(200, () => {
			inner.reveal_child = true
		})
	})

	return Object.assign(box, {
	    dismiss() {
	        inner.reveal_child = false
	        Utils.timeout(200, () => {
	            outer.reveal_child = false
	            Utils.timeout(200, () => {
	                box.destroy()
	            })
	        })
	    },
	})
}

// Notifications list
function _createAlertList() {
	const _data = new Map
	const list = Widget.Box({
        hpack: "end",
        vertical: true,
        // child: Widget.Label({ label: "SNIDDY SANDWICH" })
    })

	function _remove(_, id) {
		const animator =_data.get(id)
		if (animator) animator.dismiss()
		_data.delete(id)
	}

	list.hook(notifications, (_, id) => {
	    if (id !== undefined) {
	    	// Updated notifcation data??
	        if (_data.has(id)) _remove(null, id)

			// Check do not disturb
	        if (notifications.dnd) return

	        const animator = _createAlert(id)
	        // const animator = _createAnimator(notif)
	        
	        _data.set(id, animator)
	        list.children = [animator, ...list.children]
	    }
	}, "notified")

	list.hook(notifications, _remove, "dismissed")
	list.hook(notifications, _remove, "closed")
	
    return list
}

// Notifications overlay container
export default (monitor = 0) => {
	const position = ["top", "right"]
	return Widget.Window({
		monitor,
		className: "alerts",
		name: `alerts-${monitor}`,

		anchor: position,
		// not exclusive
		css: "background-color: green",

		// TODO: The parent widget needs a revealer routine, else no children show
		child: Widget.Box({
			css: "padding: 1px",
			child: _createAlertList(),
		})
	})
}
