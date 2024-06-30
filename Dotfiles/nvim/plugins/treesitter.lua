-- PLUGIN: nvim-treesitter
-- SOURCE: https://github.com/nvim-treesitter/nvim-treesitter

-- Advanced syntax highlighting

local plugin = {
	"nvim-treesitter/nvim-treesitter",
	cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
	event = { "BufReadPost", "BufNewFile" },
	build = ":TSUpdate",
	opts = {},
	config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end
}

return plugin
