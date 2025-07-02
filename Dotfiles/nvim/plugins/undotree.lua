-- PLUGIN: undotree
-- SOURCE: https://github.com/mbbill/undotree
-- LEVEL: GUI

-- Exposes Neovim's buffer history system by providing a tree visualization
-- TODO: Try to integrate this with Neotree such that a fifth tab can be shown
-- (instead of the current solution where both are shown independently)

local spec = {
	"mbbill/undotree",
	cond = condUSER,
	cmd = {
		"UndotreeToggle",
		"UndotreeShow",
		-- "UndotreeHide",
		-- "UndotreeFocus",
		-- "UndotreePersistUndo",
	},
	-- event = { "BufEnter" },
	init = function()
		-- NOTE: If setting up persistent undo data (likely alongside the
		-- implementation of custom session management) the BufEnter event
		-- trigger will need to be re-enabled
		require("editor.binds").command("tu", "UndotreeToggle")
	end
}

return spec

