-- PLUGIN: telescope.nvim
-- SOURCE: https://github.com/nvim-telescope/telescope.nvim

-- Fuzzy finder utility

local plugin = { 
	"nvim-telescope/telescope.nvim",	
	tag = "0.1.8",
	dependencies = { 'nvim-lua/plenary.nvim' },
	cmd = { "Telescope" },
	opts = {
		-- Note that missing extensions do not throw errors
		extensions = { "directory", "projections", "file_browser", "themes" }
	},
	config = function(_, opts)
		local telescope = require("telescope")
		telescope.setup(opts)
		for _, ext in ipairs(opts.extensions) do
			telescope.load_extension(ext)
		end
	end
}

return plugin
