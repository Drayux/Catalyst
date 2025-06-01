-- >>> init.lua: Neovim top-level config

-- Configuration dependencies (all soft)
-- > wl-clipboard (provider of choice, any will do though)
-- > Git CLI (for neovim plugins)
-- > A "nerd" font (for developer glyphs)
-- > Ripgrep (for fuzzy search)


-- >> ENVIRONMENT <<
-- Override package path and runtime path
-- Package path defines a file search order for the lua runtime
-- Runtime path does...something??
-- ... (todo, put layout.lua and editor.lua in /etc/ and symlink)

-- Load features depending on runtime env
-- > (TODO) Pager mode : LESS
--  - keymaps
-- > Root (GUI or TTY) : ROOT
--  - keymaps
--  - global config
-- > User account (TTY) : TTY
--  - keymaps
--  - global config
--  - event hooks
--  - user commands
--  - plugins (limited)
-- > User account + GUI : GUI
--  - keymaps
--  - global config
--  - event hooks
--  - user commands
--  - plugins
--  - theme
local mode = "LESS"
if (os.execute("exit $(id -u)") ~= 0) then
	-- Non-superuser, determine if TTY or emulator
	local term = vim.env.TERM
		or "unknown"
	if (term == "linux") then
		-- TTY
		mode = "TTY"
	else
		mode = "GUI"
	end
else
	mode = "ROOT"
end
vim.g.envmode = (mode == "GUI" and 4)
	or (mode == "TTY" and 3)
	or (mode == "LESS" and 1)
	or 0

-- Insert preferred lua search paths to package.path
-- > This path is used by lua when a module called with require()
local packagePaths = {}
local insertAfter = -1 -- Hold the location of `./?.lua`
for path in package.path:gmatch("([^;]+)") do
	if (insertAfter < 0) then
		if (path == "./?.lua") then
			insertAfter = 1 - insertAfter
		else
			insertAfter = insertAfter - 1
		end
	end
	table.insert(packagePaths, path)
end

-- NOTE: Inserting both paths into one line
-- > We don't need to search for these so save the cycles
if (mode == "ROOT") then
	table.insert(packagePaths, insertAfter,
		"/etc/nvim/config/lua/?.lua;/etc/nvim/config/lua/?/init.lua")
else
	local baseDir = vim.fn.stdpath("config")
	table.insert(packagePaths, insertAfter,
		baseDir .. "/?.lua;"
		.. baseDir .. "/?/init.lua")
end
package.path = table.concat(packagePaths, ";")

-- Editor settings differ across devices
-- TODO: If a known hostname exists, no need to use the heuristic
-- > Use a heuristic to make our best guess
local desktopFavor = 0
local hostname = vim.fn.system("hostname")
if (hostname and #hostname > 0) then
	if (hostname == "catalyst")
		or (hostname == "chitin")
		or (hostname == "aether")
	then
		desktopFavor = desktopFavor + 2
	elseif hostname:match("LX%-.+") then
		desktopFavor = desktopFavor - 1
	end
	-- Save the hostname to the environment for later reference
	vim.env.HOST = hostname

-- For now, only one check should be necessary
elseif vim.env.HOME then
	subdir = vim.env.HOME:match("/home(.*)")
	if subdir and subdir:match("/.+") then
		desktopFavor = desktopFavor - 1
	else
		desktopFavor = desktopFavor + 1
	end
end

-- A non-negative result indicates a personal device
vim.g.host = (desktopFavor < 0) and "WORK"
	or "HOME"


-- >> CONFIG <<
pcall(require, "options") -- Editor behavior (global options)
pcall(require, "layout") -- Custom (completely sane) key binds

-- Super-user config stops here
-- > TODO: Still not sure how I want to link the init.lua
if (nvimMode == "ROOT") then
	return
end


-- >> FUNCTIONALITY <<
pcall(require, "plugin") -- Lazy plugin loader
pcall(require, "events") -- Extra user commands/events

-- The following are not yet implemented at all, this idea may be replaced sometime
-- if (nvimMode == "GUI") then
	-- pcall(require, "gui") -- Load fancy UI plugins and features
	-- pcall(require, "session") -- Custom session management plugin (WIP)
-- end
