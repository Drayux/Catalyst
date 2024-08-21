-- PLUGIN: dracula.nvim
-- SOURCE: https://github.com/Mofiqul/dracula.nvim

-- Neovim 'dracula' theme (chadracula is the base46 port)

local plugin = {
	"Mofiqul/dracula.nvim",
	lazy = false,
	opts = {
		transparent_bg = true,
		italic_comment = true,

		colors = {
			selection = "#3c3d49",
		}
	},
	config = function(_, opts)
		require("dracula").setup(opts)
	end
}

return plugin
