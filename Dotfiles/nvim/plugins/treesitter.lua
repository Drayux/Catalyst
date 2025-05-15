-- PLUGIN: nvim-treesitter
-- SOURCE: https://github.com/nvim-treesitter/nvim-treesitter
-- LEVEL: CORE

-- Advanced syntax highlighting

local spec = {
	"nvim-treesitter/nvim-treesitter",
	cond = condCORE,
	main = "nvim-treesitter.configs",
	event = { "BufEnter" },
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects",
			cond = condUSER
		},
		{ "nvim-treesitter/nvim-treesitter-context",
			cond = condUSER,
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
			cond = condGUI, -- Only enable in terminal emulator
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
		},
		{ "OXY2DEV/foldtext.nvim",
			cond = false and condGUI, -- Just a "pretty" plugin so disable it for now
			opts = {
				default = {}
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
		highlight = { enable = true },
		incremental_selection = { enable = true },
		indent = { enable = true },
		textobjects = {
			move = {
				enable = true, 
				set_jumps = true,
				goto_next_start = {
					["<leader>as"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
				},
			},
			-- select = {
			-- 	enable = true 
			-- },
			-- swap = {
			-- 	enable = true 
			-- }
		}
	},
	build = ":TSUpdate",
	init = function(plugin)
		-- Enable treesitter code folding
		-- > Buffer options which use the global value as default
		-- > Note that foldtext cannot be set globally, so using foldtext.nvim is preferable
		vim.o.foldmethod = "expr"
		vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

		-- Taken from AstroNvim, this ensures that TreeSitter's queries are available for
		-- > other plugins, as other plugins may assume that TreeSitter is already loaded
		require("lazy.core.loader").add_to_rtp(plugin)
		pcall(require, "nvim-treesitter.query_predicates")
	end,
	config = function(plugin, opts)
		-- Treesitter is unusual and the "default main" must be overridden
		require(plugin.main).setup(opts)

		-- Enable treesitter highlighting for C, Ruby, (and probably others)
		-- > Likely an api version bug, some languages do not enable treesitter's
		-- > highlights by default, but they will be if explicitly called
		vim.cmd("TSEnable highlight")
	end
}

return spec
