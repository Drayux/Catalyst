local dirload = require("lua.dirload")

-- Make a simple table of [feature_name] = true/false
local function features_GenerateList(self)
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
local function features_ModifyList(self, input_str)
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
local function features_ShowList(self)
	local _esc = string.char(27, 91)
	local enabled_text = _esc .. "32mINSTALL" .. _esc .. "0m"
	local disabled_text = _esc .. "31mSKIP" .. _esc .. "0m"

	print("Selected features:")
	for feat, en in pairs(self.selected) do
		print(" |    >", feat, en and enabled_text or disabled_text)
	end
end

-- TODO: Consider tweaking dirload such that the error message can be saved
-- here and then output can be deferred later (doesn't really matter, just a
-- possible nice-to-have)
local errormsg = nil

-- Local storage of feature tables
local features = {
	spec_list = dirload("spec/feature"),
	selected = nil,
	feat_count = 0,

	GenerateList = features_GenerateList,
	ModifyList = features_ModifyList,
	ShowList = features_ShowList,
}
-- Do some work when the module is first loaded
features:GenerateList()
if features.feat_count == 0 then
	errormsg = "No features available (is /spec/feature empty?)"
end

-- 

local module = setmetatable({
	interactive = function()
		local user_response = ""
		local first_time = true
		repeat
			-- Prompt the user for input
			features:ShowList(selected)
			if first_time then -- Show extra helper prompt
				first_time = false
				print(" | Select or deselect via space-seperated list, press ENTER to accept")
				print(" | (ex. SYSTEM -zsh hyprland)")
			end
			io.write(" └ ")
			user_response = io.read("*l")
			print() -- Useless formatting
		until features:ModifyList(user_response)
	end,
	print = function()
		features:ShowList()
	end,
	error = function()
		return errormsg
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
		features:ModifyList(input)
	end,
})

return module
