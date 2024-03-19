export default (monitor) => Widget.Window({
    className: "corners",
    name: `corners-${monitor}`,
    monitor,
    
    anchor: [ "top", "bottom", "right", "left" ],
    clickThrough: true,
    layer: "bottom",

    child: Widget.Box({
    	className: "bounds",
    	child: Widget.Box({
    		className: "shape",
    		expand: true	// like saying `width, height: 100%`
    	})
    })
})
