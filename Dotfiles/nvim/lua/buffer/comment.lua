-- Commenting submodule for buffer manipulation

-- This file is mostly a recreation of _comment.lua from the runtime
-- > /usr/share/nvim/runtime/lua/vim/_comment.lua

-- The reason the functions have been copied here is to introduce some custom
-- > commenting functionality, notably the "uncomment all" keymap (xC)
-- > The runtime provides many useful comment utilities that are not exposed as
-- > part of the _comment.lua api, thus requiring a silly workaround like this

-- NOTE: As an advanced feature, supporting block comments may be deceptively difficult
-- > This entails storing the block comment string and the line comment string
-- > After that, determining if a comment "block" exists is not so trivial, as the
-- > beginning of the line cannot simply be checked for the pattern
-- > Thus, it may be necessary to parse the entire file for this functionality


-- Determine the target range of the comment using the API
-- > Taken from runtime: operator and toggle_lines
-- > return: Table (integer[], integer[]) (start coordinate, end coordinate)
-- > ^^ "range" type is a named table of two "location" types
local getSelectionRange = function()
	-- Compute target range
	local mark_from, mark_to = "'[", "']"
	local lnum_from, col_from = vim.fn.line(mark_from), vim.fn.col(mark_from)
	local lnum_to, col_to = vim.fn.line(mark_to), vim.fn.col(mark_to)

	-- Do nothing if "from" mark is after "to" (like in empty textobject)
	if (lnum_from > lnum_to) or (lnum_from == lnum_to and col_from > col_to) then
		return -- nil
	end

	return {
		start = { lnum_from, col_from },
		final = { lnum_to, col_to } -- Can't easily use "end" because lua keyword
	}
end

-- Get the raw comment string from treesitter, if available
-- > Taken from runtime, get_commentstring
local _tsCommentString = function(location)
	local commentstr = nil
	local parser = vim.treesitter.get_parser(0, "", { error = false })
	if not parser then
		-- Treesitter not active in this buffer
		return -- (commentstr = nil)
	end

	-- Cursor position
	local pos = {
		row = location[1] - 1,
		col = location[2]
	}

	-- Try to get 'commentstring' associated with local tree-sitter language metadata
	-- > This is useful for injected languages (like markdown with code blocks)
	-- > Traverse backwards to prefer narrower captures
	local captures = vim.treesitter.get_captures_at_pos(0, pos.row, pos.col)
	for i = #captures, 1, -1 do
		local id, metadata = captures[i].id, captures[i].metadata
		local commentstr = metadata["bo.commentstring"] or metadata[id] and metadata[id]["bo.commentstring"]

		if commentstr then
			return commentstr
		end
	end

	-- Otherwise get 'commentstring' from the deepest LanguageTree which both contains
	-- > reference range and has valid 'commentstring'
	local res_level = 0
	local function traverse(lang_tree, level)
		if not lang_tree:contains({ pos.row, pos.col, pos.row, pos.col + 1 }) then
			return
		end

		local lang = lang_tree:lang()
		local filetypes = vim.treesitter.language.get_filetypes(lang)
		for _, ft in ipairs(filetypes) do
			local cur_cs = vim.filetype.get_option(ft, "commentstring")
			if cur_cs ~= '' and level > res_level then
				commentstr = cur_cs
			end
		end

		for _, child_lang_tree in pairs(lang_tree:children()) do
			traverse(child_lang_tree, level + 1)
		end
	end
	traverse(parser, 1)

	-- Finally, return what we have (if anything)
	return commentstr
end

-- Get parsed 'commentstring' at cursor
--- @param location integer[]
--- @return Table: { right: str, left: str }
-- > Taken directly from the runtime (reorg of get_comment_parts)
local extractCommentParts = function(location)
	local commentstr = vim.bo.commentstring or _tsCommentString(location)

	-- Verify comment string is defined
	if commentstr == nil or commentstr == "" then
		vim.api.nvim_echo({ { "Option 'commentstring' is empty.", "WarningMsg" } }, true, {})

	-- Validate the defined comment string
	elseif not (type(commentstr) == "string" and commentstr:find("%%s") ~= nil) then
		error(vim.inspect(cs) .. " is not a valid 'commentstring'.")

	-- Success
	else
		-- Structure of 'commentstring': <left part> <%s> <right part>
		local left, right = commentstr:match('^(.-)%%s(.-)$')
		if left and left:len() == 0 then
			left = nil
		end
		if right and right:len() == 0 then
			right = nil
		end

		-- TODO: Clean up prefix/suffix whitespace for more inclusive comment matching
		-- Consider: C comments: /*code and //code should be fine to uncomment
		-- But maybe a triple dash in lua... ---comment, should we leave in the - ?

		return { prefix = left, suffix = right }
	end

	-- Getting here is a failure, return nil
end

-- Split a line and determine its properties
-- > New function that merges many elements from runtime
-- BUG: Already commented lines do not have their comments doubled-up
-- > because the content is extracted anyway...however this may become nice to have?
-- > Perhaps the force option should be necessary to double-up (triple-up, etc.)? (TODO)
local extractLineContents = function(line, prefix, suffix)
	-- Validate line input
	if not line or (type(line) ~= "string") then
		return -- nil
	end

	-- Prepare the line into table with defaults
	-- TODO (tomorrow) refactor this to only use index and move the extraction logic
	-- > This will require we save a reference to the original line, which should be faster
	local _, indent, whitespace = line:find("^(%s*)")
	local info = {
		commented = false,   -- Boolean: True if prefix and suffix are matched
		indent = whitespace, -- Depth (aka end index of indent)
		prefix = 0,          -- Location of comment prefix (0 if not present)
		suffix = 0,          -- Location of comment suffix (0 if not present at EOL)
		content = nil,       -- Line contents (excluding whitespace and comment syntax)
	}
	-- Check if line is empty (whitespace only)
	if indent == line:len() then
		return info
	end

	-- Find the comment prefix
	local pstart, _, post = line:find("^" .. prefix .. "(.*)", indent + 1)
	if pstart then
		info.prefix = pstart
		info.commented = true -- To be reverted if suffix is defined but not matched
	else
		post = line:sub(indent + 1)
	end

	-- Find the comment suffix
	if suffix then
		local sstart = post:find(suffix .. "%s*$")
		if sstart then
			info.suffix = sstart
			post = post:sub(1, sstart - 1)
		else
			commented = false
		end
	end

	-- Update the final line contents
	info.content = post
	-- print("Line:", "'" .. (post or "<nil>") .. "'")
	return info
end

-- Returns a closure that can be used to comment or uncomment code
-- The closure expects a line contents table as input
local createOperator = function(comment, force, prefix, suffix)
	suffix = suffix or ""

	-- Info is the output type of extractLineContents()
	return function(info)
		-- Empty/whitespace only line should remain untouched (unless we force a comment)
		if not info.content then
			if force and comment then
				return prefix .. suffix
			else
				return info.indent
			end
		end

		-- Perform the comment/uncomment operation
		-- TODO: Consider splitting this into seperate calls to omit the if in the closure
		local line
		if comment then
			line = info.indent .. prefix .. info.content .. suffix
			if force then
				-- If force, then tack on an extra prefix and suffix regardless
				-- of if one is already present
				-- NOTE: In the current state, this might add some unexpected whitespace
				if info.prefix > 0 then
					line = prefix .. line
				end
				if info.suffix > 0 then
					line = line .. suffix
				end
			end
		else
			line = info.indent .. info.content
		end

		return line
	end
end

local module = {
	selection = getSelectionRange,
	parts = extractCommentParts,
	process = extractLineContents,
	operator = createOperator,
}

-- Rough idea for comment block
-- This would mostly entail a comment operator function with different logic that would
-- be more friendly for multiline comments. Instead of working on a linewise basis, it may
-- search backwards and forwards from the cursor looking for either end of a multiline
-- comment. From here, it can guess if we are currently commented or not. If so, uncomment
-- the selection. If not, comment the selection. If we cross commented/uncommented sections,
-- then extend the commented portion through the uncommented portion.


--==-- OLD STUFF FROM COMMENT PLUGIN... --==--

-- Toggles the current line and `count` following lines (add comment if mixed)
local commentLine = function()
	-- local _, utils = pcall(require, "Comment.utils")
	local _, api = pcall(require, "Comment.api")
	if not api then
		vim.notify("Comment.nvim is not installed, update configs to use 'gcc' instead", vim.log.levels.ERROR)
		return
	end

	local mode = vim.api.nvim_get_mode().mode
	if mode == "v"
		or mode == "V"
		-- or mode == "^V"
	then
		-- Comment.nvim API is weird
		-- To toggle a visual selection, first exit visual mode and then call
		-- > the toggle linewise function, specifying "visual mode"
		local escapeKey = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
		vim.api.nvim_feedkeys(escapeKey, "nx", false)
		api.toggle.linewise(mode)
	else
		-- Otherwise, call the toggle linewise function with a number of lines
		local count = (vim.v.count > 0) and vim.v.count or 1
		api.toggle.linewise.count(count)
	end
end

-- Uncomment all targeted lines (toggle prioritizes commenting)
local uncommentLine = function()
	local _, utils = pcall(require, "Comment.utils")
	if not utils then
		vim.notify("Comment.nvim is not installed, update configs to use 'gcc' instead", vim.log.levels.ERROR)
		return
	end

	-- Leave visual mode if active
	local mode = vim.api.nvim_get_mode().mode
	if mode == "v" or mode == "V" then
		local escapeKey = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
		vim.api.nvim_feedkeys(escapeKey, "nx", false)
	else
		mode = "line" -- Convert to Comment.nvim's expected format
	end

	local range = utils.get_region(mode)
	local lines = utils.get_lines(range)

	-- Recreate internal API to construct the "comment context"
	-- > https://github.com/numToStr/Comment.nvim/blob/master/lua/Comment/opfunc.lua#L46
	local left_cs, right_cs = utils.parse_cstr({}, {
		cmode = utils.cmode.uncomment,
		cmotion = "line",
		ctype = utils.ctype.linewise,
		range = range,
	})

	-- Closures to perform the uncomment operation
	-- > Boolean params enable padding (yes please, daddy!)
	local check = utils.is_commented(left_cs, right_cs, true)
	local uncomment = utils.uncommenter(left_cs, right_cs, true)
	local changes = false
	for idx, line in pairs(lines) do
		if check(line) then
			lines[idx] = uncomment(line)
			changes = true
		end
	end

	-- TODO: Currently, nvim_buf_set_lines has a bug where all marks that are
	-- > within the changed content region are cleared
	-- > Currently only in the nightly builds is the vim._with function, which
	-- > should resolve this bug
	-- > https://github.com/neovim/neovim/pull/29168

	-- Call nvim api to update the buffer
	-- vim._with({ lockmarks = true }, function()
		if changes then
			vim.api.nvim_buf_set_lines(0, range.srow - 1, range.erow, false, lines)
		else
			vim.notify("Nothing to uncomment!", vim.log.levels.WARN)
		end
	-- end)

	-- Re-enter previous visual mode selection
	-- if mode == "v" or mode == "V" then
		-- vim.api.nvim_feedkeys("gv", "nx", false)
	-- end
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

--==-- ^^^OLD STUFF FROM COMMENT PLUGIN --==--


return module
