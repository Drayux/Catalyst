-- Starter from https://martinlwx.github.io/en/config-neovim-from-scratch/
-- Hint: use `:h <option>` to figure out the meaning if needed

-- Interface
vim.opt.clipboard = 'unnamedplus'   -- use system clipboard 
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
vim.opt.mouse = 'a'                 -- allow the mouse to be used in Nvim
vim.opt.splitbelow = true           -- open new vertical split bottom
vim.opt.splitright = true           -- open new horizontal splits right
vim.opt.confirm = true				-- Confirm changes to unsaved buffer on quit (instead of erroring out)

--- Keymapping
vim.g.mapleader = "/"
vim.opt.timeout = false

--- Sessions
vim.opt.sessionoptions:append("localoptions")       -- Save localoptions to session file


-- Appearance
vim.g.default_theme = "draycula"
vim.opt.number = true               -- show absolute number
vim.opt.relativenumber = true       -- add numbers to each line on the left side
vim.opt.showmode = false			-- hide the -- INSERT -- tag in insert mode (nothing to do with statusline)
vim.opt.cursorline = true           -- highlight cursor line underneath the cursor horizontally


-- Editor
--- Tabs
vim.opt.tabstop = 4                 -- number of visual spaces per TAB
vim.opt.softtabstop = 4             -- number of spacesin tab when editing
vim.opt.shiftwidth = 4              -- insert 4 spaces on a tab
vim.opt.expandtab = false           -- use tabs instead of spaces because we are sane

--- Search
vim.opt.incsearch = true            -- search as characters are entered
vim.opt.hlsearch = true             -- do not highlight matches
vim.opt.ignorecase = true           -- ignore case in searches by default
vim.opt.smartcase = true            -- but make it case sensitive if an uppercase is entered

--- Folding
--- TODO: Consider if I want auto closing (especially if a fold were opened via movement with insert mode or search)
vim.opt.foldenable = false			-- Don't fold code by default
vim.opt.foldlevelstart = 1			-- Default global fold level (used by zm, zr, etc.)
vim.opt.foldminlines = 2 -- 9		-- Minimum block size +1 to be considered a fold point; includes start/end of block (Min screen for context.nvim is 24) ; 2 so one-liners are skipped
vim.opt.foldopen = "all" -- "block,hor,insert,jump,mark,percent,quickfix,search,tag,undo"
vim.opt.foldclose = "all" -- ""
vim.opt.foldmethod = "expr"			-- Use `foldexpr` to automatically define fold points
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldtext = "" -- "v:lua.vim.treesitter.foldtext()"


-- Plugins
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
