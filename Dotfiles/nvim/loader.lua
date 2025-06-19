-- >>> loader.lua: Lazy loader and third-party plugins

-- Leader key dedicated to plugin key bindings
vim.g.mapleader = ";"
vim.g.plugpath = vim.fn.stdpath("config") .. "/plugins/"

-- >>> Plugin load levels
-- TODO: These currently feel a bit vague and their use case ambiguous
function condCORE() return vim.g.envmode > 0 end
function condUSER() return vim.g.envmode > 2 end
function condBASE() return vim.g.envmode < 4 end
function condGUI() return vim.g.envmode == 4 end
-- <<<

-- Add lazy to the vim runtime path
-- > https://neovim.io/doc/user/starting.html#load-plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

-- Reinstall lazy loader if the path does not exist
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local repo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end

-- Lazy loader configuration
local config = {
	defaults = { lazy = true },
	root = vim.fn.stdpath("data") .. "/lazy",
	lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
	dev = { path = vim.fn.stdpath("config") .. "/dev" },
	spec = {
		name = "plugins",
		import = function()
			-- Table of plugin specs to be fed to Lazy
			local plugins = {}

			-- Directory to search for plugin spec files
			local dir = vim.g.plugpath
				or (vim.fn.stdpath("config") .. "/plugins/")
			-- Correct the path if invalid
			if (dir:sub(-1) ~= "/") then
				dir = vim.g.plugpath .. "/"
			end

			-- Lazy loader supports a function instead of a string
			-- > for imports (aka this function) so we can return
			-- > our own table of plugin specs for any source
			for _, file in ipairs(vim.fn.readdir(dir, [[v:val =~ '\.lua$']])) do
				local spec = nil
				local plugconfig, err = loadfile(dir .. file)
				if plugconfig then
					spec, err = plugconfig()
				end

				if err then
					-- Lua error while loading the plugin spec
					print("Failed to load plugin: "
						.. file
						.. "\n > "
						.. (err or "~ unexpected error ~"))
				elseif spec then
					if (type(spec) == "table") then
						table.insert(plugins, spec)
					elseif (type(spec) == "string") then
						table.insert(plugins, { spec })
					else
						print("Plugin `" .. file .. "` provided no spec, skipping")
					end
				end
			end
			return plugins
		end
	},
	performance = {
		rtp = {
			reset = false,
			disabled_plugins = {
				"bugreport", "compiler", "ftplugin",
				"getscript", "getscriptPlugin",
				"gzip", "logipat",
				"netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
				"matchit", "optwin", "syntax", "synmenu",
				"tar", "tarPlugin",
				"tohtml", "2html_plugin",
				"tutor", "rplugin", "rrhelper", "spellfile_plugin",
				"vimball", "vimballPlugin",
				"zip", "zipPlugin",
			}
		}
	},
}
require("lazy").setup(config)
