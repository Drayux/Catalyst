-- PLUGIN: comment.nvim
-- SOURCE: https://github.com/numToStr/Comment.nvim
-- LEVEL: USER

-- Extra comment string functionality

local spec = {
	"numToStr/Comment.nvim",
	cond = condUSER,
	init = function(_, opts)
		local toggleLine = function()
			require("Comment.api").toggle.linewise()
		end

		-- Set keybinds (will invoke lazy load)
		local EDITOR = { "n", "v" } -- Taken directly from layout (keymaps)
		map(EDITOR, "xc", toggleLine)
	end
}

return spec

