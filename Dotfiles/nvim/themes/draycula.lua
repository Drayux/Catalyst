-- Dray's custom NVIM highlights
-- Built off of dracula-soft, for use with themer.lua

local base = {
	base00 = "#292A35",
	base01 = "#3a3c4e",
	base02 = "#44475a", -- Selection maybe
	base03 = "#70747f",
	base04 = "#62d6e8",
	base05 = "#e9e9f4",
	base06 = "#70747f",
	base07 = "#ff95ef",
	base08 = "#FDC38E",
	base09 = "#BAA0E8",
	base0A = "#A7DFEF",
	base0B = "#ffffa5",
	base0C = "#A7DFEF",
	base0D = "#69ff94",
	base0E = "#ff92df",
	base0F = "#f7f7fb",
	white = "#F6F6F5",
	darker_black = "#232531", -- 1c1c1c
	black = "#292A35", --  nvim bg
	black2 = "#303341",
	one_bg = "#373844", -- real bg of onedark
	one_bg2 = "#44475a", -- Selection maybe
	one_bg3 = "#565761",
	grey = "#5e5f69",
	grey_fg = "#666771",
	grey_fg2 = "#6e6f79",
	light_grey = "#73747e",
	red = "#E95678", -- DD6E6B
	baby_pink = "#DE8C92",
	pink = "#E48CC1",
	line = "#373844", -- for lines like vertsplit
	green = "#69ff94", -- 87E58E
	vibrant_green = "#69FF94",
	nord_blue = "#b389ef",
	blue = "#BAA0E8",
	yellow = "#E8EDA2",
	sun = "#FFFFA5",
	purple = "#BAA0E8",
	dark_purple = "#BAA0E8",
	teal = "#0088cc",
	orange = "#FDC38E",
	cyan = "#A7DFEF",
	statusline_bg = "#2b2d39",
	lightbg = "#343642",
	lightbg2 = "#2f313d",
	pmenu_bg = "#b389ef",
	folder_bg = "#BAA0E8",

	-- Unmatched colors

	-- bright_red = "#E1837F",
	-- bright_green = "#97EDA2",
	-- bright_yellow = "#F6F6B6",
	-- bright_blue = "#D0B5F3",
	-- bright_magenta = "#E7A1D7",
	-- bright_cyan = "#BCF4F5",
	-- bright_white = "#FFFFFF", -- index 15
	--
	-- menu = "#21222C",
	-- visual = "#3E4452",
	-- gutter_fg = "#4B5263",
	-- nontext = "#3B4048",
}

local palette = {
	-- Legacy colors for compatibility
	red = base.red,
	yellow = base.yellow,
	orange = base.orange,
	magenta = base.dark_purple,
	blue = base.blue,
	green = base.green,
	cyan = base.teal,

	-- The new shiny boy
	directory = base.folder_bg,
	fg = base.white,
	diff = {
		add = base.green,
		remove = base.red,
		text = base.blue,
		change = base.yellow,
	},
	accent = base.base0C,
	search_result = { fg = base.base01, bg = base.base0A, telescope = base.base0A },
	match = base.base06,
	dimmed = {
		inactive = base.base03,
		subtle = base.grey_fg,
	},
	bg = {
		base = base.base00,
		alt = base.darker_black,
		selected = base.base02,
	},
	border = base.blue,
	syntax = {
		statement = base.base08,
		["function"] = base.base0D,
		variable = base.base05,
		include = base.base0D,
		keyword = base.base0E,
		struct = base.base0E,
		string = base.base0B,
		identifier = base.base08,
		field = base.base0A,
		parameter = base.base08,
		property = base.base08,
		punctuation = base.base0F,
		constructor = base.base0C,
		operator = base.base05,
		preproc = base.base0A,
		constant = base.base09,
		todo = { fg = base.base0A, bg = base.base01 },
		number = base.base09,
		comment = base.base03,
		type = base.base0A,
		conditional = base.base0E,
	},
	built_in = {
		["function"] = base.base0C,
		type = base.base0A,
		variable = base.base0C,
		keyword = base.base0E,
		constant = base.base09,
	},
	diagnostic = {
		error = base.red,
		warn = base.yellow,
		info = base.green,
		hint = base.purple,
	},
	inc_search = { fg = base.base01, bg = base.base09 },
	uri = base.base08,
	pum = {
		fg = base.base06,
		bg = base.one_bg,
		sbar = base.one_bg2,
		thumb = base.nord_blue,
		sel = {
			bg = base.pmenu_bg,
			fg = base.base05,
		},
	},
	heading = {
		h1 = base.blue,
		h2 = base.blue,
	},
}

return palette

