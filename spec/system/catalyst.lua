-- >>> CATALYST SYSTEM SPEC

local spec = {
	-- name = "catalyst", -- Set by options parser
	score = function()
		local shell_handle = io.popen("hostname")
		local output = shell_handle:read("*a"):match("^(catalyst)")
		shell_handle:close()

		return output and 10 or 0
	end,

	-- TODO: Not sure quite how to have feature selection work with the system
	-- selection. TLDR some config is only for one computer and some computers
	-- wont use some config (i.e. nvidia-related configuration.) If only one
	-- computer uses a feature, then it's relatively easy to place the entire
	-- config into the overrides.
	--
	-- However if only one computer does not use a feature, some way to
	-- conveniently exclude that feature would be preferred. (This is the major
	-- takeaway of this TODO.)

	exclude_features = { },
}

return spec
