-- PLUGIN: midnight.nvim
-- SOURCE: https://github.com/dasupradyumna/midnight.nvim
-- LEVEL: BASE

-- Fallback theme when not using themer for dynamic theming

local spec = {
	-- "ribru17/bamboo.nvim",
	"dasupradyumna/midnight.nvim",
	cond = function()
		return (condBASE() or (vim.g.disable_themer))
			and condUSER() end,
	lazy = false,
	priority = 1000,
	config = function()
		-- require("bamboo").load()
		require("midnight").load()
	end
}

return spec
