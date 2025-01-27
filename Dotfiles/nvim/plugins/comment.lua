-- PLUGIN: comment.nvim
-- SOURCE: https://github.com/numToStr/Comment.nvim
-- LEVEL: USER

-- Extra comment string functionality

local spec = {
	"numToStr/Comment.nvim",
	cond = condUSER,
	event = { "BufEnter" }, -- VimEnterPost at the earliest (because of base key mapping event)
	-- > Alternatively, lazy load and set the keybind with `require("Comment.api").toggle.linewise()`
	opts = {
		mappings = {
			basic = true
		},
		-- TODO: Explore extra features
		-- > https://github.com/numToStr/Comment.nvim/blob/master/lua/Comment/init.lua#L98
		toggler = {
			line = "xc",
			block = "xC",
		},
		opleader = {
			line = "xc",
			block = "xC",
		}
	},
	-- config = function(_, opts)
	-- 	require("Comment").setup(opts)
	--
	-- 	local api = require("Comment.api")
	-- 	if api then
	-- 		-- Set additional comment keybinds
	-- 	end
	-- end
}

return spec

