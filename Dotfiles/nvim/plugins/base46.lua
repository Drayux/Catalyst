-- PLUGIN: base46
-- SOURCE: https://github.com/NvChad/base46

-- Theming plugin from NvChad
-- Depends on NvChad/ui which provides (nvconfig aka `chadrc.lua`)
-- Depends on nvim-lua/plenary.nvim to build theme bytecode

local plugin = {
	"NvChad/base46",
	lazy = false,
	branch = "v2.5",
	dependencies = { 'nvim-lua/plenary.nvim' },
	build = function() require("base46").load_all_highlights() end,
	config = function()
		-- Load active theme on plugin initalization
		require("base46").load_all_highlights()
		dofile(vim.g.base46_cache .. "defaults")
		dofile(vim.g.base46_cache .. "statusline")
	end
}

return plugin
