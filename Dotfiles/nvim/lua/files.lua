-- Extended functionality for neo-tree.nvim

-- Helper function to check if Neotree is open
local getState ; getState = function(source, ...)
	-- Recursive base case
	if not source then return nil end

	local state = require("neo-tree.sources.manager").get_state(source)
	local exists = require("neo-tree.ui.renderer").window_exists(state)

	-- Recursion will stop if the window exists
	return (exists and source) or getState(...)
end

local isOpen = function()
	if not vim.g.neotree_enabled then
		return false
	end
	return getState("filesystem", "document_symbols", "buffers", "git_status")
end

local api = {
	state = getState,
	open = isOpen,
}

return api
