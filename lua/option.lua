--- option.lua - Script argument processing

-- USAGE: Parses script arguments from a pre-defined structure (see __options)
-- STATE: Singleton instance; values held by this module
-- RTYPE: Module (API table -> instance)
-- NOTES --
--	  > I'm itching to refactor this... The bones feel great: modular
-- 		definitions, rigid API, etc. But the parsing is limited, and the API
-- 		seems clunky. I keep imaginging the return value of this module is just
-- 		a table with the options inside (wrapped by some MT magic.) But that
-- 		conflicts with delayed error handling, generated "help" output, and
-- 		variable input to the parser for the sake of tests. I could just merge
-- 		the two, but then what about namespace clashes (like an error() api
-- 		function version an --error option?) I could make all the options
-- 		lowercase and throw an error, but then I'm introducing "invisible"
-- 		syntax rules.

-- Supported option data types
-- Value is a closure-generating function which verifies the range of the input
local __types = setmetatable({
	String = function(range)
			if (range and (type(range) ~= "table")) then
				-- Developer error
				error("[option.lua] Bad use of String type; range is not a table")
			elseif (range == nil) then
				-- Fallback to any value so long as it's a non-empty string
				return setmetatable({}, {
					__index = { type = "String" },
					__call = function(input)
						local key = tostring(input):upper()
						return (#key > 0) and key or nil
					end })
			end

			-- Returns str_val if in range, else nil
			return setmetatable(range, {
				__index = { type = "Enum" },
				__call = function(input)
						local str_input = tostring(input)
						local valid = true
						-- Minimum string length (incl)
						if (valid and range.minlength) then
							valid = #str >= range.minlength
						end
						-- Maximum string length (incl)
						if (valid and range.maxlength) then
							valid = #str <= range.maxlength
						end

						-- Anything else?? (TODO*)

						return valid and str_input or nil
					end })
		end,
	Enum = function(range)
			if (range and (type(range) ~= "table")) then
				-- Developer error
				error("[option.lua] Bad use of Enum type; range is not a table")
			elseif (range == nil) then
				-- Fallback to string type with no bounds
				-- (This works because thus chunk is only executed when calling
				-- __types.Enum() so __types.String() also must exist already.)
				return __types.String()
			end

			-- Returns (enum_val, int_val) if valid, else nil
			-- Allows options to be changed at runtime before parsing
			return setmetatable(range, {
				__index = { type = "Enum" },
				__call = function(_, input)
					if (type(input) == "number") then
						-- Handle numerical indexing; might happen internally
						if (range[input]) then
							return range[input], input
						end
						return nil
					end
					local enum_val = tostring(input):upper()
					for _k, _v in pairs(range) do -- pairs() to allow for holes
						if (type(_k) == "number" and _v == enum_val) then
							return _v, _k
						end
					end
					-- implied `return nil`
				end })
		end,
}, {
	__index = function(_, key)
			-- Developer error (likely a typo)
			error("[option.lua] Unsupported data type `" .. key .. "`")
		end
})

-- Available script options
local __options = {
	-- <OPTION (proper name)>
		-- range: Acceptable values (checked by valid function)
		-- default: Default value if none specified
		-- * count: Expected number of arguments (i.e. `--mode install` has one)
		-- flagchar: Short-hand letter (i.e. --script === -s)
		-- * unset: Sets a flag option to false (maybe create __types.Flag and put this and flagchar in that param?)
		-- desc.name: Usage info - name of option
		-- desc.summary: Usage info - brief summary of option
		-- process: Closure to be ran when option value is requested
		-- * transform: Closure to convert raw input before validation
		-- * nullable: If nil is a valid value or not
	mode = {
		range = __types.Enum({ "USAGE", "INSTALL", "CHECK", "TEST" }),
		default = "USAGE",
		-- count = 1, (refactor pending: implied by Enum type)
		desc = {
			name = "mode",
			summary = "Script operation mode.",
			-- error = "",
		}
	},
	features = {
		-- TODO: To make SYSTEM work, feature selection should go after target
		-- system selection...there are other considerations like default to
		-- SELECT if no system was specified.
		range = __types.Enum({ "ALL", "SELECT", "USER", "ROOT", "SYSTEM" }),
		default = "ALL", -- TODO: Consider changing to USER once kinks are worked out
		-- count = 1, (refactor pending: implied by Enum type)
		flagchar = "f",
		desc = {
			name = "features",
			summary = "Which features to install or compare (user and system WIP.)",
		}
	},
	system = {
		-- Auto means try to detect the system, none means select no
		-- system-specific config
		range = __types.String(),
		default = "AUTO",
		-- count = 1, (refactor pending: implied by Enum type)
		flagchar = "t",
		desc = {
			name = "system",
			summary = "Target system for unagnostic configuration entries (also AUTO, NONE.)",
		}
	},
	script = {
		default = false,
		-- count = 0, (refactor pending: implied by Flag type or none at all for now)
		flagchar = "s",
		desc = {
			name = "script",
			summary = "Skip interactive prompts.",
		}
	},
	pretend = {
		default = true, -- false (force true for development)
		-- count = 0, (refactor pending: implied by Flag type or none at all for now)
		flagchar = "p",
		desc = {
			name = "pretend",
			summary = "Instead of taking any action, dump what would be done to stdout.",
		}
	},
	-- dummy = { default = nil } -- This works!
}

-- From the static option defs, build the data store index
-- As the data table will be indexed by table types, __map allows multiple
-- names to refer to the same data
local __map = setmetatable({
	flags = {},
	invflags = {}, -- TODO
	posopts = {}, -- TODO
	-- Using the __index MT is cleaner than copying every k,v pair in __options
	-- since the format is already correct
}, { __index = __options })
for opt, data in pairs(__options) do
	if (data.flagchar) then
		assert(#data.flagchar == 1, "[option.lua] Bad flagchar: " .. tostring(data.flagchar))
		__map.flags[data.flagchar] = data
	end
	-- TODO: Check data.range for flags and invflags
	-- TODO: Check for pos specification (i.e. MODE is position 1 for this program)
end

local __state = {
	ERROR = TRUE, -- True while DATA is nil, resets to false when parse called
	DATA = nil -- Key is the option spec table, value is the dynamic option data
}

--- MODULE API ---
local Module = {}
Module.__index = function(_, key)
	local fn = Module[key]
	if fn then
		return fn
	end

	local msg_on_error = string.format("[option.lua] Reference to undefined option `%s`", key)
	local index = __options[key] -- Technically should be __map[key] but I haven't exactly worked out flags yet

	assert(index, msg_on_error)
	return __state.DATA[index] or index.default
end
Module.__newindex = function()
	error("[option.lua] Bad access; module is read-only")
end
-- Pairs can be used to list all options
-- Will not work in lua < 5.2! (does nothing)
-- TODO: This technically makes __options modifyable, which we'd like to avoid
-- Module.__pairs = function()
	-- local k, v
	-- return function()
		-- repeat k, v = next(__options, k)
		-- until (k == nil) or (type(k) == "string"
			-- and k:match("^[^_]+") -- Skip any options preceeded by an underscore
			-- and type(v) == "table")
		-- return k, v
	-- end, nil, nil
-- end

-- Parse performs the logic of splitting an array of args into named options
-- Generally called once automatically at script init; calling again will reset
-- the parse data and use the new parse instead (intended for unit tests)
function Module.Parse(_, input)
	if (type(input) == "string") then
		local intbl = {}
		for arg in input:gmatch("[^%s]+") do
			table.insert(intbl, arg)
		end
		input = intbl
	elseif (input == nil) then
		input = rawget(_G, "arg") -- Raw script arguments
	end
	assert(type(input) == "table", "[option.lua] Error getting script arguments")
	-- Reset module state
	__state.ERROR = false
	__state.DATA = {}

	local optqueue = {}
	local optidx = 1
	local modeset = false

	for _, arg in ipairs(input) do
		local isopt, islong, key = arg:match("(-?)(-?)(%w+)")

		-- User specified an option (-option)
		local opt_spec
		if #isopt > 0 then
			if #islong > 0 then
				opt_spec = __options[key] -- Technically should be __map[key] but I haven't exactly worked out flags yet
				if not opt_spec then
					__state.ERROR = "Unrecognized option: " .. (arg or "<nil>")
					return -- error set
				end
			else
				for charidx = 1, #key do
					local flagchar = string.char(key:byte(charidx))

					opt_spec = __map.flags[flagchar]
					if not opt_spec then
						__state.ERROR = "Unrecognized option: " .. (arg or "<nil>")
						return -- error set
					end
				end
			end

			-- Capture the option that will be set
			-- TODO: The following checks for the param length and assumes either
			-- 	0 or 1, the former being a "boolean" option, the latter being
			-- 	anything else.
			if not opt_spec.range then
				-- TODO: Also check for boolean type with range.type == "Flag"
				__state.DATA[opt_spec] = true
			else
				table.insert(optqueue, opt_spec)
			end

		-- User specified a value (value)
		else
			-- Pluck option value from whatever we're parsing
			opt_spec = optqueue[optidx]
			if not opt_spec then -- No more user options, fallback to mode (TODO: Change this to __map.pos[1])
				if modeset then
					__state.ERROR = "Unrecognized option: " .. (arg or "<nil>")
					return -- error set
				else
					-- We will always set mode with the first "floating" argument
					-- TODO: Probably should make this more general-form and configurable
					__state.DATA[__options.mode] = key
					modeset = true
				end

			else
				__state.DATA[opt_spec] = key
				optidx = optidx + 1
			end
		end
	end

	if #optqueue >= optidx then
		__state.ERROR = "Not enough arguments"
	end
end

-- For every available option, verify that the value is within range
-- Returns FALSE if any option fails the range check, followed by an error message
-- NOTE: To define an option which *must* be defined, let the default value be
-- 	nil and the range specify non-nil values
function Module.Verify(_)
	local err_fmt = "Invalid value `%s` for option: %s"  -- (rawvalue or "<nil>")
	for opt_name, opt_spec in pairs(__options) do
		if not opt_spec.range then
			goto continue
		end

		local raw_value = __state.DATA[opt_spec] or opt_spec.default
		local ck_value = opt_spec.range(raw_value)

		-- TODO: If adding support for nil values, add that check here!
		if (ck_value == nil) then
			if not opt_spec.default then
				-- Special error message for non-empty values
				return false, string.format("Option %s cannot be empty", opt_name)
			end
			return false, string.format(err_fmt, tostring(raw_value), opt_name)
		end

		-- Update option state with validated data
		__state.DATA[opt_spec] = ck_value

		::continue::
	end
	return true, nil
end

-- Used exclusively at the top of a script; Don't process values yet, just
-- show what was parsed from the command line
function Module.Dump(_)
	print("Script options:")
	for opt_name, opt_spec in pairs(__options) do
		opt_val = __state.DATA[opt_spec] or opt_spec.default
		if opt_val ~= false then
			opt_name = opt_name:sub(1, 7):upper() -- Prettier formatting
			opt_val = (type(opt_val) == "string") and opt_val:lower() or opt_val
			opt_val = opt_val or "<none>"
			print(" │    >", opt_name, opt_val)
		end
	end
	print() -- Pretty formatting
end

-- Error flag getter (set during a parse error, not a failed range validation)
function Module.Error(_)
	return __state.ERROR
end

function Module.Usage(_)
	print("USAGE: catalyst <mode> [-t system] [-f features] [-p] [-s]")
	for k, v in pairs(__options) do
		print("\n     * ", k .. " -- (default: " .. tostring(v.default) .. ")")
		print("", v.desc.summary)
	end
end

-- Return module via a proxy
Module:Parse() -- Parse the arguments fed to the script `config arg1 arg2 ...`
return setmetatable({}, Module)
