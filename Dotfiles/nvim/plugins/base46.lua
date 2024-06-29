return { "NvChad/base46",
	-- ^^Depends on NvChad/ui (for "nvconfig") and nvim-lua/plenary.nvim (to build bytecode)
		branch = "v2.5",
		lazy = false,
        dependencies = { 'nvim-lua/plenary.nvim' },
		build = function() require("base46").load_all_highlights() end,
		config = function()
			require("base46").load_all_highlights()
			dofile(vim.g.base46_cache .. "defaults")
			dofile(vim.g.base46_cache .. "statusline")
		end
	}
