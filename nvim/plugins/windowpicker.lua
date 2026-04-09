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
			autoselect_one = true,
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
			return not window or vim.api.nvim_set_current_win(window)
		end

		-- TODO: Move this to keymap layers instead of toggling with vim.g.windowpicker_enabled
		require("editor.binds").set("n", "V", quickSelect)
	end
}

return spec
