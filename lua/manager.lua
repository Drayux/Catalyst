-- NOTE: Not the best place for this, but with regard to implementing copy
-- Uninstall should assume links or sys edits always. The presence of a link
-- makes cleanup easy. The only use case for copy is a system where I want
-- to edit the config crazy style anyway.

local staging = require("lua.staging") -- Maintains install-related data structures

local FeatureSpec = require("lua.spec").Feature
local SystemSpec = require("lua.spec").System

-- TODO: Consider changing __features to be an ipairs table, rather than a pairs
-- table (in doing so, also create the name assignment in the feature spec, the
-- same as we do with system spec)
-- This will allow me to sort the table alphabetically, making the selection
-- output more user-friendly
local __features
local __state = {
	SYSTEM = nil,
	ERROR = nil,
	STAGE = 0,
}

local function is_masked(feat_name)
	local feat_data = __features[feat_name]
	assert(type(feat_data) == "table", "nil feature")

	return not (feat_data.files and (#feat_data.files > 0))
end

-- Helper function to abstract little nuances
-- Selection is the boolean value to set (else nil will default to TRUE)
local function select_feature(feat_name, select_val)
	local feat_data = __features[feat_name]
	assert(type(feat_data) == "table", "nil feature")

	if not feat_data.files then
		print("Warning: select uninitialzed feature " .. feat_name)
		return
	elseif is_masked(feat_name) then
		if select_val == true then
			print("Nothing to install for " .. feat_name)
		end
		feat_data.selected = false
		return
	end

	feat_data.selected = (select_val == nil) or (select_val == true)
end

-- Verifies and sets the target system; handles keywords if used (AUTO, NONE)
local function set_target_system(target_system)
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
	local available_systems = require("lua.dirload")("spec/system", { on_load = SystemSpec.SpecLoad })

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
					__state.SYSTEM = spec
				end
			end
		end

		if __state.SYSTEM then
			print("Detected " .. __state.SYSTEM:upper() .. " as the target system")
		else
			print("Target system could not be determined")
			-- TODO: Consider prompting the user if they want to quit
			-- TODO: Consider if this should set __state.ERROR
		end
		print() -- Silly formatting

	elseif target_system ~= "NONE" then
		-- TODO: Currently assuming all spec names are lowercase (but probably shouldn't)
		local spec = available_systems[target_system:lower()]
		if spec then
			__state.SYSTEM = spec
		else
			print(string.format("No such system with name `%s`", target_system))
			-- TODO: Consider if this should set __state.ERROR
		end
	end
end

--

--- MODULE API ---
local Module = {}
Module.__index = Module
Module.__newindex = function()
	error("[manager.lua] Bad access; module is read-only")
end

-- Returns an iterator (i.e. `for k, v in <Module>:GetSelected() do ... end`)
-- TODO: Actually test this with multiple defined features
function Module.GetSelected()
	local name
	return function()
		repeat name, data = next(__features, name)
			if not name then return end
		until data.selected and not is_masked(name)
		return name, data
	end, nil, nil
end

function Module.GetError()
	if type(__state.ERROR) == "string" then
		return true, __state.ERROR
	end
	return false, nil
end

-- Pretty formats the selected feature list for CLI output
-- NOTE: Originally OutputSelectionList (delete this note once refactor complete)
function Module.PrintSelected()
	local _esc = string.char(27, 91)
	local enabled_text = _esc .. "32mINSTALL" .. _esc .. "0m"
	local disabled_text = _esc .. "31mSKIP" .. _esc .. "0m"
	local masked_text = _esc .. "33mMASKED" .. _esc .. "0m"

	print("Selected features:")
	for feat_name, feat_data in pairs(__features) do
		if is_masked(feat_name) then
			-- Special case inspired by portage; output whenever a feature has
			-- an empty file list (so selecting it will still do nothing)
			print(" │    >", feat_name, masked_text)
		elseif feat_data.selected then
			print(" │    >", feat_name, enabled_text)
		else
			print(" │    >", feat_name, disabled_text)
		end
	end
end

-- TODO: Some sort of system for "show feature"
-- Likely would need modification to InteractiveSelect for an extra control char
-- TLDR it would output the files that would be installed for the indicated features
-- Thinking something akin to the following:
--   └ ? zsh hyprland
-- Then we run stage two on just those features and print the staging tree.
-- Alternatively:
--   └ ? *   /   └ ?
-- Might run a full stage two and show everything (include unselected features here?)

-- Parse an input string and apply changes to the selected features list
function Module.ModifySelected(_, input_str)
	if (not input_str) or (#input_str == 0) then
		return true -- User is done making modifications
	end

	local first_arg = true

	-- Parse the input string
	for minus, target_feature in input_str:gmatch("(%-?)([%w]+)") do
		if target_feature == "ALL" then
			if first_arg then
				for feat_name, _ in pairs(__features) do
					select_feature(feat_name)
				end
			else
				print("ALL keyword not in first position; skipping")
			end

		-- SELECT means "opt-in selection" aka deselect everything
		-- (May not be intuitive, implemented for command line parsing convenience)
		elseif target_feature == "SELECT" then
			if first_arg then
				for feat_name, _ in pairs(__features) do
					select_feature(feat_name, false)
				end
			else
				print("SELECT keyword not in first position; skipping")
			end

		-- SYSTEM means select all features listed in the system spec
		-- TODO: Right now, this is a blacklist system, should I support a
		-- whitelist system instead? both??
		elseif target_feature == "SYSTEM" then
			if first_arg then
				-- This is currently waiting on changing __state.SYSTEM to hold
				-- the system spec data, rather than the spec name
				print("TODO: system-spec feature selection")
			else
				print("SYSTEM keyword not in first position; skipping")
			end

		else
			if __features[target_feature] == nil then
				print("Unrecognized feature " .. target_feature)
			else
				local feat_enabled = (#minus == 0)
				select_feature(target_feature, feat_enabled)
			end
		end

		first_arg = false
	end
end

function Module.InteractiveSelect(self)
	local user_response = ""
	local first_time = true
	repeat
		-- Prompt the user for input
		self:PrintSelected()
		if first_time then -- Show extra helper prompt
			first_time = false
			print(" │ Select or deselect via space-seperated list, press ENTER to accept")
			print(" │ (ex. SYSTEM -zsh hyprland)")
		end
		io.write(" └ ")
		user_response = io.read("*l")
		print() -- Useless formatting
	until self:ModifySelected(user_response)
end

-- feature_data is the value component of __features (table of selected, spec_data, and file_data)
-- function Module.ProcessFeature(_, feature_data)
	-- assert(type(feature_data) == "table", "[manager.lua] Bad param for ProcessFeature")
-- end

--

-- Performs the first stage of spec processing
-- > Extract files for each feature and merge system-specific overrides
-- target_system may be nil
-- TODO/NOTE: Call this *before* ModifySelected or the absence of the feat_data.files list
-- will trigger a bunch of "nothing to do warnings."
-- TODO: Personal lua style question: should I call the first parameter self? proxy? instance?
function Module.ProcessSystem(self, target_system)
	local previous_system = __state.SYSTEM
	if target_system then
		set_target_system(target_system)
	end

	if (__state.STAGE > 0) and (__state.SYSTEM == previous_system) then
		if not target_system then
			-- Developer error
			print("Warning: Extra call to manager:ProcessSystem; skipping")
		end
		return
	end

	-- for feat_name, feat_data in self:GetSelected() do
	for feat_name, feat_data in pairs(__features) do
		feat_data.files = feat_data.spec:LoadFiles(__state.SYSTEM)

		-- (PREV) Deselect feature if Load returns an empty list; no longer needed?
		-- select_feature(feat_name, feat_data.selected)
	end

	__state.STAGE = 1
end

-- Performs the second stage of spec processing
-- > Load all features into the staging filesystem (next stage verifies)
function Module.StageFeatures(self)
	if __state.STAGE < 1 then
		self:ProcessSystem() -- target_system is nil
	end

	-- TODO: >>> the rest <<<

	__state.STAGE = 2
end

return setmetatable({
	-- Not a metamethod! I've chosen this naming convention to indicate its unusual
	-- usage; Notably that __init should only be called once "automagically"
	-- This is necessary so that the call to dirload may be deferred until the
	-- script environment is verified
	__init = function(self)
		assert(type(self) == "table", "[manager.lua] Bad call to init (did you use `:` ?)")
		assert(__features == nil, "[manager.lua] Invalid reinit of module")

		self.__init = nil
		setmetatable(self, Module)

		-- >>> Begin initialization of the module state  <<<

		__features = {}
		for filename, spec_data in pairs(require("lua.dirload")("spec/feature")) do
			assert(not __features[filename], string.format("[manager.lua] Duplicate spec entry `%s`", filename))
			__features[filename] = {
				selected = false,
				spec = FeatureSpec(spec_data) -- *TODO: maybe use dirload's on_load option instead
				-- files = {} -- Map of target_path <Path> : source_path <Path>; init as nil
				-- ^^NOTE: Instances of Path are unique, thus collisions are checked later
			}
		end
		if #__features == 0 then
			__state.ERROR = "No features available (is <catalyst>/spec/feature empty?)"
		end

		setmetatable(__features, {
			__newindex = function(_, feat_name)
				error(string.format("[manager.lua] No spec available for feature `%s`", feat_name))
			end
		})
	end
}, {
	__index = function(self, key)
		-- Initialize the module when first called
		-- NOTE: Not 100% on this implementation, this could be done without a call
		self:__init() 
		return self[key] -- Honor the original request
	end
})
