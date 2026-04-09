-- >>> binds.lua: Utilities for setting key bindings

-- For details, see: cheatsheet.svg
-- vim.o.langmap is another compelling option for accomplishing this, but it would
-- > work best only with key swaps. For any other purpose, the effects are dubious

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

	-- Allow functions to be included for the g@l operator
	_closures = setmetatable({}, {
		__index = function(self, key)
			local idx = key:match("^_(%d+)$")
			if idx then
				return self[tonumber(idx)]
			end
		end
	})
}

local _defaults = {
	noremap = true,
	silent = true,
}
-- Generates an options tables
-- Available options not enumerated here: nowait, buffer, script, unique
-- > :h map-arguments
function module.options(description, expression)
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
		_options.expr = true
	end
	return _options
end

-- Map a function to a g@l expression
-- @func - string (function in lua/buffer.action) or closure
-- NOTE: Using the function option has the potential to leak resources if
-- rebinding on the fly, making new calls to this function
-- > To remedy this, the returned closure should be stored for reuse
function module.wrap(func, _opts)
	local operator
	if type(func) == "function" then
		-- Closure - Save a reference locally
		-- Usage: module.set(module.NORMAL, "<C-d>", module.wrap(function() print("hello world") end))

		-- TODO: I might be able to fix the leak by a complicated proxy table system
		-- Here, the main table would use the function as the key (which should match
		-- the address) and the second table tracks its name index. When wrapping, use
		-- the address of the function as the key with the index the corresponding
		-- value. The proxy table maps the opposite, so that each function can be
		-- called via an index, which is the name saved to the closure table.
		-- > Not implemented because this config does not use this yet

		table.insert(module._closures, func)

		-- Update func for the returned options table
		func = tostring(#module._closures)
		operator = "v:lua.require'editor.binds'._closures._" .. func

	elseif type(func) == "string" then
		-- Function name - Pull in from lua buffer operations (actions)
		local closure = require("buffer").action[func] -- Verify the function exists
		if not closure then
			error("Buffer action `" .. tostring(funcstr) .. "` does not exist")
		end
		operator = "v:lua.require'buffer'.action." .. func

	else
		error("Cannot wrap nil function for keymap")
	end

	local wrapfunc = function()
		vim.go.operatorfunc = operator
		return "g@l"
	end

	if _opts == false then
		-- Let the bind specify the options
		return wrapfunc
	elseif type(_opts) == "table" then
		-- If options provided, ensure expression is set to true
		_opts.expr = true
		return wrapfunc, _opts
	else
		-- Default to tacking on expression options for convenience
		return wrapfunc, module.options(func .. " expression", true)
	end
end

-- Wrapper function to cleanup calls to vim.keymap.set()
function module.set(mode, key, action, _opts)
	local opts = _opts or _defaults
	vim.keymap.set(mode, key, action, opts)
end

-- Wrapper function to set a leader command (mostly used by plugins)
function module.command(key, command)
	if (type(key) ~= "string") or (#key == 0) then
		error("Cannot bind command with invalid key sequence")
	end
	vim.keymap.set(module.NORMAL, "<leader>" .. key, "<cmd>" .. command .. "<cr>", _defaults)
end

-- Wrapper function to cleanup binding to no-op
function module.disable(mode, key)
	vim.keymap.set(mode, key, "<nop>", _defaults)
end

-- Wrapper function to reset a key to its default binding
-- NOTE: Will fail for binds set in the runtime, such as `gcc`
function module.reset(mode, key)
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

		-- Currently just a module debugging table
		-- (I'm trying some module/metatable stuff for the first time)
		show = function(self)
			print("TODO: Show keymap")
		end,

		-- Set the binds in the editor
		-- TODO: If maps are to be logged/stored, this is probably the place to do it
		-- Else, it could be done in the bind function, if that is left as is (not a bind table)
		_activate = function(self)
			-- TODO: Fallback behavior until a bind table format is designed
			if type(self._bind) == "function" then
				self:_bind()
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
