-- Setup 'lazy' plugin loader
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local repo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end

-- Look for config files in ~/.config/nvim (instead of ~/.config/nvim/lua)
-- TODO: We may wish to put this *after* the working directory
package.path = vim.fn.stdpath('config') .. "/?.lua;" .. vim.fn.stdpath('config') .. "/?/init.lua;" .. package.path
vim.opt.rtp:prepend(lazypath)

-- Global configuration options
vim.g.mapleader = "/"
vim.g.base46_cache = vim.fn.stdpath("data") .. "/nvchad/base46/"

local pluginopts = require("options")
local pluginpath = vim.fn.stdpath("config") .. "/plugins"
local plugins = {}

-- Exclude loading certain plugins
local exclude = {
	filetree = false,
	ui = false, 
	base46 = false,
}

-- Load all plugins specified in .../nvim/plugins/
for _, file in ipairs(vim.fn.readdir(pluginpath, [[v:val =~ '\.lua$']])) do
	local module = file:gsub("%.lua$", "")
	if exclude[module] == true then goto continue end
	
	table.insert(plugins, require("plugins." .. module))
	::continue::
end
require("lazy").setup(plugins, pluginopts)

-- Event hooks and functionality
require("keymaps")	-- Key bindings: .../nvim/keymaps.lua
require("events")	-- Event hooks: .../nvim/events.lua
