-- Configuration for the NvChad plugins (ui) since they have to be special
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.ui = {
    -- Available themes: ls ~/.local/share/nvim/lazy/base46/lua/base46/themes/
	-- theme = "onedark", -- (DEFAULT)
	theme = "chadracula",
	telescope = { style = "bordered" },
	tabufline = {
		enabled = true,
		lazyload = true,
		order = { "treeOffset", "buffers", "tabs", "btns" },
		modules = nil,
	},
	nvdash = {
		-- Specific startups loaded as defined in .../nvim/events.lua
		load_on_startup = false,
		header = {
			"                                    ",
			-- local motd = math.random(10); motd,
		},
		buttons = {
			--  󰈚 󰈭   
			{ " 󰈚    ", "Open Project  ", "Telescope projections" },
			{ " 󰈚    ", "Open Directory  ", "Telescope directory feature=open_dir" },
			{ " 󰈚    ", "Open Recent  ", "Telescope oldfiles" },
			{ " 󰈚    ", "Open File  ", "Telescope find_files" },
			{ " 󰈚    ", "New File  ", "enew" },
			{ "     ", "Browse Files  ", "Telescope file_browser path=%:p:h select_buffer=true" },
			{ "     ", "Mappings  ", "NvCheatsheet" },
		},
	},
}

return M
