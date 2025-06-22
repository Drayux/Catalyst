-- PLUGIN: themer.lua / midnight.nvim
-- SOURCE: https://github.com/ThemerCorp/themer.lua / https://github.com/dasupradyumna/midnight.nvim
-- LEVEL: GUI / BASE

-- Dynamic theme utility
-- > In GUI mode, load themer - the theme utility plugin
-- > Otherwise, load a fallback theme

vim.g.disable_themer = false -- Debugging override

local api = require("editor").colors
local spec = {
	"ThemerCorp/themer.lua",
	cond = function()
		return not (vim.g.disable_themer or condBASE()) end,
	event = { "VimEnter" },
	opts = {
		-- Currently default to transparent mode; may want to change this later (or just move the setting)
		transparent = false,
		default = "draycula",
	},
	init = function()
		vim.g.themer_enabled = true

		-- TODO: If further conditions for themer are not met, then
		-- > remove themer from the spec and load midnight.nvim instead
	end,
	config = function(_, opts)
		-- >> Set up user commands
		local rethemeCmd = "Retheme"
		vim.api.nvim_create_user_command(rethemeCmd, api.select, {
			nargs = 1,
			desc = "Change editor color theme (highlights)",
			complete = list,
		})
		vim.cmd("ca colorscheme " .. rethemeCmd)

		-- Add transparency toggling as a user command
		-- TODO: This could stand to be changed as a param of setHighlights (perhaps unnecessary, however)
		vim.api.nvim_create_user_command("ToggleTransparent", function(args)
			print("big sadge, themer doesn't currently support transparency hot-swapping :(")
			if true then return end

			local mode = args.args
			if mode == "false" then mode = false
			elseif mode == "true" then mode = true
			else
				_, mode = api.select() -- Get current config

				-- Enable transparency if unset (themer defaults to no transparency)
				if mode == nil then mode = true end
			end
			
			api.select(nil, mode)
		end, {
			nargs = "?",
			desc = "Change editor transparency mode",
		})

		-- >> Load telescope key bindings
		-- NOTE: This may not be sufficent when both plugins are lazy-loaded
		if vim.g.telescope_enabled then
			require("editor.binds").command("ft", "Telescope themes")
			require("editor.binds").command("flt", "Telescope themes light=true")
		end

		-- >> Set the default theme
		-- HACK: Themer appears to bug out with the transparency option
		-- ^^For some reason, initially loading only a specific few themes first works
		-- TODO: "Base" fallback theme (midnight.nvim?)
		api.select("ayu_light", opts.transparent or false)

		-- TODO: If option is present, then run setHighlights a second time (once fallback "_base" is created)
		local default = opts["default"] or "draycula"
		api.select({ args = default })
	end
}

return spec
