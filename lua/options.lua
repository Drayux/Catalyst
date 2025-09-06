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

-- Available script options
local options = setmetatable({
	-- <OPTION (proper name)>
		-- range: Acceptable values (checked by valid function)
		-- default: Default value if none specified
		-- transform: Closure to convert raw input before validation
		-- count: Expected number of values
		-- desc.name: Usage info - name of option
		-- desc.summary: Usage info - brief summary of option
	mode = {
		range = { USAGE = 0, INSTALL = 1, CHECK = 2 },
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
		range = { ALL = 0, SELECT = 1, USER = 2, SYSTEM = 3 },
		default = "ALL", -- 0
		transform = transform_EnumOption,
		count = 1,
		desc = {
			name = "features",
			summary = "Which features to install or compare (select is WIP.)",
		}
	},
	system = {
		-- TODO: Consider reading these from a file
		-- Auto means try to detect the system, none means select no
		-- system-specific config
		range = { AUTO = 0, CATALYST = 1, CHITIN = 2, WORK = 3, NONE = 4 },
		default = "AUTO", -- 0
		transform = transform_EnumOption,
		count = 1,
		desc = {
			name = "system",
			summary = "Target system for unagnostic configuration entries.",
		}
	},
	debug = {
		default = true, -- false (force true for development)
		count = 0,
		desc = {
			name = "debug",
			summary = "Instead of taking any action, dump what would be done to stdout.",
		}
	},

	__data = {},
	__flags = {},
	__error = false,
}, {
	__index = function(self, key)
			if type(key) == "table" then
				return self.__data[key] or key.default
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
				rawset(self.__data, key, value)
			end
		end,

	-- Pairs can be used to dump all options
	-- Will not work in lua < 5.2! (does nothing)
	__pairs = function(self)
			local k, v
			return function(self)
				-- Keep looping until we find the next valid key and return it (or quit)
				-- aka: A table member that is not preceeded with an underscore
				repeat k, v = next(self, k)
				until (k == nil)
					or (type(k) == "string" and k:match("^[^_]+"))

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
							self[option] = true -- Writes to self.__data
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
								self[option] = true -- Writes to self.__data
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
						self[option] = key -- Writes to self.__data, may set self.__error
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
	s = options.system,
	d = options.debug,
}
options.__flags.long = { }

return options() -- Parse the arguments fed to the script `config arg1 arg2 ...`
