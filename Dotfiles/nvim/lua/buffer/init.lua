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
local COMMENT = 1
local UNCOMMENT = -1
local TOGGLE = 0

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

local commentLine = function(mode)
	-- NOTE: To call the classic "gcc" do:
	-- require("vim._comment").operator(0) -- Param doesn't matter, just non-nil

	-- TODO: Consider feature to add a comment to an empty line if it is the only line selected

	-- Commenting logic is broken down into a sub-module
	local commentUtils = require("buffer.comment")

	local selection = commentUtils.selection()
	-- print(selection.start[1], selection.start[2], selection.final[1], selection.final[2])
	if not selection then
		-- We might get here with an empty text object
		-- > *Consider running 'ytd' on the above line*
		return
	end

	-- Try to get the comment string, quit early if none
	-- NOTE: The runtime has something to do with a reference position, and I
	-- > am not sure what situation this becomes helpful: perhaps 'gcgc' ?
	local commentParts = commentUtils.parts(selection.start)
	if not commentParts then
		return
	end

	-- Process all selected lines to prepare for comment operation
	local force = false -- true
	local lines = vim.api.nvim_buf_get_lines(0, selection.start[1] - 1, selection.final[1], false)
	local parsed = {} -- Use pairs to iterate, not ipairs
	for num, text in pairs(lines) do
		-- local line = commentUtils.process(text, "/%*", "%*/")
		local line = commentUtils.process(text, commentParts.prefix, commentParts.suffix)
		parsed[num] = line

		if (mode == TOGGLE) and (not line.commented) then
			mode = COMMENT
		end
		-- if (mode != UNCOMMENT) and force then
			-- force = line.empty
		-- end
	end

	-- Build and apply the comment operation closure
	-- NOTE: If the commenting mode is still to toggle, then the entire selection was commented
	local operator = commentUtils.operator(mode == COMMENT, force, commentParts.prefix, commentParts.suffix)
	vim._with({ lockmarks = true }, function()
		vim.api.nvim_buf_set_lines(
			0,
			selection.start[1] - 1,
			selection.final[1],
			false,
			vim.tbl_map(operator, parsed)
		)
	end)
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

local module = {
	expressions = {
		insertLineAbove = function() insertLine(ABOVE) end,
		insertLineBelow = function() insertLine(BELOW) end,
		moveLineUp = function() moveLine(UP) end,
		moveLineDown = function() moveLine(DOWN) end,
		commentLine = function() commentLine(TOGGLE) end,
		uncommentLine = function() commentLine(UNCOMMENT) end,
		-- commentBlock = commentBlock, -- (TODO)
	},
	commands = {
		closeBuffer = closeBuffer,
	}
}

return module
