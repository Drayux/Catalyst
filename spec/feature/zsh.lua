local spec = {
	feature = "zsh", -- Look for files in dotfiles/zsh, overrides/zsh, or scripts/zsh
	opts = {
		prefer_link = true,

		-- TODO: Considering something about needing privilege escallation?
		-- Something like this though, we'll likely only need it once per system
		system_needs_root = true,
		local_needs_root = false,
	},

	-- Copy/link the entire directory to this location (preferred for most config)
	-- NOTE: This may be dubious if a config directory already exists
	location = "~/.config/zsh",

	-- If specified, copy/link only the entries listed
	-- files = {
		-- ["config"] = "~/.config/zsh/config",
		-- ["profile"] = "~/.config/zsh/profile",
		-- ...
	-- },

	-- Extra helper symlinks for annoying hidden dotfiles
	links = {
		-- ["link_name"] = ["link_target"] (aka links and tables are one to many)
		[".zshrc"] = "config",
		[".zprofile"] = "profile",
		[".zlogout"] = "logout",
	},

	-- Third-party soft depedencies
	-- (reqs folder because I hate when multiple directories begin with the same letter)
	depends = { },
	
	-- Config editing scripts instead of files
	edits = {
		["zprofile"] = { "/etc/zprofile", syntax = "bash" }
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
