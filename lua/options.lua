-- Options helpers
local transform_EnumOption = function(option, input)
	if (type(option.range) == "table") then
		-- return option.range[tostring(input):upper()]
		local key = tostring(input):upper()
		return option.range[key] and key or nil
	end
	-- Developer error, raise exception
	error("Bad use of transform_EnumOption; option.range is not an enum table")
end

-- Some options may require additional processing (i.e. system "AUTO")
local function process_System(initial_target)
	local systems = require("lua.dirload")("spec/system")
	local target_system = nil

	if initial_target == "AUTO" then
		-- Figure out what system we're installing to
		-- NOTE: Relatively lazy heuristic, score better than a 4 for a system to
		-- be a valid candidate
		local best_score = 4
		for sys, spec in pairs(systems) do
			if type(spec.score) == "function" then
				local score = spec.score()
				if score > best_score then
					best_score = score
					target_system = sys
				end
			end
		end

		if target_system then
			print("Detected " .. target_system:upper() .. " as the target system")
		else
			print("Target system could not be determined")
			-- TODO: Consider prompting the user if they want to quit
		end
		print() -- Useless formatting

	elseif initial_target ~= "NONE" then
		-- TODO: This lower() is a side effect of the current options parsing
		target_system = initial_target:lower()
	end

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

-- Available script options
local _data = {}
local options = setmetatable({
	-- <OPTION (proper name)>
		-- range: Acceptable values (checked by valid function)
		-- default: Default value if none specified
		-- transform: Closure to convert raw input before validation
		-- process: Closure to be ran when option value is requested
		-- count: Expected number of values
		-- desc.name: Usage info - name of option
		-- desc.summary: Usage info - brief summary of option
	mode = {
		range = { USAGE = 0, INSTALL = 1, CHECK = 2, TEST = 3 },
		default = "USAGE", -- 0
		transform = transform_EnumOption,
		count = 1,
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
		range = { ALL = 0, SELECT = 1, USER = 2, ROOT = 3, SYSTEM = 4 },
		default = "ALL", -- TODO: Consider changing to USER once kinks are worked out
		transform = transform_EnumOption,
		count = 1,
		desc = {
			name = "features",
			summary = "Which features to install or compare (user/system WIP.)",
		}
	},
	system = {
		-- TODO: Instead of checking an enum, build possible options from the
		-- spec/system directory (systems would become case-sensitive, would
		-- feel more like feature selection)
		-- Auto means try to detect the system, none means select no
		-- system-specific config
		range = { AUTO = 0, NONE = 1, CATALYST = 2, CHITIN = 3, WORK = 4 },
		default = "AUTO", -- 0
		transform = transform_EnumOption,
		process = process_System,
		count = 1,
		desc = {
			name = "system",
			summary = "Target system for unagnostic configuration entries.",
		}
	},
	script = {
		default = false,
		count = 0,
		desc = {
			name = "script",
			summary = "Skip interactive prompts.",
		}
	},
	pretend = {
		default = true, -- false (force true for development)
		count = 0,
		desc = {
			name = "pretend",
			summary = "Instead of taking any action, dump what would be done to stdout.",
		}
	},

	__flags = {},
	__error = false,

	-- Used exclusively at the top of a script; Don't process values yet, just
	-- show what was parsed from the command line
	print = function(self)
		print("Script options:")
		for opt_name, opt_meta in pairs(self) do
			opt_val = _data[opt_meta] or opt_meta.default
			if opt_val ~= false then
				opt_name = opt_name:sub(1, 7):upper() -- Prettier formatting
				opt_val = (type(opt_val) == "string") and opt_val:lower() or opt_val
				print(" │    >", opt_name, opt_val)
			end
		end
		print() -- Useless formatting
	end
}, {
	__index = function(self, key)
			if type(key) == "table" then
				local option_value = _data[key] or key.default

				if key.process then
					option_value = key.process(option_value)
					_data[key] = option_value

					-- NOTE: This could be changed here if I needed to run the key
					-- process more than once
					key.process = nil
				end

				return option_value
			end
		end,
	__newindex = function(self, key, rawvalue)
			-- Force table writes to nested proxy
			if type(key) ~= "table" then
				-- Developer error, raise exception
				error("Options table is read only (requires option as key)")
			end

			-- Range check the argument if necessary
			local value
			if key.transform then
				value = key:transform(rawvalue)
			else
				value = rawvalue
			end

			if value == nil then
				self.__error = "Invalid option value: " .. (rawvalue or "<nil>")
			else
				-- Duplicate args will be overwritten
				-- rawset(_data, key, value)
				_data[key] = value
			end
		end,

	-- Pairs can be used to dump all options
	-- Will not work in lua < 5.2! (does nothing)
	__pairs = function(self)
			local k, v
			return function(self)
				-- Skip all items except for option values
				-- aka. Tables whose names do not begin with _ and whose values are tables
				repeat k, v = next(self, k)
				until (k == nil) or (type(k) == "string"
					and k:match("^[^_]+")
					and type(v) == "table")

				if k then
					return v.desc.name, self[k]
				else
					return nil
				end
			end, self, nil
		end,

	-- Call is responsible for parsing arguments
	__call = function(self, input)
			local intbl = input or rawget(_G, "arg") -- Script arguments

			local optqueue = {}
			local optidx = 1
			local modeset = false

			for _, a in ipairs(intbl) do
				local isopt, islong, key = a:match("(-?)(-?)(%w+)")

				-- User specified an option (-option)
				if #isopt > 0 then
					if #islong > 0 then
						local option = self.__flags.long[key]
						if not option then
							self.__error = "Unrecognized option: " .. (a or "<nil>")
							goto error
						end

						-- Check if this is a boolean argument
						if not option.valid then
							self[option] = true -- Writes to _data
						else
							table.insert(optqueue, option)
						end
					else
						for charidx = 1, #key do
							local keychar = string.char(key:byte(charidx))
							local option = self.__flags.short[keychar]
							if not option then
								self.__error = "Unrecognized option: " .. (a or "<nil>")
								goto error
							end

							-- Check if this is a boolean argument
							if (not option.count) or (option.count == 0) then
								self[option] = true -- Writes to _data
							else
								table.insert(optqueue, option)
							end
						end
					end

				-- User specified a value (value)
				else
					-- Pluck option value from whatever we're parsing
					local option = optqueue[optidx]
					if not option then -- No more user options, fallback to mode
						if modeset then
							self.__error = "Unrecognized argument: " .. (a or "<nil>")
							goto error
						else
							-- We will always set mode with the first "floating" argument
							-- TODO: Probably should make this more general-form and configurable
							self[self.mode] = key
							modeset = true
						end

					else
						self[option] = key -- Writes to _data, may set self.__error
						if self.__error then
							goto error
						end

						-- NOTE: Multi-value options currently unsupported,
						--   but the skeleton is halfway in place
						optidx = optidx + 1
					end
				end
			end

			if #optqueue >= optidx then
				self.__error = "Not enough arguments"
			end

			::error::
			return self
		end
})

-- Option flag indexing
-- NOTE: If improving this, it would be prudent to save these in the option
-- itself, and then generate the __flags table once
options.__flags.short = {
	f = options.features,
	t = options.system,
	p = options.pretend,
	s = options.script,
}
options.__flags.long = { }

return options() -- Parse the arguments fed to the script `config arg1 arg2 ...`
