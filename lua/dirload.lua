-- Require a directory all at once; helper for spec files
-- Adapted from: https://github.com/Nikaoto/dirload.lua

-- Require all .lua files from a given directory.
-- Does not traverse directories inside of directories.

-- TODO: This is quite similar to the API of filesystem.lua...
-- It might be worth replacing this call with one from that module?
local function get_directory_items(path)
	-- Original dirload used love2d/luafilesystem, neither of which we would
	-- expect to have installed this early. Thus, we use bash instead.

	-- Strict input validation (all use cases are known repo file paths)
	if type(path) ~= "string" then
		error("Bad call to get_directory_items; path must be a string")
	elseif not path:match("^[%w_/-]+$") then
		error("Bad call to get_directory_items; path is invalid: " .. path)
	end

	local contents = {}

	-- Working directory assumed to be repo root (lua script breaks otherwise)
	local shell_handle = io.popen("ls " .. path)
	local output = shell_handle:read("*a")
	for path in output:gmatch("[%w%._-]+") do
		table.insert(contents, path)
	end
	shell_handle:close()

	return contents
end

local function dirload(path, opts)
	opts = opts or {}

	-- Fixup path for concatenation
	if not path:match("/$") then
		path = path .. "/"
	end

	-- Create ignored files table
	local ignore_tbl = {}
	if opts.ignore then
		for _, f in pairs(opts.ignore) do
			ignore_tbl[f] = true
		end
	end

	local index = {}
	for _, file in pairs(get_directory_items(path)) do
		local ignored = ignore_tbl[file]

		local module = file:match("(.*)%.lua$")
		if module and not ignored then
			-- Using loadfile for a couple reasons: Defer handling errors, no
			-- additional path cleanup (module formatting replaces / with .),
			-- and better coupling with hook functions
			local chunk, err = loadfile(path .. file)
			local content = nil
			if chunk then
				if opts.on_load == false then
					-- Specify false to just return the lua chunk
					content = chunk
				else
					local on_load = opts.on_load or function(c, m, p)
						local _status, _content = pcall(c)
						if _status and (_content == nil) then
							return nil, "Nothing returned from module"
						end
						return _content
					end

					content, err = on_load(chunk, module, path)
				end
			end

			if err then
				if opts.on_error then
					content = opts.on_error(module, path, err)
				else
					print(string.format("Error loading \"%s\": %s", module, err))
				end
			end

			if content ~= nil then
				index[module] = content
			end
		end
	end

	return index
end

return dirload
