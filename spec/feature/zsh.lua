local spec = {
	feature = "zsh", -- Look for files in dotfiles/zsh, overrides/zsh, or scripts/zsh
	-- Third-party soft depedencies (located in the reqs directory because I
	-- hate when multiple directories begin with the same letter)
	depends = { },
	opts = {
		prefer_link = true,
		config_root = "~/.config/zsh", -- Root of target install location

		-- TODO: Considering something about needing privilege escallation?
		-- Something like this though, we'll likely only need it once per system
		system_needs_su = true,
		local_needs_su = false,
	},

	-- If specified, copy/link only files here for higher granularity
	files = { "config", "profile", "logout", --[[ ... ]] }
	-- files = {
		-- ["alt_zsh_config"] = "", -- Target: $config_root/alt_zsh_config
		-- ["alt_zsh_config_2"] = "$config_root", -- Target: $config_root/alt_zsh_config_2
		-- ["crazy_zsh_config"] = "~/.config/zsh_crazy_style",
		-- ... },
	-- TODO: The above is not yet implemented, still working out the details
	-- I think I am mostly content with putting in some hard rules:
	-- * If files tbl is present, then config_root will be generated as a folder ALWAYS
	-- * Any ipairs values have install targets: $config_root/$value (source assumed $feature/config/$value)
	-- * Directories will have contents globbed - therefore setting the target to "" will glob files into the config root (good thing!)
	-- > Therefore 'simulating' the target directory not existing; consider `mv foo/ baz/; mv bar/ baz/`
	-- > This results in baz/foo-a.txt, baz/foo-b.txt, baz/bar/bar-a.txt, ... (bad thing!)
	-- > This also makes reusing the same implementation for overrides inherently work intuitively!
	-- * (Skipping recreating the thing gpkg does with specific files from directories, config should be organized better instead)
	-- * (Considering hard-linking since we're globbing directories)

	-- Extra helper symlinks for annoying hidden dotfiles
	links = {
		-- ["link_name"] = ["link_target"] (aka links and tables are one to many)

		-- Local links because zsh looks for a file named .zshrc, not config
		[".zshrc"] = "config",
		[".zprofile"] = "profile",
		[".zlogout"] = "logout",

		-- Symlink scripts dir so that it doesn't get globbed and hard linked with files^^
		["scripts"] = "$feature_config/scripts", 
	},

	-- Config editing scripts instead of files
	edits = {
		["zprofile"] = { "/etc/zprofile", syntax = "bash" }
	},

	-- System-specific overrides
	system = {
		-- If system is not listed here, no override is defined
		-- (Same map rules as dotfiles above)
		work = {
			-- files = {}, -- Overrides spec.files if defined (does not merge)
			overrides = { -- Merges with spec.files (overwrites conflicting entries)
				["work"] = "~/.local/zsh/overrides",
			}
			-- edits = {} -- Merges with spec.edits (overwrites conflicting entires)
		},
	},
}

return spec
