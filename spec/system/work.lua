-- >>> WORK SYSTEM SPEC

local spec = {
	score = function()
		local shell_handle = io.popen("hostname")
		local output = shell_handle:read("*a"):match("^(LX.+)")
		shell_handle:close()

		return output and 5 or 0
	end,

	-- See TODO in catalyst.lua
	exclude_features = { },
}

return spec
