-- PLUGIN: ui
-- SOURCE: https://github.com/NvChad/ui/tree/v2.5

-- UI plugin from NvChad
-- Adds status bar, tabs, dash, and is necessary for theming with base46

local plugin = {
	"NvChad/ui",
	lazy = false,
	branch = "v2.5",
	config = function() require("nvchad") end
}

return plugin
