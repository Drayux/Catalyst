local _api = {} -- Filesystem function interface

-- TODO: Considering a refactor of this
-- I don't love that the relative paths defined here depend on varpath
-- variables defined elsewhere. The primary fix idea is to move the relative
-- path LUT to its own subtable in the LUT that would be provided by the
-- feature when calling path_Split()
local rel_path_lut = setmetatable({
	["~"] = user_home,
	["."] = "$install_root",
}, {
	__index = function(_, path)
		return "$feature_config/" .. (path or "")
	end
})
function _api.path_Split(path, lut)
	path = path or "."
	lut = lut or setmetatable({
		-- NOTE: An oversight of the current design is that (for now)
		-- feature_config MUST be defined in order for relative paths to work
		install_root = _api.path_GetDotfileRoot,
	}, { __index = function(_, key)
			error(string.format("No varpath set for $%s (fallback)", key))
		end })

	local splits = {}
	local accept_index = 0
	local parent_warning = false

	local splitter; splitter = function(_path, start, depth)
		if (depth > 5) then
			error("Variable path split maximum recursion depth reached")
		end

		-- Start is true whenever the beginning of a path is used as input
		-- This allows for relative path lookup
		if start then
			local path_start, path_end = _path:match("^([^/]+)(.-)$")
			if path_start then
				local varpath = path_start:match("^%$(.*)$")
				if varpath then
					path_start = lut[varpath]()
				else
					path_start = rel_path_lut[path_start]
				end

				splitter(path_start, true, depth + 1)
				_path = path_end
			end
		end

		-- By this point, we assert that any path segment is absolute
		if _path then
			for segment in _path:gmatch("/+([^/]+)") do
				local varpath = segment:match("^%$(.*)$")
				if varpath then
					segment = lut[varpath]()
					-- TODO: Might be a "prettier" solution, but TLDR we want
					-- to restore the slash that was plucked off just earlier
					splitter("/" .. segment, false, depth + 1)
				elseif segment == "." then
					-- Ignore
				elseif segment == ".." then
					-- Ensure that ipairs will stop when expected (if ../ was used)
					splits[accept_index] = nil
					accept_index = accept_index - 1
					assert(accept_index >= 0, "Unable to specify parent of root directory")

					if not parent_warning then
						print("Warning: it is advisable to avoid ../ in spec install paths")
						parent_warning = true
					end
				else
					accept_index = accept_index + 1
					splits[accept_index] = segment
				end
			end
		end
	end

	splitter(path, true, 1)
	return splits
end

-- TODO: The current implementation of path_Split() both resolves and splits
-- It does this recursively and it's really cool! But I hadn't considered that
-- would be much more versitle to resolve and then split.
-- Thus, this function does not translate any relative/parent paths!
function _api.path_Resolve(path_str, lut)
	local join_tbl = {}
	local resolver; resolver = function(segment, depth)
		if (depth > 5) then
			error("Variable path resolution maximum recursion depth reached")
		end

		local pre, var, post = segment:match("^(.-)$([^/]*)(.*)$")

		if not pre then
			-- Base case (no $var matched)
			-- NOTE: This is where I would resolve relative paths if necessary
			-- if (#join_tbl == 0) and is_relative_path(segment) then
			--     resolver("$feature_config", depth + 1)
			-- end
			table.insert(join_tbl, segment)
			return
		elseif #pre > 0 then
			table.insert(join_tbl, pre)
		end

		-- Lookup varpath
		local f_varpath = lut[var]
		if not f_varpath then
			-- Fallback if LUT does not raise an exception
			print(string.format("No value for var `%s`", var))
		else
			local varpath = f_varpath()
			if (#join_tbl > 0) and varpath:match("^[/~]") then
				-- Don't stop running, but warn for a possible config mistake
				print("Warning: absolute varpath used in middle of path")
			end
			resolver(varpath, depth + 1)
		end

		resolver(post, depth + 1)
	end

	resolver(path_str, 1)
	print(table.concat(join_tbl))
	-- return table.concat(join_tbl)
end

function _api.path_Join(path, lut)
	if type(path) == "string" then
		return path

	elseif type(path) == "table" then
		local join_tbl = {}
		for _, segment in ipairs(path) do
			table.insert(join_tbl, "/")
			table.insert(join_tbl, segment)
		end

		assert(#join_tbl > 1, "Cannot join empty path")
		return table.concat(join_tbl)
	end
	error("Cannot join nil path")
end

-- feature_config (path) needs to be absolute and resolved (I could add a more
-- rigid API but I have no reason for one right now)
-- TLDR we want to index all the entries within a feature config dir;
-- specifically using the same relpath so the spec is trivial to index
function _api.path_IndexFeature(feature_config)
	assert(type(feature_config) == "string", "Feature config path must be a string")
	assert(feature_config:match("^[/~]"), "Feature config path must be absolute")
	assert(not feature_config:match("%$"), "Feature config path must have varpaths resolved")

	local index = {}
	local shell_handle

	shell_handle = io.popen(string.format("find \"%s\" -mindepth 1 -type f", feature_config))
	local output = shell_handle:read("*a")
	for entry in output:gmatch(feature_config .. "/(.-)\n") do
		-- Setting this up as an array means we loop multiple times;
		-- but we save on memory space with big key names.
		-- Honestly no clue which is better and I don't have the time to test it rn
		table.insert(index, entry)
	end
	shell_handle:close()

	return index
end

-- Search for path_str in files index
-- returns string on exact match (path is a file)
-- returns table of files on partial match (path is a directory)
-- TODO: Rename this function
function _api.path_GlobPath(index, path_str)
	assert(type(index) == "table", "File index must be generated")
	assert(type(path_str) == "string", "Path to glob must be a string")
	assert(not path_str:match("%$"), "Path to glob must have varpaths resolved")

	local result
	local pattern = "^" .. path_str .. "/?(.-)$"
	for _, path in ipairs(index) do
		-- Anything that shows up after matching the start is a subpath;
		-- If an exact match shows up, it's just a file
		local subpath = path:match(pattern)
		if subpath then
			-- The capture resolves to "" on exact path match
			if #subpath == 0 then
				return path_str:match("^.*/(.-)$") or path_str
			end

			result = result or {}
			table.insert(result, subpath)
		end
	end
	return result
end

return setmetatable({}, {
	__index = _api,
	-- Trivial read-only
	__newindex = function()
		error("Path utilites module is read-only")
	end
})
