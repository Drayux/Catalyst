-- >>> init.lua: Neovim configuration entry point

-- DEPENDENCIES:
--  > A "Nerd" font (i.e. JetbrainsMonoNerdFont - Use monospace variant for non-merging symbols)

-- Setup 'lazy' plugin loader
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local repo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end


-- Configuration
-- Look for config files in ~/.config/nvim (instead of ~/.config/nvim/lua)
local wdpath, luapath = package.path:match("(.-);(.*)$")
if luapath and wdpath:match("^%./%?") then
	-- Remove "./?.lua" from path if present
	package.path = luapath
end
package.path = vim.fn.stdpath('config') .. "/?.lua;"
	.. vim.fn.stdpath('config') .. "/?/init.lua;"
	.. package.path

-- Load config groups (before plugins)
local opts = require("config")		-- Global configuration: .../nvim/config.lua (returns lazy loader config)
require("keymap")			-- Key bindings: .../nvim/keymap.lua
require("events")			-- Event hooks: .../nvim/events.lua


-- Plugins
vim.opt.rtp:prepend(lazypath)
local pluginpath = vim.fn.stdpath("config") .. "/plugins"
local plugins = {}

-- Optionally exclude certain plugins (via file name)
local exclude = {
	filetree = false,
	ui = false, 
	base46 = false,
}

-- Load plugin files from .../nvim/plugins/
for _, file in ipairs(vim.fn.readdir(pluginpath, [[v:val =~ '\.lua$']])) do
	local module = file:gsub("%.lua$", "")
	if exclude[module] == true then goto continue end
	
	table.insert(plugins, require("plugins." .. module))
	::continue::
end
require("lazy").setup(plugins, opts)

