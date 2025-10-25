local spec = {
	feature = "zsh", -- Look for files in dotfiles/zsh, overrides/zsh, or scripts/zsh
	-- Third-party soft dependencies (check scripts in the reqs/ directory)
	depends = { "zsh-syntax-highlighting" },

	-- Values that affect how the script processes this spec(?)
	opts = {
		prefer_link = true,

		-- TODO: Considering something about needing privilege escallation?
		-- Something like this though, we'll likely only need it once per system
		system_needs_su = true,
		local_needs_su = false,
		-- Also TODO: When true, feature will not be set to install with the ALL keyword
		ignore_select_all = false,
		-- Alternatively, perhaps 'hidden = true/false' so it doesn't show up at all? (Maybe 'deprecated'?)

		---

		-- TODO: Consider moving these two to a vars table (perhaps the feature name--above--as well)
		install_root = "~/.config/zsh", -- Root of target install location
		-- feature_config = "$feature_root/config", -- Override if defined (should be rare; must be abs path)
	},

	-- FILES TABLE RULES:
	-- * If present, install_root always assumed to be a directory
	-- ** Thus a directory at $install_root will be generated;
	-- ** Else a symlink to $feature_config will be installed with the name $install_root
	-- * If $feature_config/$dotfile specifies a directory
	-- ** Its contents will be (globbed and) installed to the install target (still a directory)
	-- ** > The reason for this design is to eliminate a race condition/config order conflict
	-- ** > Consider `mv foo/ baz/; mv bar/ baz/`;
	-- ** > This results in baz/foo-a.txt, baz/foo-b.txt, baz/bar/bar-a.txt, ...
	-- ** > This also allows us to specify a directory for overrides, improving maintainability

	-- * 'ipairs $values' will install to: $install_root/$value (link target: $feature_config/$value)
	-- ** I.E. for profile below: ~/.config/zsh/profile --> $feature_config/profile
	files = { "profile", "config", "logout", --[[ ... ]] },

	-- * $key:$value pairs mapped as: $value/$key (link) targets [$feature_config/]$key
	-- ** > Essentially for any key, the value is necessarily a directory
	-- files = {
		-- Each of these (links) would install to: $install_root/$key (profile, config, logout)
		-- ["profile"] = "$install_root",
		-- ["config"] = ".", 
		-- ["logout"] = true,
		--
		-- ["explicit_path"] = "~/.config/crazy_style",  -- ~/.config/crazy_style/explicit_path
		-- ["folder_config"] = "~/.config/",              -- ~/.config/entry_1, ~/.config/entry_2, ...
		-- ["bad_target"] = "", -- (Throws error)
		--
		-- One can specify a rename with the following value format
		-- ["rename_me"] = { "$xdg_config", "new_name" }, -- ~/.config/new_name
		-- ["folder_rename"] = { "$xdg_config", "the_folder" }, -- ~/.config/the_folder/entry_X*
		-- ["bad_rename"] = { "$xdg_config", "" }, -- (Throws error)
		-- ... },

	-- TODO: Considering hard-linking since we're globbing directories, else consider globbing only one layer deep
	-- ^^thinking NO on the hard-links: if git does the "delete most a file, original file is a new file" thing with its diff, the entire config will break.

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
		["zdotdir"] = { "/etc/profile.d/zdotdir.sh",
			syntax = "shell",
			create = true, -- Do not error if original file is not found
			access = "0644", -- file / user: read/write / group: read / other: read
			-- TODO: Do I need owner/group?
			-- write = "redirect", -- TODO: Thinking maybe options for copy, pipe, etc.
		}
	},

	-- System-specific overrides
	system = {
		-- If system is not listed here, no override is defined
		-- (Same map rules as dotfiles above)
		work = {
			-- files = {}, -- Replaces spec.files if defined (does not merge)
			-- edits = {} -- Merges with spec.edits (overwrites conflicting entires)
			overrides = { -- Merges with spec.files (overwrites conflicting entries)
				["work"] = { "~/.local/zsh", "overrides" },
			}
			-- vars = {} -- TODO: Rough idea, offer a good usecase for varpaths
			-- where files can be installed in different locations on different
			-- systems without other system overrides.
		},
	},
}

return spec
