-- Commenting submodule for buffer manipulation

-- This file is mostly a recreation of _comment.lua from the runtime
-- > /usr/share/nvim/runtime/lua/vim/_comment.lua

-- The reason the functions have been copied here is to introduce some custom
-- > commenting functionality, notably the "uncomment all" keymap (xC)
-- > The runtime provides many useful comment utilities that are not exposed as
-- > part of the _comment.lua api, thus requiring some silly workaround like this

-- Get the raw comment string from treesitter, if available
-- > Taken from runtime, get_commentstring
local getTreesitterCommentString = function(cursor)
	local commentstr = nil
	local parser = vim.treesitter.get_parser(0, '', { error = false })
	if not parser then
		-- Treesitter not active in this buffer
		return -- (commentstr = nil)
	end

	-- Cursor position
	local pos = {
		row = cursor[1] - 1,
		col = cursor[2]
	}

	-- Try to get 'commentstring' associated with local tree-sitter language metadata
	-- > This is useful for injected languages (like markdown with code blocks)
	-- > Traverse backwards to prefer narrower captures
	local captures = vim.treesitter.get_captures_at_pos(0, pos.row, pos.col)
	for i = #captures, 1, -1 do
		local id, metadata = captures[i].id, captures[i].metadata
		local commentstr = metadata['bo.commentstring'] or metadata[id] and metadata[id]['bo.commentstring']

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
			local cur_cs = vim.filetype.get_option(ft, 'commentstring')
			if cur_cs ~= '' and level > res_level then
				commentstr = cur_cs
			end
		end

		for _, child_lang_tree in pairs(lang_tree:children()) do
			traverse(child_lang_tree, level + 1)
		end
	end
	traverse(ts_parser, 1)

	-- Finally, return what we have (if anything)
	return commentstr
end

-- Get parsed 'commentstring' at cursor
--- @param ref_position integer[]
--- @return Table: { right: str, left: str }
-- > Taken directly from the runtime (reorg of get_comment_parts)
local parseCommentString = function(ref_position)
	local commentstr = getTreesitterCommentString() or vim.bo.commentstring

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
		return { left = left, right = right }
	end

	-- Fail
	-- TODO: Consider defaulting to nil for no-op
	return { left = "", right = "" }
end

-- Split a line and determine its properties
-- > New function that merges many elements from runtime
local getLineInfo = function(line, cstr)
	-- Input validation
	if not line or (type(line) ~= "string") then
		return -- nil
	end

	local linetbl = {
		empty = true,
		commented = false,
		indent = 0,
		contents = nil
	}

	-- Check if the line is empty
	if line:find("^%s*$") == nil then
		return linetbl
	end

	 
end

local module = {
	parse = parseCommentString,
	split = getLineInfo,
	-- check toggle/uncomment helper (mode check?)
	comment = commentLine, -- action or closure generator?
}


--==-- OLD STUFF FROM COMMENT PLUGIN... --==--

-- Toggles the current line and `count` following lines (add comment if mixed)
local commentLineOld = function()
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

--==-- ^^^OLD STUFF FROM COMMENT PLUGIN --==--

return module
