local Class = { type = "Spec:System" }
Class.__index = Class
Class.__newindex = function()
	error("Attempt to add new member to `Spec:System` class")
end

local Module = {}
Module.__index = Module
Module.__newindex = function()
	error("[system.lua] Bad access; Module is read-only")
end
Module.__call = function(_, spec_data)
	local errmsg = "[system.lua] Spec:System must be initialized with a well-formed feature spec table"
	assert(type(spec_data) == "table", errmsg)
	assert(not getmetatable(spec_data), errmsg)
	assert((type(spec_data._name) == "string")
		and (#spec_data._name > 0), "Malformed system spec; _name is nil")

	return setmetatable(spec_data, Class)
end

local Instance = {}

-- Closure to be used with dirload on_load option
-- Does not use self! (aka call Module.SpecLoad(c, m, p), not Module:SpecLoad(c, m, p))
function Module.SpecLoad(chunk, module, path)
	local call_status, spec_data = pcall(chunk)
	if not call_status then
		return nil, string.format("System spec `%s` returned error: %s", module, spec_data)

	elseif call_status and (spec_data == nil) then
		return nil, string.format("System spec `%s` did not return", module)
	end

	spec_data._name = module
	return Instance(spec_data)
end

return setmetatable(Instance, Module)
