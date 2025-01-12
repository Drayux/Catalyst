-- PLUGIN: telescope.nvim
-- SOURCE: https://github.com/nvim-telescope/telescope.nvim
-- LEVEL: CORE

-- Fuzzy finder utility

local spec = { 
	"nvim-telescope/telescope.nvim",	
	cond = condCORE,
	cmd = { "Telescope" },
	dependencies = { 'nvim-lua/plenary.nvim' },
	init = function()
		vim.g.telescope_enabled = true

		-- Plugin keybinds
		mapcmd("ff", "Telescope find_files")
		mapcmd("fe", "Telescope buffers")
		mapcmd("fg", "Telescope live_grep")
	end,
	config = function(_, opts)
		-- Load plugin integrations
		if vim.g.themer_enabled then
			local _, api = pcall(require, "colors")
			if api then
				api.setupTelescope()
			end
		end

		-- Load extensions early so that their autocompletes are generated
		-- opts = { extensions = { "directory", "projections", "file_browser", "themes" }}
		-- telescope.load_extension(ext)

		-- Projections
		-- vim.keymap.set('n', '<leader>fp', "<cmd>Telescope projections<cr>")
	end
}

return spec
