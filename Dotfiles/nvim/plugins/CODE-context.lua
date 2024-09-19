-- PLUGIN: nvim-treesitter-context
-- SOURCE: https://github.com/nvim-treesitter/nvim-treesitter-context

-- Pin current code context to top of editor
-- TODO: Add the highlight groups to customize color of floating context

local plugin = {
	"nvim-treesitter/nvim-treesitter-context",
	lazy = false,
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = { -- https://github.com/nvim-treesitter/nvim-treesitter-context?tab=readme-ov-file#configuration
		enable = true,
		mode = "cursor", -- "topline",
		-- separator = "",
		min_window_height = 24,
		max_lines = 8,
		multiline_threshold = 1,
		trim_scope = "outer", -- "inner"
	},
	config = function(_, opts)
		require("treesitter-context").setup(opts)
	end
}

return plugin
