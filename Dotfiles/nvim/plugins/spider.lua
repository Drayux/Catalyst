-- PLUGIN: nvim-spider
-- SOURCE: https://github.com/chrisgrieser/nvim-spider
-- LEVEL: USER

-- Improved W/E/Q motions
-- (TODO) Plugins for additional functionality
-- > https://github.com/nvim-treesitter/nvim-treesitter-textobjects
-- > (alternatively) https://github.com/chrisgrieser/nvim-various-textobjs

local spec = {
	"chrisgrieser/nvim-spider",
	cond = condUSER,
	init = function()
		vim.g.spider_enabled = true

		-- Set keymaps
		-- > Note that some keymaps set in this way could be overwritten!
		local MOTION = "" -- (copied from plugin.lua)
		map(MOTION, "w", "<cmd>lua require('spider').motion('w')<cr>")
		map(MOTION, "e", "<cmd>lua require('spider').motion('e')<cr>")
		map(MOTION, "q", "<cmd>lua require('spider').motion('b')<cr>")
	end
}

return spec

