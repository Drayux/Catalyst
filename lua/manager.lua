-- NOTE: Not the best place for this, but with regard to implementing copy
-- Uninstall should assume links or sys edits always. The presence of a link
-- makes cleanup easy. The only use case for copy is a system where I want
-- to edit the config crazy style anyway.

local staging = require("lua.staging") -- Maintains install-related data structures

local FeatureSpec = require("lua.spec").Feature
-- local SystemSpec = require("lua.spec").System

local __features
local __state = {
	SYSTEM = nil,
	ERROR = nil,
}

local Module = {}
Module.__index = Module
Module.__newindex = function()
	error("[manager.lua] Bad access; module is read-only")
end

-- Returns an iterator (i.e. `for k, v in <Module>:GetSelected() do ... end`)
-- TODO: Actually test this with multiple defined features
function Module.GetSelected()
	local k
	return function()
		repeat k, v = next(__features, k)
			if not k then return end
		until __features[k].selected
		return k, v
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

	print("Selected features:")
	for feat_name, feat_state in pairs(__features) do
		print(" │    >", feat_name, feat_state.selected and enabled_text or disabled_text)
	end
end

-- Parse an input string and apply changes to the selected features list
function Module.ModifySelected(_, input_str)
	if (not input_str) or (#input_str == 0) then
		return true -- User is done making modifications
	end

	-- Parse the input string
	for minus, target_feature in input_str:gmatch("(%-?)([%w]+)") do
		-- TODO: Special rules for USER, SYSTEM, etc.
		-- (not sure how exactly I want these to behave just yet)
		-- TODO: Skip features unsupported by the set system (also TODO, this
		-- condition needs a definition)
		if target_feature == "ALL" then
			for feat_name, _ in pairs(__features) do
				__features[feat_name].selected = true
			end

		-- SELECT means "opt-in selection" aka deselect everything
		-- (May not be intuitive, implemented for command line parsing convenience)
		elseif target_feature == "SELECT" then
			for feat_name, _ in pairs(__features) do
				__features[feat_name].selected = false
			end

		else
			if __features[target_feature] == nil then
				print("Unrecognized feature: " .. target_feature)
			else
				local feat_enabled = (#minus == 0)
				__features[target_feature].selected = feat_enabled
			end
		end
	end
end

-- NOTE: Previously features.interactive() (delete note once refactor complete)
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

-- TODO (maybe?) Update the selection list when this is called (right now it's
-- just a rewrite of what used to be in the options parser)
-- I *also* don't like that this funciton is only relevant before any processing
-- > i.e. if it's called, then features may need to be processed again to handle
-- > alternative system-specific overrides
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
			-- TODO: Consider if this should set __state.ERROR
		end
		print() -- Silly formatting

	elseif target_system ~= "NONE" then
		-- TODO: Currently assuming all spec names are lowercase (but probably shouldn't)
		local spec = available_systems[target_system:lower()]
		if spec then
			__state.SYSTEM = target_system
		else
			print(string.format("No such system with name `%s`", target_system))
			-- TODO: Consider if this should set __state.ERROR
		end
	end
end

-- feature_data is the value component of __features (table of selected, spec_data, and file_data)
function Module.ProcessFeature(_, feature_data)
	assert(type(feature_data) == "table", "[manager.lua] Bad param for ProcessFeature")
	if feature_data.files then
		print(string.format("Feature %s may have already been processed, skipping", feature_data.spec.feature))
		return
	end

	feature_data.files = feature_data.spec:Process()
	
	-- TODO: >>> the rest <<<
end

--

-- TODO (for upcoming development session!)
-- manager:SetSystem() in its current form should be the call responsible for
-- the first-round processing all of the spec files. First round processing
-- should be to iterate every available feature, and handle the overrides ONLY.
-- Because it is possible to change the system again later, this should be
-- placed into temporary tables, rather than overriding in-place.
-- (From here, I probably want to move SetSystem to a name like VerifySystem,
-- and then the ProcessAll functionality becomes it's own routine.)
-- Finally, the manager will handle the second stage of processing (essentially
-- the staging and filesystem shenanigans)

--- MODULE API ---
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
