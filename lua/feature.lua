local filesystem = require("lua.filesystem")

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


--- FEATURE SPEC API ---
local spec_api = {}

-- Varpath getters; Probably a clever way to do this general form but there's
-- not too many of them to really worry about that yet
function spec_api.GetInstallTarget(self)
	local target = self.opts.install_target
	if not target then
		target = "~/.config/" .. self.feature
		print(string.format("No install target specified for %s; assuming `%s`", self.feature, target))

		-- Save the new value so we only warn once per feature
		self.opts.install_target = target
	end
	return target
end

function spec_api.GetFeatureRoot(self)
	local feature = self.opts.feature_root
	if not feature then
		feature = string.format("%s/dofiles/%s", filesystem.path_GetScriptDir(), self.feature)
		self.opts.feature = feature
	end
	return feature
end

function spec_api.GetFeatureConfig(self)
	local config = self.opts.feature_config
	if not config then
		config = self:GetFeatureRoot() .. "/config"
		self.opts.feature_config = config
	end
	return config
end

function spec_api.GetFeatureEdits(self)
	local edits = self.opts.feature_edits
	if not edits then
		edits = self:GetFeatureRoot() .. "/edits"
		self.opts.feature_edits = edits
	end
	return edits
end

function spec_api.GetFeatureOverrides(self)
	local overrides = self.opts.feature_overrides
	if not overrides then
		overrides = self:GetFeatureRoot() .. "/overrides"
		self.opts.feature_overrides = overrides
	end
	return overrides
end

-- Varpath table is perhaps more complicated than necessary
-- TLDR: we convert $variable values to actual path entries via a lookup table.
-- These table values will change depending on the current spec, thus we pass a
-- closure to the filesystem API to get the appropriate value.
-- I wanted to specify the values that would be returned via the object API,
-- thus requiring the following complicated procedure to apply closures and
-- store the generated table with the instantiated spec object.
local _varpath_fn_lut = {
	install_target = spec_api.GetInstallTarget,
	feature_root = spec_api.GetFeatureRoot,
	feature_config = spec_api.GetFeatureConfig,
	feature_edits = spec_api.GetFeatureEdits,
	feature_overrides = spec_api.GetFeatureOverrides,
}
function spec_api.GetVarpathTable(self)
	local lut = self.varpath_lut
	if not lut then
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
					-- NOTE: An oversight of the current design in filesystem.lua is that (for
					-- now) feature_config MUST be defined in order for relative paths to work
					error(string.format("No varpath set for %s (feature: %s)", key, self.feature))
				end
			end,
		})
	end

	return lut
end

-- function spec_api.LinkFile(self, file, target)
-- end


--- MODULE INITIALIZATION

-- Spec list is a basic map of setmetatable(spec_entry, spec_api)
features.spec_list = (function(t, f, ...)
	local ret = {}
	for k, v in pairs(t) do
		ret[k] = f(v, ...)
	end
	return ret
end)(require("lua.dirload")("spec/feature"), function(spec, api)
	assert(type(spec.feature) == "string") -- Feature name must be defined
	return setmetatable(spec, api)
end, spec_api)

-- TODO: Consider tweaking dirload such that the error message can be saved
-- here and then output can be deferred later (doesn't really matter, just a
-- possible nice-to-have)
features:GenerateSelectionList()
if features.feat_count == 0 then
	features.errormsg = "No features available (is /spec/feature empty?)"
end


--- MODULE API

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
