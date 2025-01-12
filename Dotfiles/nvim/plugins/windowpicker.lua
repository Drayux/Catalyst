-- PLUGIN: nvim-window-picker
-- SOURCE: https://github.com/s1n7ax/nvim-window-picker
-- LEVEL: USER

-- Window selection utility

-- TODO: Simple keymap for "select window" and subsequently
-- > move the cursor to that window
-- > require('window-picker').pick_window()

local spec = {
	"s1n7ax/nvim-window-picker",
	cond = condUSER,
	opts = {
		hint = "floating-big-letter",
		filter_rules = {
			include_current_win = false,
			autoselect_one = true,
			bo = {
				filetype = { "neo-tree", "neo-tree-popup", "notify" },
				buftype = { "terminal", "quickfix" },
			}
		}
	}
}

return spec
