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

		-- Keybinds
		-- NOTE: some keymaps set in this way could be overwritten
		-- Swapping to the keymap file/table format should mitigate this :)
		local binds = require("editor.binds")
		local bindClosure = function(_motion)
			return function()
				require("spider").motion(_motion)
			end
		end
		binds.set(binds.MOTION, "w", bindClosure("w"))
		binds.set(binds.MOTION, "e", bindClosure("e"))
		binds.set(binds.MOTION, "q", bindClosure("b"))
	end
}

return spec

