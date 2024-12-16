-- Starter from https://martinlwx.github.io/en/config-neovim-from-scratch/
-- Hint: use `:h <option>` to figure out the meaning if needed

-- >> APPEARANCE <<
vim.g.default_theme = "draycula"
vim.o.number = true					-- show absolute number
vim.o.relativenumber = true			-- add numbers to each line on the left side
vim.o.showmode = false				-- hide the -- INSERT -- tag in insert mode (nothing to do with statusline)
vim.o.cursorline = true				-- highlight cursor line underneath the cursor horizontally


-- >> INTERFACE <<
--- General
vim.g.default_splitbelow = true				-- Preferred setting for horizontal splits
vim.g.default_splitright = true				-- Preferred setting for vertical splits
vim.o.splitbelow = vim.g.default_splitbelow -- open new horizontal split bottom
vim.o.splitright = vim.g.default_splitright -- open new vertical splits right
vim.o.clipboard = 'unnamedplus'		-- use system clipboard 
vim.o.mouse = 'a'					-- allow the mouse to be used in Nvim
vim.o.confirm = true				-- Confirm changes to unsaved buffer on quit (instead of erroring out)
vim.o.scrolloff = 4					-- Pad lines from the cursor to the edge of the window
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

--- Keymapping
vim.o.timeout = false				-- Disable leader timeout

--- Sessions
vim.opt.sessionoptions:append("localoptions")       -- Save localoptions to session file


-- >> EDITOR <<
--- Formatting
vim.o.tabstop = 4					-- number of visual spaces per TAB
vim.o.softtabstop = 4				-- number of spaces in a tab when editing
vim.o.expandtab = false				-- use tabs instead of spaces because we are sane (SEE AUTOCOMMAND BELOW)
vim.o.shiftwidth = 4				-- in (crackhead) spaces mode, use four spaces in place of a TAB
-- vim.cmd.filetype("plugin off")
-- > vim.opt.formatoptions: SEE AUTOCOMMAND BELOW

--- Search
vim.o.incsearch = false				-- Do not search as characters are entered
vim.o.hlsearch = true				-- Do not highlight matches
vim.o.ignorecase = true				-- Ignore case in searches by default
vim.o.smartcase = true				-- ...but make it case sensitive if an uppercase is entered
vim.opt.iskeyword:remove("_")		-- Allow _ to split words (like - does)

--- Folding
-- TODO: Consider if I want auto closing (especially if a fold were opened via movement with insert mode or search)
vim.o.foldenable = false			-- Don't fold code by default
vim.o.foldlevelstart = 0			-- Default global fold level (used by zm, zr, etc.)
vim.o.foldminlines = 2 -- 9			-- Minimum block size +1 to be considered a fold point; includes start/end of block (Min screen for context.nvim is 24) ; 2 so one-liners are skipped
-- TODO: Open fold when some modifier is pressed and navigating (for example, moving into a block with J instead of j)
vim.o.foldopen = "block,hor,insert,jump,mark,percent,quickfix,search,tag,undo" -- "all"
vim.o.foldclose = "all" -- ""
vim.o.foldmethod = "expr"			-- Use `foldexpr` to automatically define fold points
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
-- TODO: Remove the dot character that fills the line of folded text
vim.o.foldtext = "" -- "v:lua.vim.treesitter.foldtext()"


-- >> COMMANDS <<
--- Close a buffer while retaining its window
-- (Also provides better compatibilty with NeoTree)
-- TODO: It may be possible to replace this with an autocommand hooked on BufDelPre
vim.cmd("cnorea bq bd")
vim.cmd("cnorea bquit bd")
vim.cmd("cnorea bd bp<bar>sp<bar>bn<bar>bd")
vim.cmd("cnorea bdel bp<bar>sp<bar>bn<bar>bd")
vim.cmd("cnorea bdelete bp<bar>sp<bar>bn<bar>bd")


-- >> EVENTS <<
--- Specify autocommands for the components that require them

-- Prefer tabs over spaces unless coding for work
-- TODO: Test with projections (if I opt to use it again)
-- > https://neovim.io/doc/user/autocmd.html#autocmd-events
vim.api.nvim_create_autocmd("BufNew", {
    pattern = { "*.c", "*.h" },
	callback = function()
		-- Tabs/Spaces
		pcall(vim.cmd.HostnameCmd()) -- Ensure hostname is set
		if (vim.g.hostname):match("^LX%-.+") then
			vim.cmd.setlocal("expandtab")
		end
	end
})

-- The Filetype plugin is dumb and fights with format options
-- https://www.reddit.com/r/neovim/comments/1bduxqd/prevent_vimofo_reset_by/
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		-- vim.cmd.setlocal("formatoptions-=o")
		vim.opt_local.formatoptions:remove("o")
	end
})


-- >> PLUGINS <<
--- Lazy loader
local opts = {
	lockfile = vim.fn.stdpath("cache") .. "/lazy-lock.json",
	defaults = { lazy = true },
	ui = {
		icons = {
			ft = "",
			lazy = "󰂠 ",
			loaded = "",
			not_loaded = "",
		}
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"2html_plugin",
				"tohtml",
				"getscript",
				"getscriptPlugin",
				"gzip",
				"logipat",
				"netrw",
				"netrwPlugin",
				"netrwSettings",
				"netrwFileHandlers",
				"matchit",
				"tar",
				"tarPlugin",
				"rrhelper",
				"spellfile_plugin",
				"vimball",
				"vimballPlugin",
				"zip",
				"zipPlugin",
				"tutor",
				"rplugin",
				"syntax",
				"synmenu",
				"optwin",
				"compiler",
				"bugreport",
				"ftplugin",
			}
		}
	},
}

return opts
