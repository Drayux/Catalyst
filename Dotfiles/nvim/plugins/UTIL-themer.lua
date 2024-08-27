-- PLUGIN: themer.lua
-- SOURCE: https://github.com/ThemerCorp/themer.lua

-- Theming utility plugin

local plugin = {
	"ThemerCorp/themer.lua",
	lazy = false,
	priority = 1000,
	opts = {
		transparent = true,
	},
	build = function()
		-- TODO: Create symlink to extensions/theme
	end,
	config = function(_, opts)
		-- Apply theme-related settings
		require("themer").setup(opts)

		-- Add setHightlights as a vim user command
		local setHighlightsCmd = "Theme"
		local setHighlights = require("themes._themes").set
		vim.api.nvim_create_user_command(setHighlightsCmd, setHighlights, {
			nargs = 1,
			desc = "Change editor color theme (highlights)",
			complete = require("themes._themes").complete,
		})
		vim.cmd("ca colorscheme " .. setHighlightsCmd)
		
		-- Add VimEnter event that calls :Highlight with a default theme
		vim.api.nvim_create_autocmd({ "VimEnter" }, {
			callback = function()
				-- TODO: Themer appears to bug out with the transparency option
				-- ^^For some reason, initially loading only a specific few themes first works (so this is a hacky workaround)
				setHighlights({ args = "ayu" })

				local default = vim.g.default_theme or "draycula"
				setHighlights({ args = default })
			end
		})
	end
}

return plugin

