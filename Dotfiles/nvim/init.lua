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
require("keymaps")						-- Key bindings: .../nvim/keymaps.lua
local lazyopts = require("config")	-- Nvim configuration: .../nvim/config.lua

vim.g.mapleader = "/"
vim.g.base46_cache = vim.fn.stdpath("data") .. "/nvchad/base46/"

-- Load all plugins specified in .../nvim/plugins/
local pluginpath = vim.fn.stdpath("config") .. "/plugins"
local plugins = {}
for _, file in ipairs(vim.fn.readdir(pluginpath, [[v:val =~ '\.lua$']])) do
	local module = "plugins." .. file:gsub("%.lua$", "")
	table.insert(plugins, require(module))
end
require("lazy").setup(plugins, lazyopts)
