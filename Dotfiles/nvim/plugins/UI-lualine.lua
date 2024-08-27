-- PLUGIN: lualine.nvim
-- SOURCE: https://github.com/nvim-lualine/lualine.nvim

-- Customizable status line

--------------
-- For reference
local colors = {
	black  = "#080808",
	grey   = "#303030",
	white  = "#c6c6c6",
	red    = "#ff5189",
	orange = "#fa9a55",
	green  = "#80ff82",
	cyan   = "#79dac8",
	blue   = "#80a0ff",
	purple = "#a877ed",
	violet = "#d183e8",
}

local theme = {
	normal = {
		a = { fg = colors.black, bg = colors.blue },
		b = { fg = colors.white, bg = colors.grey },
		c = { fg = colors.white },
	},

	insert = { a = { fg = colors.black, bg = colors.green }},
	visual = { a = { fg = colors.black, bg = colors.cyan }},
	replace = { a = { fg = colors.black, bg = colors.orange }},
	command = { a = { fg = colors.black, bg = colors.purple }},

	inactive = {
		a = { fg = colors.white, bg = colors.black },
		b = { fg = colors.white, bg = colors.black },
		c = { fg = colors.white },
	},
}
--------------


local plugin = {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			component_separators = "",
			section_separators = { left = "", right = "" },
			disabled_filetypes = { "neo-tree", "neo-tree-popup", "notify" },
		},
		sections = {
			lualine_a = {
				{ "mode", separator = { left = " " }, right_padding = 2 }
			},
			lualine_b = { "filename", "branch" },
			lualine_c = {
				"%=", -- add center components here
			},
			lualine_y = { "filetype", "progress" },
			lualine_z = {
				{ "location", separator = { right = " " }, left_padding = 2 },
			},
		},
		inactive_sections = {
			lualine_a = { "filename" },
			lualine_z = { "location" },
		},
		-- winbar = {
		-- 	lualine_c = { "buffers" },
		-- },
		-- inactive_winbar = {
		-- 	lualine_c = { "filename" },
		-- },
		tabline = {
			-- lualine_a = { treebutton() },
			lualine_z = {
				-- {
				-- 	"tabs",
				-- },
				{	"buffers",
					show_filename_only = true,
					hide_filename_extension = false,
					show_modified_status = true,

					mode = 4,
					-- max_length = vim.o.columns * 2 / 3,

					filetype_names = {
						["neo-tree"] = "  Neotree",
					},
						
					use_mode_colors = true,
					-- buffers_color = {
					-- 	active = 'lualine_{section}_normal',
					-- 	inactive = 'lualine_{section}_inactive',
					-- },

					symbols = {
						modified = ' ●',      -- Text to show when the buffer is modified
						alternate_file = '', -- Text to show to identify the alternate file
						directory =  '',     -- Text to show when the buffer is a directory
					}},
			},
		},
		extensions = {},
	},
	config = function(_, opts)
		local treebutton = function()
			local status, api = pcall(require, "neo-tree")
			if not status then return nil end

			return {
				-- Display a (   /  ) icon for the button
				function()
					-- https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/826#discussioncomment-5431757
					local state = require("neo-tree.sources.manager").get_state("filesystem")
					local window_exists = require("neo-tree.ui.renderer").window_exists(state)

					if window_exists then
						return ""
					end

					return ""
				end,

				-- Handler for clicking said button
				on_click = function()
					vim.cmd("Neotree toggle left")
				end
			}
		end

		opts.tabline.lualine_a = { treebutton() }
		require("lualine").setup(opts)
	end
}

return plugin

