local spec = {
	feature = "zsh", -- Look for files in dotfiles/zsh, overrides/zsh, or scripts/zsh
	opts = {
		prefer_link = true,

		-- TODO: Considering something about needing privilege escallation?
		-- Something like this though, we'll likely only need it once per system
		system_needs_root = true,
		local_needs_root = false,
	},

	-- Copy/link the entire directory to this location
	location = "~/.config/zsh",

	-- Alternatively, copy/link selected files to these locations
	-- location = {
	--	["config"] = ["~/.config/zsh/config"],
	--	[".zshrc"] = ["~/.config/zsh/.zshrc"],
	--  ...
	-- }

	-- Third-party soft depedencies
	depends = { },
	
	-- Config editing scripts instead of files
	edits = {
		["zprofile"] = "/etc/zprofile",
	},

	-- Static override files
	-- (tecnically an entire set of dotfiles could be defined here)
	overrides = {
		-- If system is not listed here, no override is defined
		-- (Same map rules as dotfiles above)
		work = {
			location = {
				["work"] = "~/.local/zsh/overrides",
			}
		},
	},
}

return spec
