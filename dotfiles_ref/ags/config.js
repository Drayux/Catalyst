import panel from "./panel/panel.js"
import corners from "./panel/corners.js"

import alerts from "./applets/alerts.js"

// Reprocess scss stylesheets (sassc)
// Allows for consistent dynamic theming
async function updateStyle() {
	const dir = `${App.configDir}/style/`
	const infile = dir + "style.scss"
	const outfile = dir + ".global.css"

	// Ensure that the file exists before generating any windows
	await Utils.exec(`touch ${outfile}`)

	// Asynchronously process the stylesheets
	Utils.exec(`sassc -t compressed ${infile} ${outfile}`)
	return outfile
}

export default {
	style: await updateStyle(),
	windows: [
		panel(),
		// corners(),
		alerts(),
	]
}

// App.addWindow(panel())
