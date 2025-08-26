import Button from "./button.js"

// Variables
import { clock } from "../variables.js"

// Services
const battery = await Service.import("battery")
const notifications = await Service.import("notifications")

const btnDebug = () => {
	notifications.popupTimeout = 3000;
	notifications.forceTimeout = false;
	notifications.cacheActions = false;
	notifications.clearDelay = 100;
	
	return Button({
		applet: "debug",
		// child: Widget.Label({ label: "huge hangey" }),
		child: Widget.Label({
		    label: notifications.bind("notifications").as(n =>
		        `there are ${n.length} notifications`
		    )
		}),

		on_clicked: () => { console.log(notifications) }
	})
}

const btnBattery = () => {
	return Button({
		applet: "battery",	// TODO (maybe?)
		visible: battery.bind("available"),
		// hexpand: false,	// TODO child class
		hpack: "end",
		
		child: Widget.Box({
			children: [
				Widget.Label({
					label: battery.bind("percent").as(p => `${p.toFixed()}%`)
				}),
			]
		}),

		on_clicked: () => { console.log(battery) }
	})
}

const btnClock = (format) => {
	// https://github.com/Aylur/ags/blob/main/src/utils/binding.ts#L20
	// let t = clock	// import
	// const fn = (t) => t.value.format(format)
	// const update = () => fn(t)
	// const watcher = Variable(update())
	// t.connect('changed', () => watcher.setValue(update()));
	// -- label: watcher.bind

	// const update = () => clock.value.format(format)
	// const time = Variable(update())
	// clock.connect('changed', () => time.setValue(update()));

	return Button({
		applet: "date",	// TODO
		// on_clicked: action.bind(),
		
		child: Widget.Label({
			justification: "center",
			label: clock.bind().as(t => t.format(format))
		})
	})
}

export default (monitor = 0) => {
	const panelPos = "bottom"
    return Widget.Window({
        monitor,
        className: "panel",
        name: `panel-${monitor}`,
        
        anchor: [ panelPos, "right", "left" ],
        exclusivity: "exclusive",
        layer: "bottom",
        
        child: Widget.CenterBox({
       	    spacing: 8,
		    vertical: false,
		    
		    startWidget: btnDebug(),
		    centerWidget: btnClock("%H:%M"),
		    endWidget: btnBattery()
        })
    })
}
