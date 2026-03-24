--- staging.lua - Shallow filesystem tree via lua tables

-- USAGE: Track directory merges and file conflicts for spec installs
-- STATE: Singleton instance; values held by this module
-- RTYPE: Module (API table -> instance)
-- NOTES: --
--    >	This is not meant to be a recreation of the global filesystem. This
-- 		structure is used to prepare the selected feature configs for installation;
-- 		used to check for conflicts and determine what directories to create.
--    >	Currently defined as a singleton since only one instance will be used
-- 		per invocation of this script. That known, this logic would otherwise be
-- 		well-suited for repurpose in an object-oriented architecture.


-- TODO: Pending updates to the staging tree (part of the API rework)
--
-- At the end of the day, installing is as simple as making a bunch of links/
-- copying files, uninstalling should be as simple as deleting those.
--
-- The challenge arises when tracking what gets installed.
--
-- Generally, the flow might be to mock up what feature would install which
-- files, and then compare that with the existing filesystem.
-- If there are no conflicts: Install right away
-- If there are conflicts with "known" files, delete/install overtop 
-- If any conflict is not known, then we might want to abort*
--
-- What constitutes a known file?
--
-- If an install cache exists and the file matches, then we know it came from
-- catalyst.
-- If the file matches but is newer that the cache, we should WARN and update
-- the timestamp (take ownership again)
-- If the cache does not exist but the file matches staging, we should WARN and
-- update ownership
--  >>> Those are the easy cases, then we can delete and recreate if the new
-- config changes from the cached install <<<
-- If the file does not match staging or cached, we should ABORT.


local path = require("lua.path") -- File tree composed of path types

-- Staging tree internal storage
local __tree = {}

--- MODULE API ---
local Module = {
	edit_data = {}, -- Edits staged for generation (table)
	file_data = {}, -- Final file install contents (array)
}
Module.__index = function(self, key)
	local fn = Module[key]
	if fn then
		return fn
	end
	-- TODO: Previously I asserted that the function was invoked with `:` and
	-- saved the closure, do I want to do this? (question of consistency/style)
	error(string.format("[staging.lua] No such method `%s`", key))
end
Module.__newindex = function()
	error("[staging.lua] Bad access; module is read-only")
end
Module.__pairs = function(self)
	-- Iterator over final install contents (only works in lua >= 5.2)
	local iter = ipairs(Module.file_data)
	return function() -- TODO: Test this (no idea if it works)
		return iter(Module.file_data, ret)
	end, nil, nil
end

-- Nomrally source is the link target (aka the "source" file w/in the repo)
-- For copy operations, source refers to the the "copy from" file
function Module.AddFile(_, install_path, source_path, type)
	local msg_on_error = "[staging.lua] Could not stage; `%s` not a valid `Path` class"
	assert(install_path.type == "Path", string.format(msg_on_error, tostring(install_path))
	assert(source_path.type == "Path", string.format(msg_on_error, tostring(source_path))

	install_path = install_path:Absolute()
	type = type or path.LINK -- Allow symlink as default install type

	local data_ptr = __tree
	local final_segment
	local target_depth = install_path:Length()
	local path_str = install_path:String()

	-- Traverse the install tree or create directories as we go
	-- TODO: `for depth, segment in ipairs(install_path) do`
	for depth, segment in ipairs(install_path._data) do
		if depth == target_depth then
			-- Last segment is the file to add
			final_segment = segment
			break
		end

		-- Create new pseudo-directory if necessary
		if not data_ptr[segment] then
			data_ptr[segment] = {}
		end

		-- Traverse filetree
		data_ptr = data_ptr[segment]
		assert(type(data_ptr) == "table",
			string.format("Spec conflict; `%s` already exists", path_str))
	end

	-- Should only trigger if install_path was empty (probably?)
	assert(final_segment,
		string.format("Attempted to add invalid install path `%s`", path_str))
	-- Error on any conflict, even if it's a directory
	-- (This deviates from classical unix behavior that puts the new file inside the dir)
	-- TODO: Maybe I want to continue if it's the same file?
	assert(not data_ptr[final_segment],
		string.format("Spec conflict; `%s` already exists", path_str))

	-- Create final file object for staging
	if type ~= path.LINK then
		source_path = source_path:Absolute()
	end
	local staged_file = {
		source = source_path, -- The data origin of the staged file
		location = install_path -- The path that the new file is created
		type = type, -- Link, copy, etc.
	}

	data_ptr[final_segment] = source_path:String() -- TREE[install_path] = source (aka link target)
	table.insert(Module.file_data, staged_file) -- Append contents obj to final install array
end

-- System configuration edits are staged in their own table for processing once
-- the staging tree is verified
-- TODO: It appears I left this function as a stub, so uh..finish it!
function Module.AddEdit(_, edit_uid, edit_spec)
	--[[ `edit_spec` input format example (probably, may be out of date)
		{
			file = "/etc/profile.d/zdotdir.sh",
			syntax = "shell",
			create = true, -- Do not error if original file is not found
			access = "0644", -- file / user: read/write / group: read / other: read
			sequence = {
				"zdotdir",
				-- Any additional edits to apply
			}
		} -- ]]

	-- Retrieve the staged edit to modify or create a new entry
	staged_edit = Module.edit_data[edit_uid]
	if not staged_edit then
		staged_edit = {}
		Module.edit_data[edit_uid] = staged_edit
	end

	-- Check the specified filepath
	-- Multiple features may request edits to the same sysconfig, however the
	-- flexible config format allows the user to specify that an target files
	-- are stored at different locations. This is not necessarily an error, but
	-- certainly an unlikely use case, so we want to warn before taking action.
	local target_path = staged_edit[file]
	if not (target_path
		and string.match(target_path, edit_spec[file] or ".*")
	then
		-- sad warning path
	end

end

-- Pretty output of the target filesystem
-- Each directory will output itself, recurse on its child directories, and
-- finally output its remaining children (which are not recursed)
function Module.Print()
	local output = {}
	local indent_inc = " │ "
	local indent_fin = " └ "
	local indent_alt = "   "

	-- > out: reference to the output table (will be merged with table.concat)
	-- > dirname: Name of directory being called (else it would only know its children)
	-- > contents: List of directory children (aka files/links per actual use case)
	-- > indent: Indent prefix (string) of the called directory
	-- > alt: Index prefix (string) for children (nil unless edge case of a directory
	--     that contains only subdirectories)
	local _worker; _worker = function(_out, _dirname, _contents, indent, alt)
		local subdirs, files

		-- First pass, filter contents
		for child, contents in pairs(_contents) do
			local is_subdir = (type(contents) == "table")
			if is_subdir then
				subdirs = subdirs or {} -- Init if not already
				table.insert(subdirs, child)
			elseif (type(contents) == "string") then
				files = files or {} -- Init if not already
				table.insert(files, child .. " --> " .. contents)

			-- Potential additional entries to support
			-- elseif (type(contents) == "boolean") then
				-- files = files or {}
				-- table.insert(files, child)
			-- else
				-- error("Invalid type in filesystem table, " .. type(contents))
			end
		end

		-- Insert self
		local num_items = (subdirs and #subdirs or 0) + (files and #files or 0)
		-- local end_str = (num_items > 0) and "/\n" or "/ <empty>\n"
		local end_str = "/\n"

		-- Each directory responsible for outputting self
		table.insert(_out, indent .. _dirname .. end_str)
		local new_indent = (alt or indent) .. indent_inc

		if num_items == 0 then
			files = { "(empty)" }
			num_items = 1
		end

		-- Second pass, output subdirectories/
		if subdirs then
			for _, _subdir in ipairs(subdirs) do
				local _subcontents = _contents[_subdir]
				if num_items == 1 then
					-- Special case so the last item uses the L symbol
					-- Note that we call out the original indent value
					local _indent = (alt or indent)
					_worker(_out, _subdir, _subcontents, _indent .. indent_fin, _indent .. indent_alt)
				else
					_worker(_out, _subdir, _subcontents, new_indent, nil)
				end

				num_items = num_items - 1
			end
		end

		-- Third pass, output links --> targets
		if files then
			for _, _file in ipairs(files) do
				if num_items == 1 then
					-- Special case so the last item uses the L symbol
					-- Note that we call out the original indent value
					new_indent = (alt or indent) .. indent_fin
				end
				table.insert(_out, new_indent .. _file .. "\n")
				num_items = num_items - 1
			end
		end
	end

	_worker(output, "<< root >>", __tree, "", nil)
	print(table.concat(output))
end

return setmetatable({}, Module)
