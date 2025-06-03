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
			cond = condCORE, -- Should be the same as base treesitter because binds depend on it
		},
		{ "ziontee113/syntax-tree-surfer",
			-- TODO: Take this plugin and build custom navigation functionality withinin buffer/
			cond = condCORE, -- Should be the same as base treesitter because binds depend on it
			init = function()
				local EDITOR = { "n", "v" }
				vim.keymap.set(EDITOR, "d", "<cmd>STSJumpToEndOfCurrentNode<cr>")
				vim.keymap.set(EDITOR, "D", "<cmd>STSJumpToStartOfCurrentNode<cr>")
				vim.keymap.set(EDITOR, "<C-d>", "<cmd>STSSelectCurrentNode<cr>")
			end,
			config = function()
				-- No "plugin main", we just need to require it
				require("syntax-tree-surfer")
			end
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
					alpha = 0.25,
					color = { "Normal", "#ffffff" },
					term_bg = "#2c2c34", -- Fallback terminal emulator color
					inactive = true, -- Whether to dim the contents of other windows when active
				},
				context = 99, -- Amount of lines to show around the current line (99 for max)
				treesitter = true, -- Use treesitter when available
				-- exclude = {}, -- Exclude these filetypes
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
		additional_vim_regex_highlighting = false,

		-- Modules
		highlight = { enable = true },
		incremental_selection = { enable = false }, -- Conflicts with custom keymap
		indent = { enable = true },
		textobjects = { -- This module is not built-in and thus requires the nvim-treesitter-textobjects plugin
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					-- TODO: None of these really work very well...
					["ic"] = "@comment.inner",
					["oc"] = "@comment.outer",
					["is"] = "@statement.inner",
					["os"] = "@block.inner",
					["id"] = "@statement.outer",
					["od"] = "@block.outer",
					["if"] = "@function.inner",
					["of"] = "@function.outer",

					-- Removed these because yf would feel like "yank with the motion 'f'"
					-- > but 'f' is not a motion
					-- ["f"] = "@function.inner",
					-- ["F"] = "@function.outer",
				}
			},
			-- >>> Modules also available, but currently not in use
			swap = { enable = false },
			move = {
				enable = false, 
				set_jumps = true,
				-- See the GitHub repo for keymap configuration
				-- > https://github.com/nvim-treesitter/nvim-treesitter-textobjects
			},
			-- <<<
		}
	},
	build = ":TSUpdate",
	init = function(plugin)
		vim.g.treesitter_enabled = true

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
