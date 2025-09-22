-- Represent an arbitrary filesystem with lua tables
-- This can be used to track directory merges and file conflicts

-- NOTE: This is not meant to be a recreation of the global filesystem. This
-- structure is used to prepare the selected feature configs for installation;
-- used to check for conflicts and determine what directories to create.

-- NOTE: Currently defined as a singleton since only one instance will be used
-- per invocation of this script. That known, this logic would otherwise be
-- well-suited for repurpose in an object-oriented architecture.

--


local path_utils = require("lua.path")

local _api = {} -- Filesystem function interface
local _data = {} -- Filesystem internal storage

function _api.AddFile(install_path, link_target, lut)
	-- TODO: Consider asserting that install_path is a string (aka split every time)
	-- Further, link_target will not need to be split, but resolved
	local path = (type(install_path) == "table") and install_path
		or path_utils.path_Split(install_path, lut)
	local install_ptr = _data

	-- Traverse the install tree or create directories as we go
	local segment
	local max_depth = #path
	for depth, _segment in ipairs(path) do
		segment = _segment
		if depth == max_depth then
			break
		end

		-- Create new directory if necessary, traverse filetree
		if not install_ptr[segment] then
			install_ptr[segment] = {}
		end
		install_ptr = install_ptr[segment]
		assert(type(install_ptr) == "table", string.format("Spec conflict; `%s` already exists", install_path))
	end
	assert(segment, string.format("Attempted to add invalid install path `%s`", install_path))

	-- This is a deliberate deviation from a classical unix CLI:
	-- Do not make files a child of an existing directory at that path if one exists
	assert(not install_ptr[segment], string.format("Spec conflict; `%s` already exists", install_path))
	install_ptr[segment] = link_target
end

-- Pretty output of the target filesystem
function _api.Print()
	assert(self == module, "Object method must be invoked as object (use `:` instead of `.`)")

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

	_worker(output, "<< root >>", _data, "", nil)
	print(table.concat(output))
end

local module = {} -- Module proxy table
return setmetatable(module, {
	__index = function(self, key)
		local _fn = _api[key]
		assert(_fn, string.format("No method %s exists for staging module", key))
		rawset(self, key, function(self, ...)
			assert(self == module, "Object method must be invoked as object (use `:` instead of `.`)")
			return _fn(...) -- Since this is a singleton module, we don't actually need to invoke with 'self'
		end)
		return self[key] -- Returns the new closure created just above
	end,
	-- Trivial read-only
	__newindex = function()
		error("Staging filetree module is read-only")
	end
})
