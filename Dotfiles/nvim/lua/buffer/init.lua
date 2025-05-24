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
local TOGGLE = true
local UNCOMMENT = false

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

local commentLine = function(toggle)
	require("vim._comment").operator(0) -- Param doesn't matter, just non-nil
end

-- Uncomment a multiline comment if exists, else create a new one from the motion
local commentBlock = function()
	local _, api = pcall(require, "Comment.api")
	if not api then
		vim.notify("Comment.nvim is not installed, update configs to use 'gcc' instead", vim.log.levels.ERROR)
		return
	end

	-- local count = (vim.v.count > 0) and vim.v.count or 1
	api.toggle.blockwise()

	-- block commenting ideas (TODO)
	-- normal mode xd -> Take o-pending and always comment that much
	-- normal mode xD -> Uncomment entire surrounding block
	-- visual modes follow suit
	-- Visual mode uncomment (xD) should ignore visual block and uncomment
	-- > at cursor??

	-- TODO: What to do if toggling linewise inside of a block?
end

local closeBuffer = function(buffer, bang)
	vim.notify("TODO: buffers.closeBuffers (target was " .. tostring(buffer) .. ")", vim.log.levels.WARN)

	-- Neovim will close the window if we close the buffer that it
	-- > currently has open; step one is to check what state we're in
	local current = vim.api.nvim_get_current_buf()
	-- print(current)

	-- TODO: Something to do with iterating all the open windows to check
	-- > if the target buffer is open in any. If so, create a new (:enew)
	-- > buffer and swap each open window to it (or maybe just do :bp??)
	-- > ALTERNATIVELY, we can just check if this is the case and warn
	-- > (this might do away with the current value, as it would be relevant
	-- > to each window anyway....although I wager we keep the above code)

	-- > TODO: For some reason, using the BANG causes the window to close in
	-- > the same conditions that not using the bang would not
	-- (old todo, not sure if still relevant)

	-- The following was the previous solution:
	-- sp : Split screen
	-- LualineBuffersJump : Jump to the previous buffer
	-- bd!(?) : Delete current buffer (including the split, so the new one takes its place)
	--	^^Original split has the active buffer before deleting
	-- if not target then return
	-- elseif target > 0 then vim.cmd("bp")
	-- end
	-- vim.cmd("sp")
	-- vim.cmd("LualineBuffersJump " .. tostring(idx))
	-- vim.cmd("bd" .. (argtable.bang and "!" or ""))
end

local commands = {
	insertLineAbove = function() insertLine(ABOVE) end,
	insertLineBelow = function() insertLine(BELOW) end,
	moveLineUp = function() moveLine(UP) end,
	moveLineDown = function() moveLine(DOWN) end,
	commentLine = function() commentLine(TOGGLE) end,
	-- uncommentLine = uncommentLine,
	-- commentBlock = commentBlock,
	closeBuffer = closeBuffer,
}

return commands
