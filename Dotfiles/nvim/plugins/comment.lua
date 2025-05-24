-- PLUGIN: comment.nvim
-- SOURCE: https://github.com/numToStr/Comment.nvim
-- LEVEL: USER

-- Extra comment string functionality

local spec = {
	"numToStr/Comment.nvim",
	cond = condUSER,
	opts = {
		ignore = "^$", -- Ignore empty lines (lua match str)
		mappings = {
			basic = false,
			extra = false
		},
	},
	init = function()
		vim.g.comment_enabled = true
	end
}

return spec

