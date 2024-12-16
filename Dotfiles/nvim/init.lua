-- >>> init.lua: Neovim configuration entry point

-- DEPENDENCIES:
--  > A "Nerd" font (i.e. JetbrainsMonoNerdFont - Use monospace variant for non-merging symbols)

-- >> CORE <<
-- Setup 'lazy' plugin loader
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local repo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end

-- Look for config files in ~/.config/nvim (instead of ~/.config/nvim/lua)
local wdpath, luapath = package.path:match("(.-);(.*)$")
if luapath and wdpath:match("^%./%?") then
	-- Remove "./?.lua" from path if present
	package.path = luapath
end
package.path = vim.fn.stdpath('config') .. "/?.lua;"
	.. vim.fn.stdpath('config') .. "/?/init.lua;"
	.. package.path

-- Override the runtime path (to trim unexpected default settings)
-- TODO: Pluck runtime from path, overwrite to minimal version
-- print(vim.o.runtimepath)
vim.opt.rtp:prepend(lazypath)


-- >> CONFIG <<
-- Load config groups (before plugins)
require("commands")			-- User commands (load first): .../nvim/commands.lua
require("keymap")			-- Key bindings: .../nvim/keymap.lua
local opts = require("config")		-- Global configuration: .../nvim/config.lua (returns lazy loader config)


-- Plugins
local pluginpath = vim.fn.stdpath("config") .. "/plugins"
local plugins = {}

-- Optionally disable certain plugins (via filename)
local disable = {
	["CODE-colorizer"] = false,
	["CODE-context"] = false, 
	["CODE-treesitter"] = false,
	["DEP-nui"] = false,
	["DEP-plenary"] = false,
	["DEP-webdevicons"] = false,
	["UI-lualine"] = false,
	["UI-neotree"] = false,
	["UTIL-projections"] = true,
	["UTIL-telescope"] = false,
	["UTIL-themer"] = false,
	["UTIL-windowpicker"] = false,
}

-- Load plugin files from .../nvim/plugins/
for _, file in ipairs(vim.fn.readdir(pluginpath, [[v:val =~ '\.lua$']])) do
	local module = file:gsub("%.lua$", "")
	if disable[module] == true then goto continue end
	
	table.insert(plugins, require("plugins." .. module))
	::continue::
end
require("lazy").setup(plugins, opts)

