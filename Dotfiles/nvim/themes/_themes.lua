-- Custom themer integration for telescope

-- Get a list of the available themes
local list = function()
	-- TODO: Consider making the themes directory an option (or even supporting multiple at once)
	local entries = vim.fn.readdir(vim.fn.stdpath("config") .. "/themes",
		function(name)
			-- Skip files beginning with an underscore
			if name:match("^[^_].+.lua$") then return 1 end
			return 0
		end)
	
	local suggestions = {}
	for _, name in ipairs(entries) do
		local theme = name:gsub("%.lua$", "")
		table.insert(suggestions, theme)
	end
	return suggestions
end

-- Function to change color scheme for themer and subsequent UI plugins
-- (This is how the theme should be changed)
-- TODO: Lualine will get a couple white artifacts left over after 1st run?
local current_theme = nil
-- local current_transparency = nil
local select = function(theme)
	-- Normalize theme entry to string
	if not theme then theme = current_theme end -- For swapping transparency settings
	if type(theme) == "table" then theme = theme.args end -- Called from autocommand
	if type(theme) ~= "string" then return current_theme end -- Called from another plugin

	-- Check if theme is already active
	if theme == current_theme then return current_theme end

	-- Load the specified theme into a table
	local status, colors = pcall(require, "themes." .. theme)
	if not status then
		-- TODO: Make this print red text
		print("Unable to load `" .. theme .. "` theme")
		return current_theme
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

	current_theme = theme
	return theme -- Return the name of the active theme
end

-- Return a picker for use with telescope
local extension = function()
	local themes = list()
	local opts = require("telescope.themes").get_ivy({
		finder = require("telescope.finders").new_table({
			results = themes,
		}),
		sorter = require("telescope.config").values.generic_sorter({}),
		sorting_strategy = "ascending",
		previewer = false,

		prompt_title = "Themes",
		results_title = false,
		
		layout_strategy = "center",
		layout_config = {
			preview_cutoff = 1,
			width = function(_, max_columns, _)
				return math.min(max_columns, 48) end,
			height = function(_, _, max_lines)
				return math.min(max_lines, 12) end,
		},

		border = true,
		borderchars = {
			prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
			results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
			preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		},

		attach_mappings = function(prompt_bufnr, map)
			local active = select() -- Get the name of the current theme

			local actions = require("telescope.actions")
			local set = require("telescope.actions.set")
			local state = require("telescope.actions.state")

			-- NOTE: Currently not changing theme on load
			-- This is doable, but I want the arrow keys to feel like
			-- an explicit "preview this theme" action

			-- Trigger theme on move up/down actions
			actions.move_selection_previous:replace(function()
				set.shift_selection(prompt_bufnr, -1)
				select(state.get_selected_entry()[1])
			end)

			actions.move_selection_next:replace(function()
				set.shift_selection(prompt_bufnr, 1)
				select(state.get_selected_entry()[1])
			end)

			-- Trigger theme on text entry (as this may select a new theme)
			vim.schedule(function()
				vim.api.nvim_create_autocmd("TextChangedI", {
					buffer = prompt_bufnr,
					callback = function()
						local selection = state.get_selected_entry()[1]
						if selection then select(selection) end
						end,
				})
			end)

			-- Revert to original theme if cancelled
			actions.close:replace(function()
				if active then select(active) end
				actions.close:original(prompt_bufnr)
			end)

			-- Don't open a new buffer on selection
			actions.select_default:replace(function()
				-- > Do something here, if desired
				local selection = state.get_selected_entry()[1]
				if selection then select(selection) end
				-- close(prompt_bufnr)
			end)

			return true end,
	})

	-- Call for the telescope prompt
	local prompt = require("telescope.pickers").new(opts)
	prompt:find()
end

local module = {
	set = select,
	complete = list,
	ext = function()
		local extmgr = require("telescope._extensions").manager
		extmgr["themes"] = { themes = extension } end,
}

return module

