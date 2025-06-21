-- >>> binds.lua: Utilities for setting key bindings

-- NOTE: (For future me)
-- The following is a ton of boilerplate for a problem I don't currently have.
-- I wanted to create a system where I could call to have my keymap(s) loaded during
-- neovim load, or sometime arbitrarily during normal operation and observe the
-- same effect. (Notably that the map is loaded at or after VimEnter so that it
-- do not clash with runtime binds such as `gcc`.)
-- The solution for this was to create a queue structure, and any keymap would be
-- loaded by enqueuing and dequeuing its name. Thus, we can "wait" for VimEnter
-- by skipping all dequeue operations, and then running them all during the autocommand.

local _nvimready = false
local _loadedmaps = {}
local _loadqueue = {
	__start = 1,
	__end = 1, -- Index of next insertion
}
function _loadqueue:insert(mapname)
	-- TODO: Consider adding a check if the name already exists
	if (type(mapname) == "string") and (#mapname > 0) then
		local idx = self.__end
		self[idx] = mapname
		self.__end = idx + 1
	else
		error("Bad keymap name requested")
	end
end
function _loadqueue:process(_overwrite)
	if not _nvimready then
		-- Do nothing; Load deferred to the autocommand
		-- Not refactor-proof, this assumes the autocommand is created below!
		return
	end

	local dir = vim.g.mappath
		or (vim.fn.stdpath("config") .. "/keymap/")

	local idx = self.__start
	if idx == self.__end then
		-- Nothing in the queue
		return
	end

	local mapname = self[idx]
	if not mapname then
		error("Keymap load queue has a hole: developer error")
	end

	local mapobj = _loadedmaps[mapname]
	if mapobj then
		-- Keymap already loaded
		-- TODO: I added this check with the intent of preventing recursion
		-- if a keymap mistakenly calls binds.loadmap() inside of its own load function,
		-- but the current form will prevent me from reloading a keymap over top
		-- another, so this could use some massaging.
	else
		local keymap, err = loadfile(dir .. mapname .. ".lua")
		if keymap then
			mapobj, err = keymap()
		end
		if mapobj then
			if (_overwrite == false) then
				mapobj._overwrite = false
			end
			_loadedmaps[mapname:lower()] = mapobj
			_, err = pcall(mapobj._activate, mapobj)
		end
	end

	-- Update the queue state
	self[idx] = nil
	self.__start = idx + 1

	if err then
		vim.notify("Failed to load keymap: " .. mapname, vim.log.levels.WARN)
	end
	-- Commented code would let the parent loop continue even if one map fails
	return mapobj -- or {}
end
function _loadqueue:clear()
	for idx = self.__start, self.__end do
		self[idx] = nil
	end
	self.__start = self.__end
end
vim.api.nvim_create_autocmd("VimEnter", {
	desc = "Load user keymaps after Neovim defaults (fix for gcc clash)",
	once = true,
	callback = function()
		_nvimready = true

		-- Load all keymaps waiting in the queue
		while _loadqueue:process() do end
	end,
})

-- Enqueue the default map for initialization
-- NOTE: This could change later, but right now it makes my root init.lua pretty
_loadqueue:insert("defaults")


-- >> MODULE <<
local module = {
	-- >>> Enumerations for vim modes
	NORMAL = "n", -- Normal mode
	INSERT = "i", -- Insert mode
	VISUAL = "v", -- Visual mode
	OBJECT = "o", -- Operator-pending mode
	-- Non-standard (but commonly bound) aggregates
	EDITOR = { "n", "v" }, -- "Editor" modes
	ACTIVE = { "n", "i", "v" }, -- "Interactive" modes
	MOTION = "", -- "Motion" modes (normal, visual, select, and operator-pending)
	GLOBAL = { "n", "i", "c", "v", "o", "t", "l" }, -- All supported modes (dangerous)
	-- <<< See | map-table |
}

local _defaults = {
	noremap = true,
	silent = true,
}
-- Generates an options tables
-- Available options not enumerated here: nowait, buffer, script, unique
-- > :h map-arguments
module.options = function(description, expression)
	if not (description or expression) then
		-- TODO: Since this is a reference, consider using metatables to make
		-- > this table immutable
		return _defaults
	end

	local _options = {
		noremap = true,
		silent = true,
	}
	if type(description) == "string" then
		_options.desc = description
	end
	if expression then
		_options.expression = true
	end
end

-- Wrapper function to cleanup calls to vim.keymap.set()
module.set = function(mode, key, action, _opts)
	local opts = _opts or _defaults
	vim.keymap.set(mode, key, action, opts)
end

-- Wrapper function to cleanup binding to no-op
module.disable = function(mode, key)
	vim.keymap.set(mode, key, "<nop>", _defaults)
end

-- Wrapper function to reset a key to its default binding
-- NOTE: Will fail for binds set in the runtime, such as `gcc`
module.reset = function(mode, key)
	vim.keymap.del(mode, key, _defaults)
end

-- Keymap API metatable
local _kmapi = {
	__index = {
		-- Enqueue a keymap to be loaded (and trigger if ready)
		-- @overwrite - false: only set unset binds; true: overwrite all binds
		load = function(self, _overwrite)
			_loadqueue:insert(self._name)
			_loadqueue:process(_overwrite)
		end,

		-- Set the binds in the editor
		-- TODO: If maps are to be logged/stored, this is probably the place to do it
		-- Else, it could be done in the bind function, if that is left as is (not a bind table)
		_activate = function(self)
			-- TODO: Fallback behavior until a bind table format is designed
			if type(self._bind) == "function" then
				self._bind(self._overwrite)
			else
				print("TODO: Load keymap from a table of binds")
			end
		end,

		-- TODO: Support a "reset" of a single key to what is defined by this map
		-- (depends on moving the map into a table)
		_reset = function(self)
			-- For consideration as well, it may be preferable to make this a
			-- "global" reset, and move the keymap.set logic from _activate() into here
			-- _activate() would then become copying the keymap table reference here,
			-- where it would be called by this _reset() command
			-- (Although as I'm writing that, _reset() would not need anything stored
			-- here, since it would be scoped to the table already via self)
			print("TODO: Reset a bind to the value given by this map")
		end,
	},
}
-- "Hidden" function to set the API metatable for a given keymap
module._register = function(keymap)
	return setmetatable(keymap, _kmapi)
end

return module
