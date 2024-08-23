-- PLUGIN: nvim-treesitter
-- SOURCE: https://github.com/nvim-treesitter/nvim-treesitter

-- Advanced syntax highlighting

local plugin = {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
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
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end
}

return plugin
