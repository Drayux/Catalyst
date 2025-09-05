local spec = {
	feature = "zsh",
	type = "static",
	location = "~/.config/zsh",

	-- For the target system, map the file at the key to the location at the value
	overrides = {
		work = {
			["work_overrides"] = "~/.local/zsh/overrides"
		},
	}
}

return spec
