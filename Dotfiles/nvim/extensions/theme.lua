-- Custom themer integration for telescope
-- This file will be linked to within themer: (.../lua/telescope/_extensions/colorscheme)

local themes = function()
	-- local colors = get_theme()
	local opts = require("telescope.themes").get_ivy({
		prompt_title = "Themer ColorScheme",
		results_title = "Change colorscheme",
		finder = require("telescope.finders").new_table({
			results = {"apples", "bananas", "coconuts"},
		}),
		previewer = false,
		-- attach_mappings = function(prompt_bufnr, map)
		-- 	for type, value in pairs(require("themer.config")("get").telescope_mappings) do
		-- 		for bind, method in pairs(value) do
		-- 			map(type, bind, function()
		-- 				if method == "enter" then enter(prompt_bufnr)
		-- 				elseif method == "next_color" then next_color(prompt_bufnr)
		-- 				elseif method == "prev_color" then prev_color(prompt_bufnr)
		-- 				elseif method == "preview" then preview(prompt_bufnr)
		-- 				end
		-- 			end)
		-- 		end
		-- 	end
		-- 	return true end,
		sorter = require("telescope.config").values.generic_sorter({}),
		layout_config = {
			width = 0.99,
			height = 0.5,
			preview_cutoff = 20,
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
	local themes = require("telescope.pickers").new(opts)
	themes:find()
end

return require("telescope").register_extension({
	exports = { highlight = themes }
})
