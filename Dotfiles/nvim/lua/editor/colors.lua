-- Dynamic theming
-- TODO: Determine if I can replace themer entirely
-- > As lualine now follows highlights, this could be retrofitted to the
-- > 	classic ":colorscheme xxx" format which is likely to be much faster
-- > The benefit of themer is the support for extracting themes
-- > 	to a unified format (instead of using a HighlightGroup), but right
-- > 	now, no plugins in this configuration use this

-- Function to change color scheme for themer and subsequent UI plugins
-- > Returns active theme and transparency setting
-- (This is how the theme should be changed)
local current_theme = nil
local current_transparency = nil
local retheme = function(theme, transparency)
	-- Normalize theme parameter (when called from user command)
	if type(theme) == "table" then theme = theme.args end
	if theme and (type(theme) ~= "string") then
		print("Unrecognized parameter format for theme, expected string")

		theme = nil
		transparency = nil -- Ignore transparency on bad params
	end

	-- When both are nil, we just want to get the current state
	if not (theme or transparency) then
		return current_theme, current_transparency
	end

	-- Process colorscheme
	local opts = {} -- New options table
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
		-- NOTE: Currently disabled as lualine follows the current
		-- > highlight groups anyway
		require("editor.status").retheme(colors)

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
end

-- Get a list of the available themes
-- lightmode -> Returns a list of light themes if true, else dark (default)
local list = function(lightmode)
	-- TODO: Consider making the themes directory an option (or even supporting multiple at once)
	local entries = vim.fn.readdir(vim.fn.stdpath("config") .. "/themes",
		function(name)
			-- Skip files beginning with an underscore
			if name:match("^[^_].+.lua$") then return 1 end
			return 0
		end)
	
	local suggestions = {}
	local current_idx = nil -- Curated for telescope, don't set a default if the theme is not listed
	for _, name in ipairs(entries) do
		local theme = name:gsub("%.lua$", "")
		local light = theme:match("(.+)_light$")
		if (light and lightmode) -- Light themes
			or (not light and not lightmode) -- Dark themes
		then
			local _theme = light or theme
			table.insert(suggestions, _theme)
			if (not current_idx) and (_theme == current_theme) then
				-- Since we're looping already, search for the index of the active theme
				current_idx = #suggestions
			end
		end
	end
	return suggestions, current_idx
end

-- >> Using attach_mappings in this way is a bit unintuitive
-- This function is intended for use in setting keymaps for actions within
-- the picker's lifetime. The actions.<action>:replace() routine can actually
-- be set at any time since Telescope uses a singleton instance for any of
-- its pickers. Its use here is because the buffer (bufnr) is passed to this
-- function, and this function will always be ran upon the picker's invocation.
local _mappings = function(prompt_bufnr)
	local active = retheme() -- Get the name of the current theme
	local ext = lightmode and "_light" or ""

	-- Copy of original close function
	-- Necessary because we override the original, thus causing any call to recurse indefinitely (TODO: Is there a better way to do this?)
	-- > https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/actions/init.lua#L379
	-- > https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/actions/mt.lua#L116
	local _close = function(pbnr)
		local current_picker = require("telescope.actions.state").get_current_picker(pbnr)

		local win_id = current_picker.original_win_id
		local cursor_valid, original_cursor = pcall(vim.api.nvim_win_get_cursor, win_id)

		require("telescope.actions").close_pum(pbnr)
		require("telescope.pickers").on_close_prompt(pbnr)

		pcall(vim.api.nvim_set_current_win, win_id)
		if cursor_valid
			and (vim.api.nvim_get_mode().mode == "i")
			and (current_picker._original_mode ~= "i")
		then
			pcall(vim.api.nvim_win_set_cursor, win_id, {
				original_cursor[1],
				original_cursor[2] + 1,
			})
		end
	end

	-- ENTER - Select does nothing (theme is already set, don't open a buffer)
	-- TODO: Call retheme() on selection if the previewer was disabled
	require("telescope.actions").select_default:replace(function()
		-- local selection = state.get_selected_entry()[1]
		-- if selection then retheme(selection .. ext) end
		_close(prompt_bufnr)
	end)

	-- CANCEL - Revert to original theme
	require("telescope.actions").close:replace(function()
		if active then retheme(active) end
		_close(prompt_bufnr)
	end)

	return true
end

-- Return a picker for use with telescope
local extension = function(args)
	local lightmode = args.light and true
	local themes, current = list(lightmode)
	local opts = require("telescope.themes").get_ivy({
		prompt_title = "Themes",
		results_title = false,

		layout_strategy = "center",
		layout_config = {
			-- preview_cutoff = 10, -- No apparent effect?
			prompt_position = "bottom",
			width = function(_, max_columns, _)
				return math.min(max_columns, 52) end,
			height = function(_, _, max_lines)
				return math.min(max_lines, 16) end,
		},

		border = true,
		borderchars = {
			results = { "─", "│", "─", "│", "╭", "╮", "│", "│" },
			prompt = { " ", "│", "─", "│", "├", "┤", "╯", "╰" },
			-- preview = { "", "", "", "", "", "", "", "" },
		},

		finder = require("telescope.finders").new_table({
			results = themes,
		}),
		sorter = require("telescope.config").values.generic_sorter({}),
		previewer = require("telescope.previewers").new({
			-- The previewer performs the logic of changing the theme
			-- As the theme is global, we "set" the theme by taking no action on close
			preview_fn = function(_, entry)
				local theme_name = entry[1]
				if theme_name then
					retheme(theme_name)
				end
			end,
		}),

		-- create_layout = function(picker) end,

		sorting_strategy = "ascending",
		selection_strategy = "follow",
		default_selection_index = current,

		attach_mappings = _mappings, -- See comment above _mappings()
	})

	-- Call for the telescope prompt
	local prompt = require("telescope.pickers").new(opts)
	prompt:find()
end

local module = {
	complete = list,
	select = retheme,
	setupTelescope = function()
			local extmgr = require("telescope._extensions").manager
			extmgr["themes"] = { themes = extension }
		end,
}

return module
