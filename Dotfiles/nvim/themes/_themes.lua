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
-- Returns active theme and transparency setting
-- (This is how the theme should be changed)
-- TODO: Lualine will get a couple white artifacts left over after 1st run?
local current_theme = nil
local current_transparency = nil
local select = function(theme, transparency)
	-- Normalize theme parameter (when called from user command)
	if type(theme) == "table" then theme = theme.args end
	if theme and (type(theme) ~= "string") then
		print("Unrecognized parameter format for theme, expected string")

		theme = nil
		transparency = nil -- Ignore transparency on bad params
	end

	-- When both are nil, we just want to get the current state
	if not theme and transparency ~= nil then
		return current_theme, current_transparency
	end
	
	--------
	
	-- Themer.nvim options table
	local opts = {}

	-- Process colorscheme
	if theme and (theme ~= current_theme) then
		-- Load the specified theme into a table
		local status, colors = pcall(require, "themes." .. theme)
		if not status then
			-- TODO: Make this print red text
			print("Unable to load `" .. theme .. "` theme")

			-- Don't set transparency if invalid theme name
			return current_theme, current_transparency
		end

		opts.colorscheme = colors

		-- Build the lualine theme (if lualine is installed)
		local lualine_theme = nil
		local status, lualine_api = pcall(require, "lualine")
		if status then
			lualine_theme = {
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

			-- Apply the lualine theme
			lualine_api.setup({ options = { theme = lualine_theme }})
		end
	end

	-- Set transparency
	-- NOTE: When transparency is nil, keep current
	if (transparency ~= nil) and (transparency ~= current_transparency) then
		-- Funny syntax normalizes the "transparency" param to a boolean
		opts.transparent = (transparency and true) or false
	end

	-- Commit the new highlights (with Themer.nvim)
	if opts.transparent ~= nil or opts.colorscheme then
		require("themer").setup(opts)
		current_theme = theme or current_theme

		if transparency ~= nil then
			current_transparency = transparency
		end
	end

	return current_theme, current_transparency -- Return the name of the active theme
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
				return math.min(max_columns, 40) end,
			height = function(_, _, max_lines)
				return math.min(max_lines, 16) end,
		},

		border = true,
		borderchars = {
			prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
			results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
			preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		},

		-- TODO: Keybind to preview theme maybe?
		attach_mappings = function(prompt_bufnr)
			local active = select() -- Get the name of the current theme

			local actions = require("telescope.actions")
			local set = require("telescope.actions.set")
			local state = require("telescope.actions.state")

			-- Original close function (TODO: Is there a better way to do this?)
			-- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/actions/init.lua#L379
			local close = function(pbnr)
				local picker = state.get_current_picker(pbnr)
				local win_id = picker.original_win_id
				local cursor_valid, cursor = pcall(vim.api.nvim_win_get_cursor, win_id)

				actions.close_pum(pbnr)
				require("telescope.pickers").on_close_prompt(pbnr)

				pcall(vim.api.nvim_set_current_win, win_id)
				if cursor_valid and (vim.api.nvim_get_mode().mode == "i") and (picker._original_mode ~= "i") then
					pcall(vim.api.nvim_win_set_cursor, win_id, {
						cursor[1],
						cursor[2] + 1,
					})
				end
			end

			-- ENTER - Don't open a new buffer, just set the theme
			actions.select_default:replace(function()
				-- > Do something here, if desired
				local selection = state.get_selected_entry()[1]
				if selection then select(selection) end
				close(prompt_bufnr)
			end)

			-- CANCEL - Revert to original theme
			actions.close:replace(function()
				if active then select(active) end
				close(prompt_bufnr)
			end)

			-- ARROW-UP - Trigger theme preview (and move selection up)
			actions.move_selection_previous:replace(function()
				set.shift_selection(prompt_bufnr, -1)
				select(state.get_selected_entry()[1])
			end)

			-- ARROW-DOWN - Trigger theme preview (and move selection down)
			actions.move_selection_next:replace(function()
				set.shift_selection(prompt_bufnr, 1)
				select(state.get_selected_entry()[1])
			end)

			-- NOTE: Currently not changing theme on load
			-- This is doable, but I want the arrow keys to feel like
			-- an explicit "preview this theme" action

			-- Trigger theme on text entry (as this may select a new theme)
			-- Enable this only when also previewing by default^^
			-- TODO: Does this "leak"?
			-- vim.schedule(function()
			-- 	vim.api.nvim_create_autocmd("TextChangedI", {
			-- 		buffer = prompt_bufnr,
			-- 		callback = function()
			-- 			local selection = state.get_selected_entry()[1]
			-- 			if selection then select(selection) end
			-- 			end,
			-- 	})
			-- end)

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
