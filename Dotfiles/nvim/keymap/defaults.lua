local binds = require("editor.binds")

-- TODO: If refactoring keymaps into tables, then this function should continue
-- to call no parameters and use the local closure
local setKeymap = function()
end


-- >> MODULE <<
local keymap = {
	_name = "defaults",
	_binds = {} -- TODO: Placeholder to save my spot, contents may be moveable to parent
}

-- Load all binds defined in this keymap
-- TODO: Force - false: only set unset binds; true: overwrite all binds
-- keymap.load = function(force)
	-- print("hello world")
-- end

-- TODO: Support a "reset" of a single key to what is defined by this map
-- (depends on moving the map into a table)

return setmetatable(keymap, binds._api)
