-- PLUGIN: neo-tree.lua
-- SOURCE: https://github.com/nvim-neo-tree/neo-tree.nvim
-- LEVEL: USER

-- Filesystem tree pane

local api = require("files")
local spec = {
	"nvim-neo-tree/neo-tree.nvim",
	cond = condUSER,
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"s1n7ax/nvim-window-picker",
	},
	cmd = { "Neotree" },
	opts = {
		close_if_last_window = true,
		enable_git_status = true,
		sort_case_insensitive = true,
		popup_border_style = "rounded",

		window = {
			position = "left",
			width = 35,
			mappings = {
				["<space>"] = { "toggle_preview", config = { use_float = true }},
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
	init = function()
		vim.g.neotree_enabled = true

		-- Shortcut for toggling the tree (source aware)
		-- Will show the most recent source or default to filesystem
		-- (Unless :Neotree was invoked directly, then the state may not be updated)
		-- https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/826#discussioncomment-5431757
		local toggleState = nil
		vim.api.nvim_create_user_command("Neotoggle", function(args)
			local windowOpen = api.open()
			if windowOpen then
				-- Window present, save state and close
				toggleState = windowOpen
				vim.cmd("Neotree close")

			else
				-- No window, open last known source
				local source = toggleState or ""
				vim.cmd("Neotree left focus " .. source)

			end
		end, {
			nargs = 0,
			desc = "Toggle Neotree sidebar",
		})

		-- Shortcut for opening a file browser
		-- Will show a floating (temporary) window unless the filesystem tree is already open
		vim.api.nvim_create_user_command("Neofiles", function(args)
			-- Check if neotree is currently visible
			local filetreeOpen = api.state("filesystem")
			if filetreeOpen then
				-- :Neotree will focus the tree
				vim.cmd("Neotree filesystem left")
				return
			end
			
			-- Sidebar "hotkey" is simply :Neotree toggle left
			vim.cmd("Neotree filesystem float")
		end, {
			nargs = 0,
			desc = "Activate Neotree filesystem (swap or open)",
		})

		-- Key mappings
		require("editor.binds").command("fb", "Neofiles")
		require("editor.binds").command("tt", "Neotoggle")
		require("editor.binds").command("tb", "Neotree focus filesystem left")
		require("editor.binds").command("te", "Neotree focus buffers left")
		require("editor.binds").command("tg", "Neotree focus git_status left")
		require("editor.binds").command("ts", "Neotree focus document_symbols left")
		-- require("editor.binds").command("th", "Neotree focus undo_history left") -- (TODO - CUSTOM)
		-- > https://github.com/mbbill/undotree
	end,
	config = function(_, opts)
		require("neo-tree").setup(opts)
		api.load() -- Trigger lazy load user commands
	end
}

return spec
