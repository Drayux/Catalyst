-- Represent an arbitrary filesystem with lua tables
-- This can be used to track directory merges and file conflicts

-- NOTE: Currently defined as a singleton since only one instance will be used
-- per invocation of this script. That known, this logic would otherwise be
-- well-suited for repurpose in an object-oriented architecture.

local user_home = os.getenv("HOME")
-- Ensure $HOME is defined; Home path will always be at least `/home` on any of
-- my systems, hence I assert at least that many characters
assert((type(user_home) == "string") and (#user_home >= 5))

local function path_IsAbsolute(path)
	if type(path) ~= "string" then
		return false
	end
	return path:match("^[/~]") and true or false
end

local function tree_OutputTree(ft)
	local output = {}
	local indent_inc = " │ "
	local indent_dir = " └ "

	local _worker; _worker = function(_out, _dirname, _contents, indent)
		local subdirs, files

		-- First pass, filter contents
		for child, contents in pairs(_contents) do
			local is_subdir = (type(contents) == "table")
			if is_subdir then
				subdirs = subdirs or {} -- Init if not already
				table.insert(subdirs, child)
			else
				files = files or {} -- Init if not already
				table.insert(files, child .. " --> " .. (contents or "<nil>"))
			end
		end

		-- Insert self
		local end_str = (subdirs or files) and "/\n" or "/ <empty>\n"
		table.insert(_out, indent .. indent_dir .. _dirname .. end_str)

		-- Second pass, output subdirectories
		if subdirs then
			for _, _subdir in ipairs(subdirs) do
				local _subcontents = _contents[_subdir]
				_worker(_out, _subdir, _subcontents, indent .. indent_inc)
			end
		end

		-- Third pass, output files
		if files then
			for _, _file in ipairs(files) do
				table.insert(_out, indent .. indent_inc .. indent_inc .. _file .. "\n")
			end
		end
	end

	_worker(output, "ROOT", ft, "")
	print(table.concat(output))
end

local filetree = {
	cupcakes = {
		dog_toes = "tasty.txt",
		socks_in_mouth = "also_tasty.txt",
		waterfall = {
			riverbed = "double_tree.tar.gz"
		},
		hamburger = {
			mouth = "goated",
			ass = "silly",
		}
	},
	eggplant = {},
	sausage = "egg_mcmuffin.exe",
}

-- return filetree

tree_OutputTree(filetree)
