-- PLUGIN: nvim-window-picker
-- SOURCE: https://github.com/s1n7ax/nvim-window-picker

-- Window selection utility

local plugin = {
	"s1n7ax/nvim-window-picker",
	version = "2.*",
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
	},
	config = function(_, opts)
		require("window-picker").setup(opts)
	end
}

return plugin

