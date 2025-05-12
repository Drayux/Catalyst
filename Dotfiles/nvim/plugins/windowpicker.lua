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
			return not window or vim.api.nvim_set_current_win(window)
		end
		-- NOTE: For whatever reason, calling quickSelect as an expression
		-- > keymap would invoke error E565 without fail, so the following is a
		-- > workaround by defining the expression as a user command
		-- UPDATE: Apparently it would seem that expressions cannot call lua
		-- > code that changes buffers in any capacity, and I've merely managed
		-- > to dodge the effects of this on every config tweak before this one
		vim.api.nvim_create_user_command("QuickSelectWindow", quickSelect, {
			nargs = 0,
			desc = "Focus a window indicated by letter prompts",
		})
		vim.keymap.set(NORMAL, "V", "<cmd>QuickSelectWindow<cr>")
	end
}

return spec
