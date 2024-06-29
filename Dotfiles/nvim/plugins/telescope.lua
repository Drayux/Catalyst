-- PLUGIN: telescope.nvim
-- SOURCE: https://github.com/nvim-telescope/telescope.nvim

-- Fuzzy finder utility
-- TODO: Don't save an empty buffer as "No title" window when opening something else
return { 
	"nvim-telescope/telescope.nvim",	
	tag = "0.1.8",
	dependencies = { 'nvim-lua/plenary.nvim' },
	cmd = "Telescope"
}
