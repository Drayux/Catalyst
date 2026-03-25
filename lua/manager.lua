local staging = require("lua.staging") -- Maintains install-related data structures

local __features
local __state = {
	SYSTEM = nil
}

local Module = {}
Module.__index = Module
Module.__newindex = function()
	error("[manager.lua] Bad access; module is read-only")
end

-- TODO (maybe?) Update the selection list when this is called (right now it's
-- just a rewrite of what used to be in the options parser)
function Module.SetSystem(_, target_system)
	-- Input validation
	if target_system == nil then
		-- Leave as-is (assume AUTO already handled)
		return
	elseif type(target_system) ~= "string" then
		error("[manager.lua] Bad call to SetSystem; Must be string (or nil)")
	end
	if __state.SYSTEM then
		-- Possible developer error if system already set, not fatal though
		print(string.format("Target system already set, but changing to `%s`", target_system))
	end

	__state.SYSTEM = nil -- Fallback to none
	local available_systems = require("lua.dirload")("spec/system")

	if target_system == "AUTO" then
		-- Figure out what system we're installing to
		-- NOTE: Relatively lazy heuristic, score better than a 4 for a system
		-- to be a valid candidate
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

	elseif target_system ~= "NONE" then
		-- TODO: Currently assuming all spec names are lowercase!
		local spec = available_systems[target_system:lower()]
		if spec then
			__state.SYSTEM = target_system
		else
			print(string.format("No such system with name `%s`", target_system))
		end
	end
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

local Instance = setmetatable({
	-- Not a metamethod! I've chosen this naming convention to indicate its unusual
	-- usage. Notably that __init should only be called once "automagically"
	__init = function(self)
		assert(__features == nil, "[manager.lua] Invalid reinit of module")
		self.__init = nil

		setmetatable(self, Module)

		-- >>> Perform the module state initialization steps <<<
		-- Load the feature specs from the filesystem
		-- Spec list is a basic map of setmetatable(spec_entry, spec_api)
		-- TODO: Make this readable
		__features = {}
		for filename, spec in pairs(require("lua.dirload")("spec/feature")) do
			assert(not __features[filename], string.format("[manager.lua] Duplicate spec entry `%s`"), filename)
			__features[filename] = {
				selected = false,
				spec = setmetatable(spec, api), -- TODO: use dirload on_load,
				-- which will then call _feature: Module.new() (see path for reference)
			}
		end

		setmetatable(__features, {
			__newindex = function(_, feat)
				error(string.format("[manager.lua] No spec available for feature `%s`", feat))
			end })
	end
}, {
	__index = function(self, key)
		-- Initialize the module when first called
		-- NOTE: Not 100% on this implementation, this could just go here directly
		Instance:__init() 

		-- Honor the original request
		return Instance[key]
	end
})
return Instance
