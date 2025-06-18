-- Commenting submodule for buffer manipulation

-- This file is mostly a recreation of _comment.lua from the runtime but with extra stuff
-- > /usr/share/nvim/runtime/lua/vim/_comment.lua
-- The reason the functions have been copied here is to introduce some custom functionality
-- > notably the "uncomment all" keymap (xC) to portions of logic that are not otherwise
-- > exposed via any form of API, demanding multiplicity as a workaround


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
-- TODO: Comment parts padding! Make the trailing whitespace optional in the match
-- > Likely modify this function to omit whitespace and then modify extractContents
-- > to handle padding whitespace intuitively (maybe matching one %s char?)
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
local extractLineContents = function(line, prefix, suffix)
	-- Validate line input
	if not line or (type(line) ~= "string") then
		return -- nil
	end

	-- Prepare the line into table with defaults
	-- TODO (tomorrow) refactor this to only use index and move the extraction logic
	-- > This will require we save a reference to the original line, which should be faster
	local _, indent = line:find("^%s*")
	local length = line:len()
	local info = {
		line = line,                -- Reference to original line for slicing
		commented = false,          -- Boolean: True if prefix and suffix are matched
		empty = (indent == length), -- Boolean: True if the line contains only whitespace
		indent = indent,            -- Depth (aka end index of indent)
		start = indent + 1,         -- Beginning of line contents (no whitespace, no comment syntax)
		final = length,             -- End of line contents
		prefix = 0,                 -- Location of comment prefix (0 if not present)
		suffix = 0,                 -- Location of comment suffix (0 if not present)
	}
	-- Check if line is empty (whitespace only)
	if info.empty then
		return info
	end
	local offset = info.start

	-- Find the comment prefix
	local _prefix = vim.pesc(prefix)
	local prefixStart, prefixEnd = line:find(_prefix, offset)
	if prefixStart then
		info.prefix = prefixStart
		if prefixStart == offset then
			-- Comment was found at the start of the line
			-- > NOTE: Don't match against ^<prefix> for reuse with textobjects
			info.commented = true -- To be reverted if suffix is defined but not matched
		end
		offset = prefixEnd + 1
		info.start = offset
	end

	-- Find the comment suffix
	if suffix then
		local _suffix = vim.pesc(suffix)
		local suffixStart = nil
		local suffixEnd = offset - 1 -- Correction for while loop

		while suffixEnd ~= length do
			-- When not at EOL, continue matching */ so that in the following line:
			-- >	/* int main(/* int argc */) */
			-- The second */ would be matched and not left hanging
			local s, e = line:find(_suffix, suffixEnd + 1)
			if not s then
				break
			end
			suffixStart = s
			suffixEnd = e
		end

		if suffixStart then
			info.suffix = suffixStart
			info.final = suffixStart - 1
			-- The line should only count as commented if the suffix is at EOL
			info.commented = info.commented and (suffixEnd == length)

			-- TODO: Consider updating info.empty if there is no content
			-- > AKA prefixEnd == (suffixStart + 1) -- /*  */
		else
			info.commented = false
		end
	end

	return info
end

-- Helper function for commenting a line
-- Suffix should be normalized to a string
local _commentLineOperator = function(force, prefix, suffix)
	local emptyString = prefix .. suffix
	local suffixLen = suffix:len()
	return force and function(info)
		-- Force mode inserts a comment string regardless of the current state
		local text = {
			info.line:sub(1, info.indent),
			prefix,
			info.line:sub(info.indent + 1),
			suffix
		}
		return table.concat(text)

	end or function(info)
		-- Empty/whitespace only line should remain untouched (unless we force a comment)
		if info.empty then
			return info.line
		end

		-- Only insert the missing comment string parts
		local text
		if (info.prefix - info.indent) == 1 then
			-- Comment prefix already present
			text = { info.line }
		else
			-- Add the comment prefix
			text = {
				info.line:sub(1, info.indent),
				prefix,
				info.line:sub(info.start)
			}
		end
		if (suffixLen > 0) then
			print(info.suffix, info.line:len())
			if ((info.suffix + suffixLen - 1) ~= info.line:len()) then
				-- No suffix was present at EOL
				table.insert(text, suffix)
			end
		end
		return table.concat(text)
	end
end

-- Helper function for uncommenting a line
-- Suffix should be normalized to a string
local _uncommentLineOperator = function(force, prefix, suffix)
	local _prefix
	local _suffix

	if force then
		_prefix = vim.pesc(prefix)
		_suffix = vim.pesc(suffix)
	end

	return force and function(info)
		-- Force mode matches all comment parts and removes all of then
		local text = info.line:gsub(_prefix, "")
		if suffix:len() > 0 then
			text = text:gsub(_suffix, "")
		end
		return text

	end or function(info)
		if info.commented then
			local text = {
				info.line:sub(1, info.indent),
				info.line:sub(info.start, info.final)
			}
			return table.concat(text)
		end
		return info.line
	end
end

-- Returns a closure that can be used to comment or uncomment code
-- The closure expects a line contents table as input
local createOperator = function(comment, force, prefix, suffix)
	suffix = suffix or ""
	if comment then
		return _commentLineOperator(force, prefix, suffix)
	else
		return _uncommentLineOperator(force, prefix, suffix)
	end
end

-- Rough idea for comment block
-- This would mostly entail a comment operator function with different logic that would
-- be more friendly for multiline comments. Instead of working on a linewise basis, it may
-- search backwards and forwards from the cursor looking for either end of a multiline
-- comment. From here, it can guess if we are currently commented or not. If so, uncomment
-- the selection. If not, comment the selection. If we cross commented/uncommented sections,
-- then extend the commented portion through the uncommented portion.

-- TODO: For text object mode...
-- Well, text object mode itself
-- But also, right now a string that happens to contain the comment string will get matched
-- as a comment all the same. It is probably worthwhile to offer some sort of trivial string-
-- detection, or perhaps query the treesitter AST to check if the text object we think is a
-- comment actually gets parsed as a comment, too
-- '...ic' for "inner comment" aka contents minus comment syntax
-- '...oc' for "outer comment" aka the entire comment (syntax and content)

local module = {
	selection = getSelectionRange,
	pattern = extractCommentParts,
	process = extractLineContents,
	operator = createOperator,
}

return module
