-- Module for buffer manipulation operations

-- Synopsis
--- Custom keymaps are cool but frusteratingly compilcated. By some luck, most
--- of my configuration was built without running into the following issue:
--- Expression keymaps cannot call lua to modify buffers directly. From a
--- comment included in neovim's runtime:
--- > TODO: move to _defaults.lua once it is possible to assign a Lua function to options #25672
--- Thus the purpose of this module is akin to that of _bufs.lua in the runtime
--- where it can be required and the subsequent lua can be ran

-- To-Do (TODO)
--- There are some functions that could stand to be moved here that were made
--- prior to this discovery. Notably anything where the workaround was to define
--- a command and then call said command (the themer-related commands come to
--- mind, window picker, etc.)
--- I'd particularly like to prioritize the buffer manipulation commands:
---  > indent
---  > move line
--- if refactoring them might seem prudent


-- The neovim API makes it unforunately convenient to use ugly boolean parameter
-- functions, so define some constants to clear up what they are doing
local ABOVE = true
local BELOW = false
local UP = -1
local DOWN = 1

-- Expression for adding empty lines above or below the cursor 
-- > Stolen directly from nvim runtime: `/usr/share/nvim/runtime/lua/vim/_buf.lua`
-- > Copied here so that my key remap does not break if neovim updates
local insertLine = function(location)
	local offset = location and 1 or 0
	local repeated = vim.fn["repeat"]({ '' }, vim.v.count1)
	local linenr = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, linenr - offset, linenr - offset, true, repeated)
end

local moveLine = function(direction)
	local distance = direction * vim.v.count1
	local final

	if (distance > 0) then
		-- Without plus, vim uses absolute line number
		final = "+" .. tostring(distance)
	else
		-- move(-1) resolves to the current line, so offset by 1
		final = tostring(distance - 1)
	end
	vim.cmd.move(final)
end

local commands = {
	insertLineAbove = function() insertLine(ABOVE) end,
	insertLineBelow = function() insertLine(BELOW) end,
	moveLineUp = function() moveLine(UP) end,
	moveLineDown = function() moveLine(DOWN) end,
}

return commands
