-- PLUGIN: telescope.nvim
-- SOURCE: https://github.com/nvim-telescope/telescope.nvim

-- Fuzzy finder utility

local plugin = { 
	"nvim-telescope/telescope.nvim",	
	-- tag = "0.1.8",
	dependencies = { 'nvim-lua/plenary.nvim' },
	cmd = { "Telescope" },
	-- opts = { extensions = { "directory", "projections", "file_browser", "themes" }}
	config = function(_, opts)
		local telescope = require("telescope")
		telescope.setup(opts)

		-- Load the custom themer extension from the dotfiles
		require("themes._themes").ext()

		-- Load extensions early so that their autocompletes are generated
		-- telescope.load_extension(ext)
	end
}

return plugin

