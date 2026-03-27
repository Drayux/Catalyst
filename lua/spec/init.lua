--- <spec>.lua - Aggregator for 'spec helper' classes

local Module = {
	Feature = require("lua.spec._feature"),
	System = require("lua.spec._system"),
}
Module.__index = Module
Module.__newindex = function()
	error("[<spec>.lua] Bad access; module is read-only")
end

return setmetatable({}, Module)
