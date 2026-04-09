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

-- Load feature set depending on the mode and run level
-- > (TODO) Pager mode : LESS
--  - keymaps
-- > Root (GUI or TTY) : BASE
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
if (vim.fn.system("id -u") ~= 0) then
	-- Non-superuser, determine if TTY or emulator
	local term = vim.env.TERM
		or "unknown"
	if (term == "linux") then
		-- User in console
		mode = "TERM"
	else
		-- User in graphical terminal emulator
		mode = "USER"
	end
else
	mode = "BASE" -- Fallback to base (super user gets safest config)
end
vim.g.envmode = (mode == "USER" and 4)
	or (mode == "TERM" and 3)
	or (mode == "LESS" and 1)
	or 0

-- Prepare to include custom lua paths in package.path (.config/nvim/<script>.lua)
-- > Lua uses this path when a module called: require(<script>)
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
-- Insert new paths into the table and merge 
-- NOTE: New paths are added with one insertion since we don't reuse packagePaths later
if (mode == "BASE") then
	table.insert(packagePaths, insertAfter,
		"/etc/nvim/config/lua/?.lua;/etc/nvim/config/lua/?/init.lua")
else
	local baseDir = vim.fn.stdpath("config")
	table.insert(packagePaths, insertAfter,
		baseDir .. "/?.lua;"
		.. baseDir .. "/?/init.lua")
end
package.path = table.concat(packagePaths, ";")

-- Determine the host for environment-specific editor rules
-- > A best-guess heuristic is used when the hostname is unknown
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
	-- Save the hostname to the environment
	vim.env.HOSTNAME = hostname
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
-- > Domain 0 - Personal developments
-- > Domain 1 - Config for Gentex code process
vim.g.envdomain = (desktopFavor < 0) and 1
	or 0


-- >> FUNCTIONALITY <<
local load = function(module)
	local status = pcall(require, module)
	if not status then
		-- Notify the user that the file could not be found
		-- > TODO: Defer message so that it is visible upon startup
		local message = "Failed to load config module " .. tostring(module)
		vim.api.nvim_echo({
			{ message, "ErrorMsg" }
		}, true, {})
	end
end

-- TODO: Unsure how to set up superuser to use this config
-- > Yes, I know that I *shouldn't* do this can could use something like tee instead
load("options") -- Editor behavior (global options)
require("keymap.defaults"):load() -- Completely sane personalized key binds
if (mode == "BASE") then
	return -- Super-user config stops here
end
load("loader") -- Lazy plugin loader
load("events") -- Extra user commands/events

-- The following are not yet implemented at all, this idea may be replaced sometime
-- if (mode == "GUI") then
	-- pcall(require, "gui") -- Load fancy UI plugins and features
	-- pcall(require, "session") -- Custom session management plugin (WIP)
-- end

-- local binds = require("editor.binds")
-- binds.loadmap("defaults")
