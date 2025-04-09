-- PLUGIN: nvim-window-picker
-- SOURCE: https://github.com/s1n7ax/nvim-window-picker
-- LEVEL: USER

-- Window selection utility

-- > require('window-picker').pick_window()

local spec = {
	"s1n7ax/nvim-window-picker",
	cond = condUSER,
	opts = {
		hint = "floating-big-letter",
		show_prompt = false,
		filter_rules = {
			-- include_current_win = false,
			include_current_win = true,
			autoselect_one = false,
			bo = {
				filetype = { "neo-tree", "neo-tree-popup", "notify" },
				buftype = { "terminal", "quickfix" },
			}
		}
	},
	init = function()
		vim.g.windowpicker_enabled = true

		-- Simple keymap for "select window" and subsequently moving the cursor
		-- > to that window
		local NORMAL = "n"
		local quickSelect = function()
			local window = require("window-picker").pick_window()
			-- vim.api.nvim_set_current_win(window)
			print(window)
		end
		vim.keymap.set(NORMAL, "V", quickSelect, { expr = true })
	end
}

return spec
