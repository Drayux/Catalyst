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
	config = function(_, opts)
		-- Apply theme-related settings
		require("themer").setup(opts)

		-- Function to change color scheme for themer and subsequent UI plugins
		-- (This is how the theme should be changed)
		-- TODO: Lualine will get a couple white artifacts left over after 1st run?
		function setHighlights(theme)
			-- Must pass a string for a theme name
			if type(theme.args) ~= "string" then return end

			-- Load the specified theme into a table
			local status, colors = pcall(require, "themes." .. theme.args)
			if not status then
				-- TODO: Make this print red text
				print("Unable to load `" .. theme.args .. "` theme")
				return
			end

			-- Build the lualine theme
			local ll_theme = nil
			local status, lualine_api = pcall(require, "lualine")
			if status then
				ll_theme = {
					normal = {
						a = { bg = colors.accent, fg = colors.bg.alt },
						b = { bg = colors.bg.alt, fg = colors.accent },
						c = { bg = colors.bg.alt, fg = colors.dimmed.subtle },
					},

					insert = {
						a = { bg = colors.diff.add, fg = colors.bg.alt },
						b = { bg = colors.bg.alt, fg = colors.diff.add },
					},

					command = {
						a = { bg = colors.diagnostic.warn, fg = colors.bg.alt },
						b = { bg = colors.dimmed.subtle, fg = colors.diagnostic.warn },
					},

					visual = {
						a = { bg = colors.accent, fg = colors.bg.selected },
						b = { bg = colors.dimmed.subtle, fg = colors.accent },
					},

					replace = {
						a = { bg = colors.diff.delete, fg = colors.bg.alt },
						b = { bg = colors.dimmed.subtle, fg = colors.diff.delete },
					},

					inactive = {
						a = { bg = colors.bg.alt, fg = colors.accent },
						b = { bg = colors.bg.alt, fg = colors.dimmed.subtle, gui = "bold" },
						c = { bg = colors.bg.alt, fg = colors.dimmed.subtle },
					},
				}
			end

			-- Apply color schemes
			require("themer").setup({ colorscheme = colors })
			if ll_theme then lualine_api.setup({ options = { theme = ll_theme }}) end
		end

		-- Add setHightlights as a vim user command (:Highlight)
		vim.api.nvim_create_user_command("Highlight", setHighlights, {
			nargs = 1,
			desc = "Change editor color theme (highlights)",
		})

		-- Add VimEnter event that calls :Highlight with a default theme
		vim.api.nvim_create_autocmd({ "VimEnter" }, {
			callback = function()
				-- TODO: Themer appears to bug out with the transparency option
				-- ^^For some reason, initially loading only some themes first works (so this is a hacky workaround)
				setHighlights({ args = "ayu" })

				local default = vim.g.default_theme or "draycula"
				setHighlights({ args = default })
			end
		})
	end
}

return plugin

