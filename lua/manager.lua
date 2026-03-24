local __state = {
	SYSTEM = nil
}

local Module = {}
Module.__index = Module
Module.__newindex = function()
	error("[manager.lua] Bad access; module is read-only")
end

function Module.SetSystem(_, target_system)
	if __state.SYSTEM then
		if target_system == nil then
			-- Leave as-is (assume AUTO already handled)
			return
		elseif type(target_system) == "string" then
			-- Otherwise probably developer error, not fatal though
			print(string.format("[manager.lua] Target system already set, but changing to `%s`", target_system))
		else
			-- Wrong type is fatal, however
			error("[manager.lua] Bad call to SetSystem; Must be string or nil")
		end
	end

	local available_systems = require("lua.dirload")("spec/system")

	if target_system == "AUTO" then
		-- Figure out what system we're installing to
		-- NOTE: Relatively lazy heuristic, score better than a 4 for a system to
		-- be a valid candidate
		local best_score = 4
		for system, spec in pairs(available_systems) do
			if type(spec.score) == "function" then
				local score = spec.score()
				if score > best_score then
					best_score = score
					__state.SYSTEM = system
				end
			end
		end

		if __state.SYSTEM then
			print("Detected " .. __state.SYSTEM:upper() .. " as the target system")
		else
			print("Target system could not be determined")
			-- TODO: Consider prompting the user if they want to quit
		end
		print() -- Silly formatting
		return
	elseif target_system ~= "NONE" then
		-- TODO: Verify selection
		__state.SYSTEM = target_system
	end

	__state.SYSTEM = nil -- Fallback to none
end

-- TODO: Move non-spec stuff from spec.lua (originally feature.lua) into here
-- I might want to rename this again, but I think it's reasonable that this
-- handles all of the logic for user interactive stuff
-- TODO: Should it also handle the actual spec generator? I'm tempted to
-- say that this is better suited for the main file, else it's mostly empty
-- with one inconspicuous "go" type of function

--- TODO: Moving this over from options! Options should just be responsible for
-- getting this from the command line, features should actually handle what
-- system (and subsequently features) that that maps to

-- Some options may require additional processing (i.e. system "AUTO")
local function process_System(initial_target)


	if target_system then
		-- return target_system, systems[target_system]
		local spec = systems[target_system]
		spec.name = target_system
		return spec
	else
		-- Don't like this; Needed to return a non-string non-nil value so that
		-- the processed option does not fallback to "AUTO"
		return true
	end
end

---

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
		error("Bad use of features_GenerateSelectionList; Selection list already generated")
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
	install_root = Class.GetInstallRoot,
	feature_root = Class.GetFeatureRoot,
	feature_config = Class.GetFeatureConfig,
	feature_edits = Class.GetFeatureEdits,
	feature_overrides = Class.GetFeatureOverrides,
}
local function spec_Init(_spec, api)
	assert(type(_spec.feature) == "string") -- Feature name must be defined
	-- ^^TODO: Instead of asserting, consider instead just setting this value
	-- on init, the same way as we do for for system spec files

	-- Add the spec vars to the global table (managed by env.lua)
	-- TODO: We might want to ONLY do this if the feature is selected!!
	-- ^^If so, move the following to the top of spec_obj:Process()
	for var, value in pairs(_spec.vars or {}) do
		environment[var] = value
	end

	-- Create a path lookup table scoped to the target feature
	_spec._varpath_tbl = setmetatable({}, {
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
			-- (Also includes globals, to which the spec vars are added)
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

---

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
end)(require("lua.dirload")("spec/feature"), spec_Init, Class)

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
	-- Unfortunate clash of feature/options APIs, we want to set this only
	-- after the system_spec is ready to be retrieved from options
	-- TODO: This should be fixable by moving the initialization call to the
	-- option.process function (see system_spec = options[_system] in main file)
	system = function(target_system)
		if features.system then
			-- Developer error
			error("Bad use of features_SetSystem; system spec already set")
		end
		features.system = target_system
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
