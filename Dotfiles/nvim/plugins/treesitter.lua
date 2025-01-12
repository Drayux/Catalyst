-- PLUGIN: nvim-treesitter
-- SOURCE: https://github.com/nvim-treesitter/nvim-treesitter
-- LEVEL: CORE

-- Advanced syntax highlighting

local spec = {
	"nvim-treesitter/nvim-treesitter",
	cond = condCORE,
	event = { "BufEnter" },
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-context",
			cond = (vim.g.envmode > 2),
			opts = {
				-- https://github.com/nvim-treesitter/nvim-treesitter-context?tab=readme-ov-file#configuration
				enable = true,
				mode = "cursor", -- "topline",
				-- separator = "",
				min_window_height = 24,
				max_lines = 8,
				multiline_threshold = 1,
				trim_scope = "outer", -- "inner"
			}
		},
		{ "folke/twilight.nvim",
			cond = (vim.g.envmode == 4), -- Only enable in terminal emulator
			cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
			opts = {
				-- TODO: Only enable dimming in insert mode
				dimming = {
					alpha = 0.25, -- amount of dimming
					-- we try to get the foreground from the highlight groups or fallback color
					color = { "Normal", "#ffffff" },
					term_bg = "#000000", -- if guibg=NONE, this will be used to calculate text color
					inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
				},
				context = 99, -- amount of lines we will try to show around the current line
				treesitter = true, -- use treesitter when available for the filetype
				-- exclude = {}, -- exclude these filetypes
			}
		}
	},
	opts = {
		-- https://github.com/tree-sitter/tree-sitter/wiki/List-of-parsers
		ensure_installed = {
			"bash",
			"c", "cpp",
			-- "cmake",
			"css", "scss",
			"diff",
			"gitattributes", "gitcommit", "gitignore",
			-- "glsl",
			"html",
			"java", "json",
			"javascript", "typescript",
			"lua",
			"make",
			"markdown", "markdown_inline",
			"python",
			"regex",
			"ruby",
			"rust",
			"xml",
			"yaml",
		},
		ignore_install = {},
		auto_install = true,
		sync_install = true,

		-- Modules
		highlight = {
			enable = true,
			disable = {
				-- See: https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#modules
			},
		}

		-- TODO: Code folding
	},
	build = ":TSUpdate"
}

return spec
