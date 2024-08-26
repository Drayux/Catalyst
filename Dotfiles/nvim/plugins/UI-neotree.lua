-- PLUGIN: neo-tree.lua
-- SOURCE: https://github.com/nvim-neo-tree/neo-tree.nvim

-- Filesystem tree pane
-- Additional behavior defined in .../nvim/events.lua

local plugin = {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"s1n7ax/nvim-window-picker",
	},
	cmd = { "Neotree" }, -- (use if lazy-loading)
	
	opts = {
		close_if_last_window = true,
		enable_git_status = true,
		sort_case_insensitive = true,
		popup_border_style = "rounded",

		window = {
			-- position = "left",
			position = "float",
			width = 32,
			mappings = {
				["<space>"] = { "toggle_preview", } -- config = { use_float = false }},
			}
		},

		source_selector = {
			statusline = true,
			sources = {
				{	source = "filesystem",
					display_name = "  󰉓  Files" },
				{	source = "buffers",
					display_name = " 󰈚 Buffers" },
			}
		},

		filesystem = {
			follow_current_file = {
				enabled = true,
			},
			hijack_netrw_behavior = "open_current",
		},

		default_component_configs = {
			name = {
				trailing_slash = true,
				use_git_status_colors = true,
				highlight = "NeoTreeFileName",
			},
			git_status = {
				symbols = {
				  -- Change type
				  added     = "", -- "✚"
				  modified  = "", -- ""
				  deleted   = "✖",
				  renamed   = "󰁕",

				  -- Status type
				  untracked = "", -- ""
				  ignored   = "",
				  unstaged  = "󰄱",
				  staged    = "",
				  conflict  = "",
				}
			},
		},

		commands = {}
	},

	config = function(_, opts)
		require("neo-tree").setup(opts)
	end
}

return plugin

