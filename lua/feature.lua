local env_status, environment = pcall(require, "lua.env")
local path = require("lua.path")
local staging = require("lua.staging")

--- FEATURE SPEC API ---
-- NOTE: There are lots of ways to handle these function closures as the
-- feature list loads a table of spec tables. This could be defined where all
-- functionality is handled by the features object which just passes the spec
-- as the 'self' parameter, the specs have all of the functionality, or a mix
-- of both. Thus, the easiest line in the sand to draw is at "getters" where
-- processing a value that might want to be saved to the spec is part of the
-- spec API, and everything else should be handled by the feature list API.
local spec = {}

-- Varpath getters; Probably a clever way to do this general form but there's
-- not too many of them to really worry about that yet
function spec.GetInstallRoot(self)
	local target = self.opts.install_root
	if not target then
		target = "~/.config/" .. self.feature
		print(string.format("No install location specified for %s; assuming `%s`", self.feature, target))

		-- Save the new value so we only warn once per feature
		self.opts.install_root = target
	end
	return target
end

function spec.GetFeatureRoot(self)
	local feature = self.opts.feature_root
	if not feature then
		feature = string.format("%s/%s", environment.dotfile_root, self.feature)
		self.opts.feature = feature
	end
	return feature
end

function spec.GetFeatureConfig(self)
	local config = self.opts.feature_config
	if not config then
		config = self:GetFeatureRoot() .. "/config"
		self.opts.feature_config = config
	end
	return config
end

function spec.GetFeatureEdits(self)
	local edits = self.opts.feature_edits
	if not edits then
		edits = self:GetFeatureRoot() .. "/edits"
		self.opts.feature_edits = edits
	end
	return edits
end

function spec.GetFeatureOverrides(self)
	local overrides = self.opts.feature_overrides
	if not overrides then
		overrides = self:GetFeatureRoot() .. "/overrides"
		self.opts.feature_overrides = overrides
	end
	return overrides
end

-- Processes the config files specified by the spec
-- (aka. each file is placed into the staging filetree)
local function spec_ProcessFiles(spec, files)
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
		error("Bad call to spec_ProcessTables, files is not a table")
	end

	local feature_config = path(spec:GetFeatureConfig()):Absolute()

	-- For each entry, search for it below
	-- > if file (string), then install
	-- > if directory (table), then install children
	for name, directory in pairs(files) do
		local search_result = feature_config:Search(name)
		if type(search_result) == "string" then
			search_result = { name }
		end

		for _, dotfile in ipairs(search_result) do
			local install_path
			local config_path = feature_config:Append(dotfile)
			local filename = dotfile:match("^.-/(.+)$") or dotfile

			if type(directory) == "table" then
				assert(#directory == 2,
					"Rename spec must specify exactly 2 non-empty entries")
				-- directory[1] is the target install directory
				assert(directory[1] and (#directory[1] > 0),
					"Rename spec must specify an install directory (first position)")
				-- directory[2] is the new name of the dotfile
				assert(directory[2] and (#directory[2] > 0),
					"Rename spec must specify an installed filename (second position)")

				install_path = path(directory[1], spec.vars):Append(directory[2])

				-- Folder rename is a pretty different structure, perhaps this
				-- can be made cleaner sometime (TODO)
				if #search_result > 1 then
					install_path = install_path:Append(filename)
				end
			else
				-- Flatten directory contents
				if directory == true then
					directory = "$install_root"
				end
				install_path = path(directory, spec.vars):Append(filename)
			end

			staging:AddFile(install_path, config_path)
		end
	end
end

-- Processes spec config (call only once)
function spec.Process(self, system_name)
	assert(not self._processed, string.format("Feature %s has already been processed", self.feature))
	self._processed = true

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
			for k, v in pairs(system_ovr.edits) do
				files[k] = v -- Overrides table values stomp original table values
			end
		end
	end

	if not (files or links) then
		-- Simple install; symlink to root
		local install_path = path("$install_root", self.vars)
		local link_target = path("$feature_config", self.vars)
		staging:AddFile(install_path, link_target)
	else
		spec_ProcessFiles(self, files)
		-- spec_ProcessLinks(self, links)
	end

	staging:Print()
end

--- FEATURES LIST API ---
local features = {
	selected = nil,
	feat_count = 0,
	error_msg = nil,
}

-- Make a simple table of [feature_name] = true/false
function features.GenerateSelectionList(self)
	if self.selected then
		-- TODO: Didn't give this a lot of thought, just wanted a warning because this
		-- shouldn't happen in the current implementation
		error("Bad use of features_GenerateList; Selection list already generated")
	end

	self.selected = {}

	for feat, _ in pairs(self.spec_list or {}) do
		self.selected[feat] = false
		self.feat_count = self.feat_count + 1
	end

	setmetatable(self.selected, {
		__newindex = function(_, feat)
			error("Bad write to selected features; no spec for " .. feat)
		end
	})
	return self.feat_count
end

-- Parse an input string and apply changes to the selected features list
function features.ModifySelectionList(self, input_str)
	if (not input_str) or (#input_str == 0) then
		return true -- User is done making modifications
	end

	-- Parse the input string
	for minus, feature in input_str:gmatch("(%-?)([%w]+)") do
		-- TODO: Special rules for USER, SYSTEM, etc.
		-- (not sure how exactly I want these to behave just yet)
		if feature == "ALL" then
			for _feature, _ in pairs(self.selected) do
				self.selected[_feature] = true
			end

		-- NOTE: May not be intuitive, this is here mostly for symmetry
		elseif feature == "SELECT" then
			for _feature, _ in pairs(self.selected) do
				self.selected[_feature] = false
			end

		else
			if self.selected[feature] == nil then
				print("Unrecognized feature: " .. feature)
			else
				self.selected[feature] = (#minus == 0)
			end
		end
	end
end

-- Pretty formats the selected feature list for CLI output
function features.OutputSelectionList(self)
	local _esc = string.char(27, 91)
	local enabled_text = _esc .. "32mINSTALL" .. _esc .. "0m"
	local disabled_text = _esc .. "31mSKIP" .. _esc .. "0m"

	print("Selected features:")
	for feat, en in pairs(self.selected) do
		print(" │    >", feat, en and enabled_text or disabled_text)
	end
end

local spec_varpath_def = {
	install_root = spec.GetInstallRoot,
	feature_root = spec.GetFeatureRoot,
	feature_config = spec.GetFeatureConfig,
	feature_edits = spec.GetFeatureEdits,
	feature_overrides = spec.GetFeatureOverrides,
}
local function spec_Init(_spec, api)
	assert(type(_spec.feature) == "string") -- Feature name must be defined
	-- ^^TODO: Instead of asserting, consider instead just setting this value
	-- on init, the same way as we do for for system spec files

	-- NOTE: Currently no use of spec.vars being defined early
	-- The following is mostly a demonstration for possible inspiration later
	_spec.vars = setmetatable(_spec.vars or {}, {
		__index = function(tbl, key)
			-- local opt_val = _spec.opts[key]
			-- if opt_val then
				-- return opt_val
			-- end

			local fn = spec_varpath_def[key]
			if fn then
				local varpath_val = fn(_spec)
				rawset(tbl, key, varpath_val)
				return varpath_val
			end

			-- Fallback to script env vars
			return environment[key]
		end,
		__newindex = function()
			-- No reason we couldn't support this; developer mistake for now though
			error("Spec vars table is read-only")
		end
	})

	-- Attach the API metatable to the new feature spec
	return setmetatable(_spec, { __index = api })
end

--- MODULE API (initialization) ---
-- Spec list is a basic map of setmetatable(spec_entry, spec_api)
features.spec_list = (function(t, f, ...)
	local ret = {}
	for k, v in pairs(t) do
		ret[k] = f(v, ...)
	end
	return ret

-- TODO: Consider tweaking dirload such that the error message can be saved
-- here and then output can be deferred later (doesn't really matter, just a
-- possible nice-to-have)
end)(require("lua.dirload")("spec/feature"), spec_Init, spec)

if not env_status then
	-- TODO: Consider the location of this; Current rationale is that some
	-- script operations work with the wrong environment, but features
	-- certainly cannot be installed without it
	features.errormsg = "Failed to determine script environment"
elseif features:GenerateSelectionList() == 0 then
	features.errormsg = "No features available (is <catalyst>/spec/feature empty?)"
end

local module = setmetatable({
	interactive = function()
		local user_response = ""
		local first_time = true
		repeat
			-- Prompt the user for input
			features:OutputSelectionList(selected)
			if first_time then -- Show extra helper prompt
				first_time = false
				print(" │ Select or deselect via space-seperated list, press ENTER to accept")
				print(" │ (ex. SYSTEM -zsh hyprland)")
			end
			io.write(" └ ")
			user_response = io.read("*l")
			print() -- Useless formatting
		until features:ModifySelectionList(user_response)
	end,
	print = function()
		features:OutputSelectionList()
	end,
	error = function()
		return features.errormsg
	end,
	-- Unfortuante clash of feature/options APIs, we want to set this only
	-- after the system_spec is ready to be retrieved from options
	-- TODO: This should be fixable by moving the initialization call to the
	-- option.process function (see system_spec = options[_system] in main file)
	system = function(system_spec)
		if features.system then
			-- Developer error
			error("Bad use of features_SetSystem; system spec already set")
		end
		features.system = system_spec
	end
}, {
	__newindex = function()
		error("Bad write to features module; module is read-only")
	end,
	-- Will not work in lua < 5.2! (does nothing)
	__pairs = function()
		local k
		return function()
			repeat k, v = next(features.selected, k)
				if not k then return end
			until features.selected[k]
			return k, features.spec_list[k]
		end, nil, nil
	end,
	__call = function(_, input)
		features:ModifySelectionList(input)
	end,
})

return module
