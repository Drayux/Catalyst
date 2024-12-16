-- PLUGIN: twilight.nvim
-- SOURCE: https://github.com/folke/twilight.nvim

-- Zen-mode type plugin to only highlight code in the current context

local plugin = {
	"folke/twilight.nvim",
	cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
	opts = {
		dimming = {
			alpha = 0.25, -- amount of dimming
			-- we try to get the foreground from the highlight groups or fallback color
			color = { "Normal", "#ffffff" },
			term_bg = "#000000", -- if guibg=NONE, this will be used to calculate text color
			inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
		},
		context = 99, -- amount of lines we will try to show around the current line
		treesitter = true, -- use treesitter when available for the filetype
		-- expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
		-- 	"function",
		-- 	"method",
		-- 	"table",
		-- 	"if_statement",
		-- },
		-- exclude = {}, -- exclude these filetypes
	},
	config = function(_, opts)
		require("twilight").setup(opts)
		-- TODO: Automatically enable when entering insert mode and disable on exit
	end
}

return plugin

