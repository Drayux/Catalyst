-- Represent an arbitrary filesystem with lua tables
-- This can be used to track directory merges and file conflicts

-- NOTE: Currently defined as a singleton since only one instance will be used
-- per invocation of this script. That known, this logic would otherwise be
-- well-suited for repurpose in an object-oriented architecture.

local user_home = os.getenv("HOME")
-- Ensure $HOME is defined; Home path will always be at least `/home` on any of
-- my systems, hence I assert at least that many characters
assert((type(user_home) == "string") and (#user_home >= 5))

local _filetree = {} -- Filesystem data ref
-- Some test "filesystems"
-- local _filetree = {
	-- cupcakes = {
		-- dog_toes = "tasty.txt",
		-- socks_in_mouth = "also_tasty.txt",
		-- waterfall = {
			-- riverbed = "double_tree.tar.gz"
		-- },
		-- hamburger = {
			-- mouth = "goated",
			-- ass = "silly",
		-- }
	-- },
	-- eggplant = {},
	-- headphone = {
		-- big_headphone = {
			-- sennheiser = "expensive",
			-- beyerdynamic = "bad_build_quality",
		-- }
	-- },
	-- sausage = "egg_mcmuffin.exe",
-- }
-- local _filetree = {
	-- recipes = {
		-- rice_and_beans = true,
		-- banana_bread = true,
		-- bacon_and_eggs = true,
	-- },
	-- furry_art = {
		-- ["dog1.png"] = true,
		-- ["dog2.png"] = true,
		-- ["dog3.png"] = true,
		-- ["dog4.png"] = true,
		-- ["dog5.png"] = true,
	-- }
-- }
local _api = {
	-- TODO: These functions are specifically for the tree but we might want
	-- to include some generic "utils" functions as well (like path_IsAbsolute)
	-- TODO (also): Improve the closure on _filetree with these functions
	print = function() tree_OutputTree(_filetree) end,
	link = function(l, t) tree_InsertLink(_filetree, l, t) end,
}

local function tree_InsertLink(link, target)
end

local function path_IsAbsolute(path)
	if type(path) ~= "string" then
		return false
	end
	return path:match("^[/~]") and true or false
end

local function tree_OutputTree(ft)
	local output = {}
	local indent_inc = " │ "
	local indent_fin = " └ "
	local indent_alt = "   "

	-- Worker subroutine
	-- Called for each directory - each directory responsible for outputting itself,
	--   queuing its subdirectories, and outputting the files it contains
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

		-- Third pass, output files -->
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

	_worker(output, "(root) ", ft, "", nil)
	print(table.concat(output))
end

local module = setmetatable({}, {
	__index = _api,
	-- Trivial read-only
	__newindex = function()
		error("Filetree module is read-only")
	end
})

module:print()

return module
