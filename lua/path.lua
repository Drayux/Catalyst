-- Filesystem path utilites

-- Filepaths need to be manipulated and interpreted in muliple ways throughout
-- this script, primarily in the translation of config spec to actual
-- installation commands. Paths in this script also should support some form
-- of variable definition. Thus, the challenge becomes how to best represent a
-- path that can be in multiple states: Raw string with variables, raw string
-- with variables resolved, relative path, absolute path, table of directories,
-- etc.

-- This module provides an interface such that each path can be instantiated as
-- its own object. Therefore accessing any form of its state becomes a function
-- call to the respective method.

local api = {}

local function _split(path_str, varpath_tbl)
	-- path_str already validated; don't validate varpath_tbl until first lookup

	local splits = {}
	local absolute = true
	local current_varpath = nil -- For helpful output (only)

	local splitter; splitter = function(_path, _start, _depth)
		if (_depth > 5) then
			error("Variable path split maximum recursion depth reached")
		end

		-- Check if path is relative, make for an easier gmatch later
		local path_start, path_end = _path:match("^([^/]+)(.-)$")
		if path_start then
			local varpath_key = path_start:match("^%$(.*)$")
			if varpath_key then
				local varpath = varpath_tbl[varpath_key]
				assert(varpath, string.format("No such path variable `$%s`", varpath_key))
				-- current_varpath = varpath_key

				splitter(segment, true, depth + 1) -- Recurse on path variables
			else
				absolute = absolute and (not _start) -- false if splits start and no leading /
				table.insert(splits, path_start)
			end
		else
			if not _start then
				-- No path start so path is absolute, but not _start means that
				-- this is a varpath in the middle of a path string
				print(string.format("Warning: path var `%s` appears absolute", current_varpath))
			end
			path_end = _path
		end

		-- After this, any path will have a regular format ( /a/b/.../d )
		for segment in path_end:gmatch("/+([^/]+)") do
			local varpath_key = segment:match("^%$(.*)$")
			if varpath_key then
				local varpath = varpath_tbl[varpath_key]
				assert(varpath, string.format("No such path variable `$%s`", varpath_key))
				current_varpath = varpath_key

				splitter(segment, false, depth + 1) -- Recurse on path variables
			elseif segment == "." then
				-- Ignore
			else
				table.insert(splits, segment)
			end
		end
	end

	splitter(path, true, 1)
	splits._absolute = absolute
	return splits
end

local function _build(path_str, varpath_tbl)
end

--

function api.Length(self)
	return #self._data
end

function api.GetAbsolute(self)
	-- TODO: Get (guess) an absolute path or return if already absolute
end

function api.Append(self, subdir)
	-- TODO: Add to the current path with a new subdirectory
	-- (consider option to copy and add to a new path instance instead?)
end

function api.Search(self)
	-- TODO: Likely all-in-one replacement for index/search
end

return setmetatable({}, {
	__newindex = function()
		error("Path utilites module is read-only")
	end,
	__call = function(path_str, varpath_tbl)
		assert(type(path_str) == "string", "Path must be instantiated with a string")
		assert(#path_str > 0, "Path cannot be an empty string")
		
		-- Paths are stored as arrays of splits
		local path_data, err = _split(path_str, varpath_tbl)
		err = err or _build(splits) -- Skip build step if error in split step
		if err then
			error(err)
		end

		return path_data and setmetatable({
			_data = path_data, 
			_vars = varpath_tbl,
			_index = nil, -- Placeholder

			absolute = false, -- TODO
		}, {
			__index = api,
			__newindex = function()
				-- Not rigorous here, just help track of developer mistakes
				error("Attempt to add new member to path table")
			end
		})
	end
})
