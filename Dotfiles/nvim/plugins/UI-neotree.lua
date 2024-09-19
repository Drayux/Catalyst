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
	-- module = false, -- don't load plugin with `require("neotree")`
	lazy = false,
	
	opts = {
		close_if_last_window = true,
		enable_git_status = true,
		sort_case_insensitive = true,
		popup_border_style = "rounded",

		window = {
			position = "left",
			-- position = "float",
			width = 35,
			mappings = {
				["<space>"] = { "toggle_preview" } -- config = { use_float = false }},
			}
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
				  added     = "✚", -- "✚"
				  modified  = "", -- ""
				  deleted   = "✖", -- "✖"
				  renamed   = "󰁕", -- "󰁕"

				  -- Status type
				  untracked = "", -- ""
				  ignored   = "",
				  unstaged  = "󰄱",
				  staged    = "",
				  conflict  = "",
				}
			},
		},

		sources = { "buffers", "document_symbols", "filesystem", "git_status" },

		filesystem = {
			follow_current_file = {
				-- Prefer to open floating tree at location of current file
				-- but leave sidebar tree alone as a "utility"
				enabled = false,
			},
			hijack_netrw_behavior = "open_current",
		},

		source_selector = {
			statusline = true,
			sources = {
				{	source = "filesystem",
					display_name = " ╰  " },
				{	source = "document_symbols",
					display_name = " ╰  " }, -- 
				{	source = "buffers",
					display_name = " ╰ 󰈚 " },
				{	source = "git_status",
					display_name = " ╰ 󰳐 " },
			}
		},

		commands = {}
	},

	config = function(_, opts)
		require("neo-tree").setup(opts)

		-- Shortcut for opening a file browser
		-- Will show a floating (temporary) window unless the filesystem tree is already open
		vim.api.nvim_create_user_command("NeotreeActivate", function(args)
			-- Check if neotree is currently visible
			-- NOTE: Currently the same as in the lualine config...
			--   update with an API call if one is ever added
			local state = require("neo-tree.sources.manager").get_state("filesystem")
			local window_exists = require("neo-tree.ui.renderer").window_exists(state)

			-- :Neotree will focus the tree
			if window_exists then
				vim.cmd("Neotree left")
				return
			end
			
			-- Sidebar "hotkey" is simply :Neotree toggle left
			vim.cmd("Neotree float filesystem")
		end, {
			nargs = 0,
			desc = "Activate Neotree window (swap or open)",
		})
	end
}

return plugin

