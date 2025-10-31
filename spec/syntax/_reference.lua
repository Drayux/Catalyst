-- TODO: Super duper trivial implementation
-- In short, I do not yet know what I will need from such a system, so this is
-- really meant to be the basics

local spec = {
	-- Comment character per this syntax
	comment = "#",

	-- Lua code escape sequence (for runtime processing/generation)
	escape = "<<<LUA>>>",

	-- Sequence used to label our section
	marker = {
		"BEGIN CATALYST SECTION",
		"END CATALYST SECTION"
	},

	-- How to parse the file
	-- File table is the file read into a table, split by newline
	parse = function(spec, file_tbl)
		-- TODO: Really not sure about implementing this one
		-- The idea would be a quick and dirty syntax parser for simple config
		-- formats (think YAML, pipewire, etc....not something interpreted like
		-- bash, although even that I could hook up to a sandboxed interpreter
		-- and run it and then check say, variables...)

		-- Alas, the goal would be to create more formal way to search for
		-- specific configuration sections or values for the following functions
	end,

	-- Closure to look for the "catalyst config section" block
	-- (Or some other indication of being installed)
	-- Return { start_line, end_line } or nil
	-- File table is the file read into a table, split by newline
	check = function(spec, file_tbl)
		-- TODO
		-- If not a function but a table, then try to match that table sequence
	end,

	-- Where to put the generated section
	-- Intended to be ran ONLY if check returns nil
	-- File table is the file read into a table, split by newline
	placement = function(spec, file_tbl)
		-- TODO: Thinking a couple options here...
		-- > Could be a "what to search for" type of function (return a line number?)
		-- > Else could be a simple "top of file/bottom of file"
	end,
}

return spec
