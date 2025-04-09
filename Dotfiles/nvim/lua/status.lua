-- Lualine extended functionality

-- TODO: Retheme command
-- > (currently within theme.lua -> select)
-- NOTE: Some weird considerations are at hand here
-- > Alike telescope x themer, they can function independently
-- > We don't want to set anything unless lualine exists *and*
-- >	is already loaded (themer should not load lualine)
-- > *This is a functionality extension of lualine*

-- Similar to LualineBuffersJump, delete a buffer at a target index
local deleteBuffer = function(argtable)
	local idx = argtable.args
	if #idx == 0 then idx = 0
	else
		_, idx = pcall(tonumber, argtable.args)
		if not idx then 
			print("Could not close `" .. tostring(idx) .. "`")
			return
		end
	end

	-- sp : Split screen
	-- LualineBuffersJump : Jump to the previous buffer
	-- bd!(?) : Delete current buffer (including the split, so the new one takes its place)
	--	^^Original split has the active buffer before deleting

	if idx > 0 then
		vim.cmd("bp")
	end

	vim.cmd("sp")
	vim.cmd("LualineBuffersJump " .. tostring(idx))
	vim.cmd("bd" .. (argtable.bang and "!" or ""))
end

-- >>> Reference colorscheme
local colors = {
	black  = "#080808",
	grey   = "#303030",
	white  = "#c6c6c6",
	red    = "#ff5189",
	orange = "#fa9a55",
	green  = "#80ff82",
	cyan   = "#79dac8",
	blue   = "#80a0ff",
	purple = "#a877ed",
	violet = "#d183e8",
}

local theme = {
	normal = {
		a = { fg = colors.black, bg = colors.blue },
		b = { fg = colors.white, bg = colors.grey },
		c = { fg = colors.white },
	},

	insert = { a = { fg = colors.black, bg = colors.green }},
	visual = { a = { fg = colors.black, bg = colors.cyan }},
	replace = { a = { fg = colors.black, bg = colors.orange }},
	command = { a = { fg = colors.black, bg = colors.purple }},

	inactive = {
		a = { fg = colors.white, bg = colors.black },
		b = { fg = colors.white, bg = colors.black },
		c = { fg = colors.white },
	}
}
-- >>>

-- Rebuild the colors used by lualine (TODO: Pulled from themer api)
-- > Expects a table following the themer color format 
local updateTheme = function(colors)
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

local api = {
	delete = deleteBuffer,
	--retheme = updateTheme,
	retheme = function() end,
}

return api
