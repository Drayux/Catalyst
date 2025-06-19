-- >>> keymap.lua: Utilities for setting keybinds

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
module.bind = function(mode, key, action, _opts)
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

return module
