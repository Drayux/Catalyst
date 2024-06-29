-- PLUGIN: nvim-treesitter
-- SOURCE: https://github.com/nvim-treesitter/nvim-treesitter

-- Advanced syntax highlighting
return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
	build = ":TSUpdate",
	-- opts = function() return require "nvchad.configs.treesitter" end,
	-- config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end
}
