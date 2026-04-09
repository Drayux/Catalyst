-- Extended functionality for neo-tree.nvim

-- Function exists to swap the plugin load check
local _unloaded = function() return false end
local neotree = nil -- Caches Neotree API for lazy loading
local api = {
	-- load = initPlugin,
	state = _unloaded, -- getState
	open = _unloaded, -- treeOpen
}

-- Helper function to check if Neotree is open
local getState ; getState = function(source, ...)
	-- Recursive base case
	if not source then return nil end

	local _, state = pcall(neotree.manager.get_state, source)
	local exists = state and neotree.renderer.window_exists(state)

	-- Recursion will stop if the window exists
	return (exists and source) or getState(...)
end

local treeOpen ; treeOpen = function()
	-- Document_symbols may not exist without an LSP enabled
	-- > (TODO) Setup config to dynamically detect this
	return getState("filesystem", "document_symbols", "buffers", "git_status")
end

function api.load()
	if not vim.g.neotree_enabled then return end
	if not neotree then
		neotree = {
			manager = require("neo-tree.sources.manager"),
			renderer = require("neo-tree.ui.renderer")
		}
		api.state = getState
		api.open = treeOpen
	end
end

return api
