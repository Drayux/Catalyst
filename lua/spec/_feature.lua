--- feature.lua - ???

-- USAGE: *** Parses script arguments from a pre-defined structure (see __options)
-- STATE: *** Singleton instance; values are associated with this module
-- RTYPE: *** Module (API table -> instance)
-- NOTES --
--	  >	There are lots of ways to handle varpath closures as the feature list
--		loads a table of spec tables. This could be defined where all
--		functionality is handled by the features object which just passes the
--		spec as the 'self' parameter, the specs have all of the functionality,
--		or a mix of both. Thus, the easiest line in the sand to draw is at
--		"getters" where processing a value that might want to be saved to the 
--		spec is part of the spec API, and everything else should be handled by
--		the feature list API. (TODO: This note might be obsolete.)

local env_status, environment = pcall(require, "lua.env")
local path = require("lua.path")
local staging = require("lua.staging")

--- CLASS API ---
local Class = { type = "Spec:Feature" }
Class.__index = Class
Class.__newindex = function()
	error("Attempt to add new member to `Spec:Feature` class")
end

-- Subroutine that processes the config files specified by the spec
-- (aka. each file is placed into the staging filetree)
local function stage_files(spec, files)
	if not files then
		return
	elseif type(files) == "table" then
		-- Fixup ipairs values to simplify later logic
		setmetatable(files, {
			__pairs = function(self)
				local key, value
				return function(tbl)
					key, value = next(tbl, key)
					if type(key) == "number" then
						return value, "$install_root"
					end
					return key, value
				end, self, nil
			end
		})
	else
		-- Developer error
		error("Bad call to feature::stage_files, files is not a table")
	end

	local feature_config = path(spec:GetFeatureConfig()):Absolute()

	-- For each entry, search for it below
	-- > if file (string), then install
	-- > if directory (table), then install children
	for config_filename, directory in pairs(files) do
		local search_result = feature_config:Search(config_filename)
		local dir_install = false
		if type(search_result) == "string" then
			search_result = { config_filename }
			dir_install = true
		end

		for _, path_str in ipairs(search_result) do
			local install_path
			local config_path = feature_config:Append(path_str)
			local target_filename = path_str:match("^.-/(.+)$") or path_str

			if type(directory) == "table" then
				-- directory[1] is the target install directory
				assert(directory[1] and (#directory[1] > 0),
					"Rename spec must specify an install directory (first position)")
				-- directory[2] is the new name of the dotfile (or nil for the same)
				local _rename
				if directory[2] and (#directory[2] > 0) then
					_rename = directory[2]
				end

				install_path = path(directory[1], spec._varpath_tbl)

				-- file rename:
				-- install path is directory[1] + directory[2]
				-- * unless empty, then directory[1] + target_filename
				-- dir rename:
				-- install path is directory[1] + directory[2] + target_filename
				-- * unless empty, then directory[1] + target_filename
				if dir_install then
					-- Folder rename is a pretty different structure, perhaps this
					-- can be made cleaner sometime (TODO)
					if _rename then
						install_path = install_path:Append(_rename)
					end
					install_path = install_path:Append(target_filename)
				else
					install_path = install_path:Append(_rename or target_filename)
				end

				if directory[2] and (#directory[2] > 0) then
					install_path = path(directory[1], spec._varpath_tbl):Append(directory[2])
				end

			else
				-- Flatten directory contents
				if directory == true then
					directory = "$install_root"
				elseif directory == "" then
					-- TODO: Consider allowing this--doesn't hurt to have, just
					-- not much (intuitive) use for it
					error("Bad target directory (empty string)")
				end
				install_path = path(directory, spec._varpath_tbl):Append(target_filename)
			end

			-- TODO: Support for hard links (just need to read config
			-- and set type param to staging.HARD if requested)

			staging:AddFile(install_path, config_path, staging.PATH)
		end
	end
end

-- Subroutine to that processes the extra symlinks specified by the spec
-- (aka. each file is placed into the staging filetree)
local function stage_links(spec, links)
	if not links then
		return
	end
	assert(type(links) == "table", "Bad call to feature::stage_links, links is not a table")

	for link_filename, link_target in pairs(links) do
		assert(type(link_filename) == "string")
		assert(type(link_target) == "string")

		-- This association is much simpler than files, links will be generated
		-- almost exactly as they appear in the spec

		install_path = path("$install_root", spec._varpath_tbl):Append(link_filename)
		target_path = path(link_target, spec._varpath_tbl)

		staging:AddFile(install_path, target_path, staging.LINK)
	end
end

-- Subroutine to stage sysconfig edits for processing
-- Behind the scenes, we're just flattening and sticking it in an array
-- Since edits cannot conflict (multiple features touching the same file is
-- OKAY) there is no error handling to be done yet.
local function stage_edits(spec, edits)

	-- DEV NOTE: Multiple edits to the same file should NOT create multiple config
	-- sections; it should be applied sequentially (in what order though?)

	for edit_name, edit_spec in pairs(edits) do
		-- Edit staging indexes by filepath instead of internal name
		-- Spec files should use variables for shared system-level files to
		-- mitigate the chance of a system override generating extra system
		-- files by mistake.
		local edit_file = path(edit_spec.file, spec._varpath_tbl)
		edit_spec.file = edit_file:Absolute()

		-- TODO: We need something more creative than just the filename....probably?
		-- If not, the same filename in multiple locations could raise a warning, which
		-- I anticipate is likely to be helpful (most sysconfig filenames are better than simply 'config')
		local edit_uid = edit_file:Filename()
		staging:AddEdit(edit_uid, edit_spec)

		-- NOTE: We need a staging:AddFile(edit_file, "<repo/install/edits/" .. name, staging.COPY)
		-- but we can't add it here or multiple callouts to the same file will conflict.
		-- It must be added during the generation, perhaps after each file successful builds?
	end
end

-- Process spec config (call only once)
function Class.Process(self, system_name)
	assert(not self._processed, string.format("Feature %s has already been processed", self.feature))
	self._processed = true

	-- NOTE: Spec-defined variables are added to globals during init, BUT if it
	-- becomes prudent to only add the vars of *selected* spec files, then that
	-- must move here-ish (specifically, before staging any files)

	local files = self.files
	local links = self.links
	local edits = self.edits

	local system_ovr = system_name and self.system
		and self.system[system_name]
	if system_ovr then
		-- Override spec files system_ovr.files if defined
		files = system_ovr.files or files

		-- "Merge" spec files if system_ovr.overrides if defined
		if system_ovr.overrides then
			files = files or {}
			for k, v in pairs(system_ovr.overrides) do
				files[k] = v -- Overrides table values stomp original table values
			end
		end

		-- "Merge" edit files if system_ovr.edits if defined
		if system_ovr.edits then
			edits = edits or {}
			for ovr_name, ovr_spec in pairs(system_ovr.edits) do
				local base_edit = edits[ovr_name]
				if base_edit then
					-- Named edit already exists in base, merge its contents
					for ovr_k, ovr_v in pairs(ovr_spec) do
						if (ovr_k == "sequence")
							and (type(ovr_v) == "string")
						then
							-- Edge case to append single edit to sequence
							table.insert(base_edit.sequence, ovr_v)
						else
							-- Normal case, replace if defined by override
							base_edit[ovr_k] = ovr_v
						end
					end
				else
					-- Otherwise copy the entire entry from the overrides
					edits[ovr_name] = over_spec
				end
			end
		end
	end

	if not (files or links) then
		-- Simple install; symlink to root
		local install_path = path("$install_root", self.vars)
		local link_target = path("$feature_config", self.vars)
		staging:AddFile(install_path, link_target, staging.PATH)
	else
		stage_files(self, files)
		stage_links(self, links)
	end

	if edits then
		stage_edits(self, edits)
	end

	staging:Print()
end

-- Path string getters; generally intended for varpath resolution

function Class.GetInstallRoot(self)
	local target = self.opts.install_root
	if not target then
		target = "~/.config/" .. self.feature
		print(string.format("No install location specified for %s; assuming `%s`", self.feature, target))

		-- Save the new value so we only warn once per feature
		self.opts.install_root = target
	end
	return target
end

function Class.GetFeatureRoot(self)
	local root = self.opts.feature_root
	if not root then
		root = string.format("%s/%s", environment.dotfile_root, self.feature)
		self.opts.feature = root
	end
	return root
end

function Class.GetFeatureConfig(self)
	local config = self.opts.feature_config
	if not config then
		config = self:GetFeatureRoot() .. "/config"
		self.opts.feature_config = config
	end
	return config
end

function Class.GetFeatureEdits(self)
	local edits = self.opts.feature_edits
	if not edits then
		edits = self:GetFeatureRoot() .. "/edits"
		self.opts.feature_edits = edits
	end
	return edits
end

function Class.GetFeatureOverrides(self)
	local overrides = self.opts.feature_overrides
	if not overrides then
		overrides = self:GetFeatureRoot() .. "/overrides"
		self.opts.feature_overrides = overrides
	end
	return overrides
end


-- FOR NEXT TIME (TODO OLD - Just some thoughts at this point)
-- I shouldn't need this if I actually work on this when I should be but....
-- Mystery is when to stage edits versus actually process edits
-- Thinking to split up "process" and a new routine "stage"
-- Reorganize all current processing into staging
-- Finally the top-level spec handling function will run stage (aka prepare files/paths)
-- ...followed by process (aka generate intermediate files) *maybe* followed by install
-- (aka generate the main ./install and ./restore scripts -- might also be merged with process)
-- Finally, a note for extra later, the restore script should probably check for a time and maybe
-- even a signed hash as a small extra security measure. (The fear is someone editing the system
-- file backups and then the user reverting to those "now bad" files.)
-- 
-- ^^That should be plenty: An actor with access to the restore cache would
-- also have access to the ssh keys, so no keypair RSA hash exists (i.e. the restore cache would
-- be self-signed.) The timestamp and hash should be checked for accidental modifications, but
-- we must assume that any user of this script has root access. Moreover, we assume that this
-- script is stored somewhere it could be modified by the bad actor as well.
--
-- The new pressing question: How to handle multiple features editing the same system conf?
-- This means that edits should* not cause conflicts! So....do we stage them at all?
-- Further thought, most features will probably depend only on system edits unique to them,
-- but there are a few that might have cross over (like adding an environment variable to zprofile)
-- How should we handle cases when different systems have /etc/zprofile in different locations?
-- Sure, each spec could use a system override, but this feels clunky. (TODO!!!)

-- TODO - INCOMING REWORK

-- TLDR staging is more complicated than I originally guessed
-- The final output will be a list of path tuples, (SRC, TARGET)
--
-- Originally, staging went directly to this format. However, it was missing a
-- way to track which paths exist and what modules will be installed for
-- tracking what is currently installed.
--
-- In short, each spec should have utilites for determining what files it will
-- try to install. That list of (SRC, TARGET) pairs will be generated at the
-- request of the feature manager.
--
-- Once spec (for that system only??) are processed in this way, the manager
-- has two options, and I'm not sure which has priority (TODO)
--  > Place features into the staging tree
--  > Verify features with the existing filesystem
--
-- Do I ever need to check what is installed *before* selection?
-- Once selected, for installation for each feature:
--  > Check the cache
--  > If nothing installed, EASY PEASY
--  > If installed but NEW covers OLD, also easy
--  > ???
