-- PLUGIN: lualine.nvim
-- SOURCE: https://github.com/nvim-lualine/lualine.nvim

-- Customizable status line

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

-- This is the "fallback" theme for lualine
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

local plugin = {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			theme = theme,
			component_separators = "",
			section_separators = { left = "", right = "" },
			disabled_filetypes = { "neo-tree" },
		},
		sections = {
			lualine_a = {
				{ "mode", separator = { left = " " }, right_padding = 2 }
			},
			lualine_b = { "filename", "branch" },
			lualine_c = {
				"%=", -- add center components here
			},
			lualine_x = {},
			lualine_y = { "filetype", "progress" },
			lualine_z = {
				{ "location", separator = { right = " " }, left_padding = 2 },
			},
		},
		inactive_sections = {
			lualine_a = { "filename" },
			lualine_b = {},
			lualine_c = {},
			lualine_x = {},
			lualine_y = {},
			lualine_z = { "location" },
		},
		tabline = {},
		extensions = {},
	},
	config = function(_, opts)
		require("lualine").setup(opts)
	end
}

return plugin

