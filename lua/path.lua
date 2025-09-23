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

-- Creates and returns a path obj table only (no MT)
-- Copies data from ref, if provided
local function _new(path_ref)
	local obj = {
		_data = {}, 
		_vars = varpath_tbl,
		_index = nil, -- Placeholder
		_pref = 0, -- Count of leading parent refs (i.e. ../../../dir -> 3)

		absolute = false, -- TODO
	}

	if path_ref and (type(path_ref._data) == "table") then
		for _, val in ipairs(path_ref._data) do
			table.insert(obj._data, val)
		end
		_data._vars = path_ref._vars
		_data._pref = path_ref._pref
		_data.absolute = path_ref.absolute
	end

	return path_ref
end

local function _split(path_str, varpath_tbl, append_mode)
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
				-- current_varpath = varpath_key -- Not used at path start

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

	splitter(path, not append_mode, 1)
	splits._absolute = absolute
	return splits --[[, err]]
end

-- Build creates a new table always
-- path_obj is a reference to a path to copy or nil
local function _build(path_obj, path_splits)
	local _copy = _new(path_obj)
	local _warning = false -- For helpful output (only)

	if not path_splits then
		-- Return right away if nothing to append (cleanup for path:Append())
		return _copy
	end

	local data = _copy._data -- Ref
	local accept_index = #data -- TODO: test this
	for _, split in ipairs(path_splits) do
		if split == "." then
			-- Ignore
		elseif split == ".." then
			if accept_index > 0 then
				-- Step backward up the filetree
				-- TODO: This differs slightly from unix: where if a given path
				-- is a symlink, then traversing back up will navigate into the
				-- directory containing the target of the symlink instead. That
				-- functionality is not reflected here. Should it be?

				data[accept_index] = nil
				accept_index = accept_index - 1

				if not _warning then
					print("Warning: it is advisable to avoid ../ within spec install paths")
					_warning = true
				end
			elseif not path_splits.absolute then
				-- Index is 0: no known dirs to step up
				_copy._pref = _copy._pref + 1
			else
				-- Path is: /(../)whatever
				-- (this is technically okay: in unix /../ -> /; but high chance of user error in specs)
				assert(false, "Unable to specify parent of root directory")
			end
		else
			accept_index = accept_index + 1
			splits[accept_index] = segment
		end
	end

	return setmetatable(_copy, {
		__index = api,
		__newindex = function()
			-- Not rigorous here, just help track of developer mistakes
			error("Attempt to add new member to path table")
		end
	})
end

--

function api.Length(self)
	return #self._data
end

function api.GetAbsolute(self)
	-- TODO: Get (guess) an absolute path or return if already absolute
	-- TODO: Should this also resolve all parent path refs? (../)
end

-- Copies and returns a modified path
function api.Append(self, subpath_str)
	local split_data = subpath_str and _split(subpath_str, self.vars, true)
		or nil
	return _build(self, split_data)
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
		local split_data, err = _split(path_str, varpath_tbl, false)
		if err then
			error(err)
		end

		return _build(nil, split_data)
	end
})
