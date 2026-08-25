-- PLUGIN: nvim-treesitter
-- SOURCE: https://github.com/nvim-treesitter/nvim-treesitter
-- LEVEL: CORE

-- Manager for treesitter parsers

-- NOTE: Checkhealth currently has a bug with RTP if on windows
-- The default path *is* in the RTP, it just isn't resolving ~
-- Treesitter-CLI does not appear to be a real dependency
-- NeoVim >= 0.12 is needed only for calls to vim.list.unique()
-- (See nvim-treesitter/config.lua)

-- https://raw.githubusercontent.com/neovim-treesitter/treesitter-parser-registry/main/registry.json
local parsers = {
	"bash",
	"diff",
	"c",
	"cpp",
	"lua",
	"rust",
	"python",
	"json",
	"make",
	"markdown",
	"yaml",
}

local spec = {
	"neovim-treesitter/nvim-treesitter",
	cond = condCORE,
	lazy = false,
	dependencies = {
		"neovim-treesitter/treesitter-parser-registry",
		"nvim-treesitter/nvim-treesitter-textobjects",
		-- Repo archived and probably no longer works with current version of TS
		-- { "ziontee113/syntax-tree-surfer",
			-- TODO: Take this plugin and build custom navigation functionality withinin buffer/
			-- cond = condCORE, -- Should be the same as base treesitter because binds depend on it
			-- init = function()
				-- local EDITOR = { "n", "v" }
				-- vim.keymap.set(EDITOR, "d", "<cmd>STSJumpToEndOfCurrentNode<cr>")
				-- vim.keymap.set(EDITOR, "D", "<cmd>STSJumpToStartOfCurrentNode<cr>")
				-- vim.keymap.set(EDITOR, "<C-d>", "<cmd>STSSelectCurrentNode<cr>")
			-- end,
			-- config = function()
				-- No "plugin main", we just need to require it
				-- require("syntax-tree-surfer")
			-- end
		-- },
		{ "nvim-treesitter/nvim-treesitter-context",
			cond = condUSER,
			opts = {
				-- https://github.com/nvim-treesitter/nvim-treesitter-context?tab=readme-ov-file#configuration
				enable = true,
				mode = "cursor", -- "topline",
				separator = "",
				min_window_height = 24,
				max_lines = 8,
				multiline_threshold = 1,
				trim_scope = "outer", -- "inner"
			}
		},
		-- { "OXY2DEV/foldtext.nvim",
			-- cond = false and condGUI, -- Just a "pretty" plugin so disable it for now
			-- opts = {
				-- default = {}
			-- }
		-- }
	},
	opts = {
		-- TODO: Verify if this configuration is being used with the new nvim-treesitter
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
	-- build = "TSUpdate",
	init = function(plugin)
		vim.g.treesitter_enabled = true

		-- Enable treesitter code folding
		-- > Buffer options which use the global value as default
		-- > Note that foldtext cannot be set globally, so using foldtext.nvim is preferable
		vim.o.foldmethod = "expr"
		vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

		require("nvim-treesitter").install(parsers)
		require("nvim-treesitter").update("all")

		-- TODO: This list will not contain newly-installed parsers (neovim restart needed)
		local installed = require("nvim-treesitter.config").get_installed()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = installed,
			callback = function() vim.treesitter.start() end
		})
	end,
	-- config = function(_, opts)
		-- This path needs to be on the runtime path
		-- opts.install_dir = (vim.fn.stdpath("data") or "/home/.local/share/nvim") .. "/site"
		-- table.insert(vim.opt.runtimepath:get(), 1, opts.install_dir) -- <data>/site is on rtp by default

		-- Taken from AstroNvim, this ensures that TreeSitter's queries are available for
		-- > other plugins, as other plugins may assume that TreeSitter is already loaded
		-- TODO: Is this still relevant??
		-- pcall(require, "nvim-treesitter.query_predicates")

		-- require("nvim-treesitter").setup(opts)
	-- end
}

return spec
