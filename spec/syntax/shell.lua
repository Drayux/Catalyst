-- POSIX shell script syntax spec (sh, bash, zsh)
local spec = {
	comment = "#",
	escape = "<<<LUA>>>",
	marker = {
		"BEGIN CATALYST SECTION",
		"END CATALYST SECTION"
	},

	-- Closure to look for the "catalyst config section" block
	-- (Or some other indication of being installed)
	-- TODO: Save file length to file_tbl._length
	check = function(spec, file_tbl)
		local start_query
		local end_query

		if type(spec.marker) == "table" then
			start_query = string.format("%s >>> %s", spec.comment, spec.marker[1])
			end_query = string.format("%s >>> %s", spec.comment, spec.marker[2] or spec.marker[1])
		else
			start_query = string.format("%s >>> %s", spec.comment, spec.marker)
			end_query = start_query
		end

		local start_line
		local end_line
		local pattern = "^" .. start_query .. "$"

		for line_num, line_str in ipairs(file_tbl) do
			if line_str:match(pattern) then
				if not start_line then
					start_line = line_num
					pattern = "^" .. end_query .. "$"
				else
					end_line = line_num
					-- Keep looping to find the widest range on the chance that
					-- there is a corrupt format
				end
			end
		end
		-- Fixup missing end block
		-- (TODO: Not sure if this should be the intended behavior)
		if start_line and not end_line then
			-- Also TODO make sure this gets the correct length always
			end_line = file_tbl._length or #file_tbl
		end

		if (start_line > 0) and (end_line > start_line) then
			return { start_line, end_line }
		-- else return nil
		end
	end,

	-- Where to put the generated section
	-- TODO: Consider some form of whitespace QOL as well
	placement = function(spec, file_tbl)
		-- Bottom of file for shell
		-- TODO: make sure this gets the correct length always
		return (file_tbl._length or #file_tbl) + 1
	end,
}

return spec
