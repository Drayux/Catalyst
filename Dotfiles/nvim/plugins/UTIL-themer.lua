-- PLUGIN: themer.lua
-- SOURCE: https://github.com/ThemerCorp/themer.lua

-- Theming utility plugin

local plugin = {
	"ThemerCorp/themer.lua",
	lazy = false,
	priority = 1000,
	opts = {
		-- Currently default to transparent mode; may want to change this later (or just move the setting)
		transparent = false,
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

		-- Add transparency toggling as a user command
		-- TODO: This could stand to be changed as a param of setHighlights (perhaps unnecessary, however)
		vim.api.nvim_create_user_command("ToggleTransparent", function(args)
			print("big sadge, themer doesn't currently support transparency hot-swapping :(")
			if true then return end

			local mode = args.args
			if mode == "false" then mode = false
			elseif mode == "true" then mode = true
			else
				_, mode = setHighlights() -- Get current config

				-- Enable transparency if unset (themer defaults to no transparency)
				if mode == nil then mode = true end
			end
			
			setHighlights(nil, mode)
		end, {
			nargs = "?",
			desc = "Change editor transparency mode",
		})
		
		-- Add VimEnter event that calls :Highlight with a default theme
		vim.api.nvim_create_autocmd({ "VimEnter" }, {
			callback = function()
				-- TODO: Themer appears to bug out with the transparency option
				-- ^^For some reason, initially loading only a specific few themes first works (so this is a hacky workaround)
				-- TODO: "Base" fallback theme
				setHighlights("ayu", opts.transparent or false)

				-- TODO: If option is present, then run setHighlights a second time (once fallback "_base" is created)
				local default = vim.g.default_theme or "draycula"
				setHighlights({ args = default })
			end
		})
	end
}

return plugin

