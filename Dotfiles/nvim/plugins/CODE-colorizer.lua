-- PLUGIN: nvim-colorizer.lua
-- SOURCE: https://github.com/norcalli/nvim-colorizer.lua

-- Highlights color codes (i.e. #551bdf) with the reflected color

local plugin = {
	"NvChad/nvim-colorizer.lua",
	event = { "BufEnter" },
	opts = {
		user_default_options = { names = false }
	},
	config = function(_, opts)
		require("colorizer").setup(opts)
		vim.defer_fn(function()
			require("colorizer").attach_to_buffer(0)
		end, 0)
	end
}

return plugin

