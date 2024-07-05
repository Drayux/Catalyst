-- PLUGIN: nvim-web-devicons
-- SOURCE: https://github.com/nvim-tree/nvim-web-devicons

-- Patched font support

local plugin = {
	"nvim-tree/nvim-web-devicons",
	config = function() --function(_, opts)
		dofile(vim.g.base46_cache .. "devicons")
		-- require("nvim-web-devicons").setup(opts)
	end
}

return plugin
