-- Configuration for the NvChad plugins (ui) since they have to be special
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.ui = {
    -- Theme only updates if saved from nvim
    -- Available themes: ls ~/.local/share/nvim/lazy/base46/lua/base46/themes/
	-- theme = "onedark", -- (DEFAULT)
	theme = "chadracula",
	telescope = { style = "bordered" },

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },

    -- TODO: Enable and create options for...
    --     - new file
    --     - open file (search/open tree maybe)
    --     - change (tree) directory
    --     - show cheatsheet
	nvdash = {
		load_on_startup = false,
		header = {
			"                                                ",
			-- local motd = math.random(10); motd,
			"                                                ",
		},
		buttons = {
			{ "  Find File", "Spc f f", "Telescope find_files" },
			{ "󰈚  Recent Files", "Spc f o", "Telescope oldfiles" },
			{ "󰈭  Find Word", "Spc f w", "Telescope live_grep" },
			{ "  Bookmarks", "Spc m a", "Telescope marks" },
			{ "  Themes", "Spc t h", "Telescope themes" },
			{ "  Mappings", "Spc c h", "NvCheatsheet" },
		},
	},
}

return M
