// For buttons that bind to an applet window
// Taken from PanelButton.ts
export default ({applet = "", ...baseparams}) => {
	let base = Widget.Button({
		className: applet,
		...baseparams
	})
	
	// base.applet = applet <-- this works :)
	base.toggleClassName("panel-button")
	
	// JS closures are still wild to me
	let open = false
	base.hook(App, (_, win, visible) => {
		// console.log(`button.js:15 '${win}'`)
	    if (win !== applet) return

	    if (open && !visible) {
	        open = false
	        base.toggleClassName("active", false)
	    }

	    if (visible) {
	        open = true
	        base.toggleClassName("active")
	    }
	})
	
	return base
}
