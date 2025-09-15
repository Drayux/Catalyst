local filesystem = require("lua.filesystem")

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
function spec.GetInstallTarget(self)
	local target = self.opts.install_target
	if not target then
		target = "~/.config/" .. self.feature
		print(string.format("No install target specified for %s; assuming `%s`", self.feature, target))

		-- Save the new value so we only warn once per feature
		self.opts.install_target = target
	end
	return target
end

function spec.GetFeatureRoot(self)
	local feature = self.opts.feature_root
	if not feature then
		feature = string.format("%s/%s", filesystem.path_GetDotfileRoot(), self.feature)
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

-- Not my best design, so a note to my future self:
-- I wanted to specify the values that would be returned via the object API,
-- thus requiring the following complicated procedure to apply closures and
-- store the generated table with the instantiated spec object.
--
-- The mistake I made in the initial design was not knowing what all I'd use
-- variable paths for. Ultimately, almost every use case intends to resolve
-- to an absolute path (aka any path will always start with / . or $)
-- With this assumption, this design could become far simpler. While this is
-- fully functional as defined, the definition itself is relatively unintuitive.
local _varpath_fn_lut = {
	install_target = spec.GetInstallTarget,
	feature_root = spec.GetFeatureRoot,
	feature_config = spec.GetFeatureConfig,
	feature_edits = spec.GetFeatureEdits,
	feature_overrides = spec.GetFeatureOverrides,
}
function spec.GetVarpathTable(self)
	local lut = self.varpath_lut
	if not lut then
		-- TLDR: we convert $variable values to actual path entries via a lookup table.
		-- These table values will change depending on the current spec, thus we pass a
		-- closure to the filesystem API to get the appropriate value.
		self.varpath_lut = setmetatable({
			user_home = filesystem.path_GetHomeDir,
			catalyst_root = filesystem.path_GetScriptDir,
		}, {
			__index = function(tbl, key)
				local getter = _varpath_fn_lut[key]
				if getter then
					local _f = function()
						return getter(self)
					end
					tbl[key] = _f -- Only generate a new closure once per value
					return _f
				else
					error(string.format("No varpath set for $%s (feature: %s)", key, self.feature))
				end
			end,
		})
	end

	return lut
end

-- Processes the config files specified by the spec
-- (aka. each file is placed into the staging filetree)
local function process_Files(spec)
	local varpath_lut = spec:GetVarpathTable()
end

-- Processes spec config (call only once)
function spec.Process(self)
	assert(not self._processed, string.format("Feature %s has already been processed", self.feature))
	self._processed = true

	process_Files(self)
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


--- MODULE API (initialization) ---
-- Spec list is a basic map of setmetatable(spec_entry, spec_api)
features.spec_list = (function(t, f, ...)
	local ret = {}
	for k, v in pairs(t) do
		ret[k] = f(v, ...)
	end
	return ret
end)(require("lua.dirload")("spec/feature"), function(_spec, _api)
	assert(type(_spec.feature) == "string") -- Feature name must be defined
	return setmetatable(_spec, _api)
end, spec)

-- TODO: Consider tweaking dirload such that the error message can be saved
-- here and then output can be deferred later (doesn't really matter, just a
-- possible nice-to-have)
features:GenerateSelectionList()
if features.feat_count == 0 then
	features.errormsg = "No features available (is /spec/feature empty?)"
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
