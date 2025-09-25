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
		_vars = false, -- Placeholder so __newindex doesn't error (_vars set after _build() in brand new path obj)
		_data = {}, 
		_pref = 0, -- Count of leading parent refs (i.e. ../../../dir -> 3)

		absolute = false,
		index = {},
	}

	if path_ref and (type(path_ref._data) == "table") then
		for _, val in ipairs(path_ref._data) do
			table.insert(obj._data, val)
		end
		obj._vars = path_ref._vars
		obj._pref = path_ref._pref
		obj.absolute = path_ref.absolute
	end

	return setmetatable(obj, {
		__index = api,
		__newindex = function()
			-- Not rigorous here, just help track of developer mistakes
			error("Attempt to add new member to path table")
		end,
		__tostring = function(self)
			return self:String()
		end
	})
end

-- Build creates a new table always
-- path_obj is a reference to a path to copy or nil
local function _build(path_obj, path_splits)
	local _copy = _new(path_obj)
	local _warning = false -- For helpful output (only)

	if not path_splits then
		-- Return right away if nothing to append (path:Append() symmetry)
		return _copy
	end
	
	local data = _copy._data -- Ref
	local accept_index = #data -- TODO: test this

	-- The path splits (data to be appended) will always be false on an append
	-- So we trust either one source reports TRUE
	-- (This order also replaces a nil path_splits._absolute with false)
	local is_absolute = path_splits._absolute or _copy.absolute
	for idx, split in ipairs(path_splits) do
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
			elseif not is_absolute then
				-- Index is 0: no known dirs to step up
				_copy._pref = _copy._pref + 1
			else
				-- Path is: /(../)whatever
				-- (this is technically okay: in unix /../ -> /; but high chance of user error in specs)
				error("Unable to specify parent of root directory")
			end
		else
			accept_index = accept_index + 1
			data[accept_index] = split
		end
	end

	_copy.absolute = is_absolute
	return _copy
end

-- Prepares a path for use with _build()
-- (Path to table converstion with varpath lookup)
local function _split(path_str, varpath_tbl, append_mode)
	-- path_str already validated; don't validate varpath_tbl until first lookup

	local splits = {}
	local absolute = not append_mode -- Assume true if start of path, else false
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

				splitter(varpath, true, _depth + 1) -- Recurse on path variables
			elseif _start and (path_start == "~") then
				-- Resolve homedir as a varpath (but only at start of path!)
				splitter("$user_home", true, _depth + 1)
			else
				-- If at split start, path is definitely not absolute (no leading / )
				-- Else (like in a recursive lookup) pass through the previous value
				absolute = absolute and (not _start)
				table.insert(splits, path_start)
			end
		else
			if not _start then
				-- No path_start so path has absolute format, but cannot be,
				-- as _start is false
				if append_mode then
					error(string.format("Cannot append absolute path `%s`", _path))
				else
					error(string.format("Path var `%s` appears absolute", current_varpath))
				end
			end
			path_end = _path
		end

		-- After this, any path will have a regular format ( /a/b/.../d )
		for segment in path_end:gmatch("/+([^/]+)") do
			local varpath_key = segment:match("^%$(.*)$")
			if varpath_key then
				local varpath = varpath_tbl[varpath_key]
print(varpath) -- something going silly here in tests
				assert(varpath, string.format("No such path variable `$%s`", varpath_key))
				current_varpath = varpath_key

				splitter(segment, false, _depth + 1) -- Recurse on path variables
			elseif segment == "." then
				-- Ignore
			else
				table.insert(splits, segment)
			end
		end
	end

	splitter(path_str, not append_mode, 1)
	splits._absolute = absolute
	return splits --[[, err]]
end

-- NOTE: path_str should probably be absolute?
local function _index(path_str)
	assert((type(path_str) == "string") and (#path_str > 0),
		"Feature config path must be a non-empty string")

	local results_tbl = {}
	local shell_handle

	shell_handle = io.popen(string.format("find \"%s\" -mindepth 1 -type f", path_str))
	local output = shell_handle:read("*a")
	for entry in output:gmatch(path_str .. "/(.-)\n") do
		-- NOTE: Unsure if an array or 'flag table' is better, may be worth testing
		table.insert(results_tbl, entry)
	end
	shell_handle:close()

	return results_tbl
end

--

function api.Search(self, query)
	local path_str = self:GetAbsolute()
	local pattern = "^" .. query .. "/?(.-)$"

	-- Index is just a filtered list of all children that are files
	-- (It is the result of `find` with the original search path omitted)
	self.index = self.index or index(path_str)

	local result
	for _, path in ipairs(self.index) do
		-- Anything that shows up after matching the start is a subpath;
		-- If an exact match shows up, it's just a file
		local subpath = path:match(pattern)
		if subpath then
			-- The capture resolves to "" on exact path match
			if #subpath == 0 then
				-- TODO: I don't remember what this was accomplishing
				-- ^^refer to what I was doing in feature install
				return query:match("^.*/(.-)$") or query
			end

			result = result or {}
			table.insert(result, subpath)
		end
	end
	return result
end

function api.Length(self)
	-- TODO: Test that this actually works
	return #self._data + self._pref
end

function api.String(self)
	local path_str = table.concat(self._data, "/")

	if self.absolute then
		-- Tack on leading /
		-- _build asserts that _pref is 0 when absolute is true
		return "/" .. path_str
	elseif self._pref > 0 then
		-- Build up the parent path string
		local parent_tbl = {}
		for i = 1, self._pref do
			table.insert(parent_tbl, "..")
		end
		if #path_str > 0 then
			-- Hacky way to insert the extra / in the middle
			table.insert(parent_tbl, path_str)
		end
		return table.concat(parent_tbl, "/")
	else
		if #path_str > 0 then
			return path_str
		else
			-- Keep relative paths CLI-friendly
			return "."
		end
	end
end

-- NOTE: For now, this function always creates a new path object
-- There is not yet a specific use case for this, but it may prove helpful
-- Notably, if searching a path, we will need to generate a new index anyway
function api.Absolute(self)
	if self.absolute then
		return _new(self)
	end

	-- Get the working directory from the current path lookup table
	-- TODO: This needs to be set up in features/environment
	local pwd_str = self._vars.install_root
	local pwd_splits = _split(pwd_str, self._vars, false)
	-- local pwd_splits = _split("$install_root", self._vars, false) -- Also works

	-- Manually build some splits from the original path object
	for idx = 1, self._pref do
		print("pref number:", idx)
		table.insert(pwd_splits, "..")
	end
	for segment in ipairs(self._data) do
		table.insert(pwd_splits, segment)
	end
	
	return _build(nil, pwd_splits)
end

-- Copies and returns a modified path
function api.Append(self, subpath_str)
	local split_data = subpath_str and _split(subpath_str, self.vars, true)
		or nil
	return _build(self, split_data)
end

return setmetatable({}, {
	__newindex = function()
		error("Path utilites module is read-only")
	end,
	__call = function(_, path_str, varpath_tbl)
		assert(type(path_str) == "string", "Path must be instantiated with a string")
		assert(#path_str > 0, "Path cannot be an empty string")
		
		-- Paths are stored as arrays of splits
		local split_data, err = _split(path_str, varpath_tbl, false)
		if err then
			error(err)
		end

		local path_obj = _build(nil, split_data)
		if varpath_tbl then
			path_obj._vars = varpath_tbl
		end

		return path_obj
	end
})
