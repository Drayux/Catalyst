-- Represent an arbitrary filesystem with lua tables
-- This can be used to track directory merges and file conflicts

-- NOTE: This is not meant to be a recreation of the global filesystem. This
-- structure is used to prepare the selected feature configs for installation;
-- used to check for conflicts and determine what directories to create.

-- NOTE: Currently defined as a singleton since only one instance will be used
-- per invocation of this script. That known, this logic would otherwise be
-- well-suited for repurpose in an object-oriented architecture.

--


local path_utils = require("lua.path") -- TODO: remove this dependency 

-- Filesystem function interface
local _api = {}
local _tree = {} -- Filesystem internal storage

local edit_data = {} -- Edits staged for generation (table)
local file_data = {} -- Final file install contents (array)

-- Nomrally source is the link target (aka the "source" file w/in the repo)
-- For copy operations, source refers to the the "copy from" file
function _api.AddFile(install_path, source, type)
	-- TODO: Consider assertion that both inputs are path objects
	install_path = install_path:Absolute()
	type = type or _api.LINK -- Allow symlink as default install type

	local final_segment
	local target_depth = install_path:Length()
	local data_ptr = _tree

	-- Traverse the install tree or create directories as we go
	-- TODO: for depth, segment in ipairs(install_path) do
	for depth, segment in ipairs(install_path._tree) do
		if depth == target_depth then
			-- Push the last segment up in scope and break
			final_segment = segment
			break
		end

		-- Create new directory if necessary
		if not data_ptr[segment] then
			data_ptr[segment] = {}
		end

		-- Traverse filetree
		data_ptr = data_ptr[segment]
		assert(type(data_ptr) == "table",
			string.format("Spec conflict; `%s` already exists", install_path:String()))
	end

	-- Should only trigger if install_path was empty (probably?)
	assert(final_segment,
		string.format("Attempted to add invalid install path `%s`", install_path:String()))

	-- Error on any conflict, even if it's a directory
	-- (This deviates from classical unix behavior that puts the new file inside the dir)
	assert(not data_ptr[final_segment],
		string.format("Spec conflict; `%s` already exists", install_path:String()))

	-- Create final file object for staging
	if type ~= _api.LINK then
		source = source:Absolute()
	end
	local contents = {
		source = source, -- The data origin of the staged file
		location = install_path -- The path that the new file is created
		type = type, -- Link, copy, etc.
	}

	table.insert(file_data, contents) -- Append contents obj to final install array
	data_ptr[final_segment] = source:String() -- TREE[install_path] = source (aka link target)
end

-- System configuration edits are staged in their own table for processing once
-- the staging tree is verified
function _api.AddEdit(edit_uid, edit_spec)
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
	staged_edit = edit_data[edit_uid]
	if not staged_edit then
		staged_edit = {}
		edit_data[edit_uid] = staged_edit
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
function _api.Print()
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
					_worker(_out, _subdir, _subcontents, _indent .. indent_fin, _indent ..indent_alt)
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

	_worker(output, "<< root >>", _tree, "", nil)
	print(table.concat(output))
end

-- Module proxy table
local module = {
	-- Enum-like installation 'types'
	PATH = {}, -- Path install (absolute symbolic link, default for dotfiles)
	COPY = {}, -- File copy (used by edit installs)
	HARD = {}, -- Hard link to dotfile (rare, but supported)
	LINK = {}, -- Relative symbolic link (usually for hidden file fixup)
}

return setmetatable(module, {
	__index = function(self, key)
		local _fn = _api[key]
		assert(_fn, string.format("No method %s exists for staging module", key))

		-- Since this is a singleton module, we don't actually need to invoke with 'self'
		local closure = function(self, ...)
			assert(self == module,
				"Object method must be invoked as object (use `:` instead of `.`)")
			return _fn(...)
		end

		rawset(self, key, closure)
		return closure
	end,
	-- Trivial read-only
	__newindex = function()
		error("Staging filetree module is read-only")
	end,
	-- Iterator over final install contents
	__pairs = function(self)
		local iter = ipairs(file_data)
		-- TODO: Test this (no idea if it works)
		return function()
			return iter(file_data, ret)
		end, nil, nil
	end
})
