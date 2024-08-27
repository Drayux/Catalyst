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
local select = function(theme)
	-- Must pass a string for a theme name
	if type(theme) == "table" then theme = theme.args end
	if type(theme) ~= "string" then return end

	-- Load the specified theme into a table
	local status, colors = pcall(require, "themes." .. theme)
	if not status then
		-- TODO: Make this print red text
		print("Unable to load `" .. theme .. "` theme")
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

-- Return a picker for use with telescope
local extension = function()
	local themes = list()
	local opts = require("telescope.themes").get_ivy({
		prompt_title = "Themer ColorScheme",
		results_title = "Change colorscheme",
		finder = require("telescope.finders").new_table({
			results = themes,
		}),
		previewer = false,
		attach_mappings = function(prompt_bufnr, map)
			for type, value in pairs(require("themer.config")("get").telescope_mappings) do
				for bind, method in pairs(value) do
					map(type, bind, function()
						if method == "enter" then
							local selection = require("telescope.actions.state").get_selected_entry()
							select(selection[1])
							require("telescope.actions").close(prompt_bufnr)

						-- elseif method == "next_color" then next_color(prompt_bufnr)

						-- elseif method == "prev_color" then prev_color(prompt_bufnr)

						-- elseif method == "preview" then
						-- 	print("previewing!")
						-- 	local selection = require("telescope.actions.state").get_selected_entry()
						-- 	select(selection[1])
						-- 	require("telescope.actions").close(prompt_bufnr)
						end
					end)
				end
			end
			return true end,
		sorter = require("telescope.config").values.generic_sorter({}),
		layout_config = {
			width = 0.99,
			height = 0.5,
			preview_cutoff = 0,
			prompt_position = "top",
			horizontal = {
				preview_width = 0.65,
			},
			vertical = {
				preview_width = 0.65,
				width = 0.9,
				height = 0.95,
				preview_height = 0.5,
			},
			flex = {
				preview_width = 0.65,
				horizontal = {},
			},
		},
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

