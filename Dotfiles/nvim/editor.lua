-- >>> editor.lua: Neovim global options

-- Reference: https://neovim.io/doc/user/options.html#_3.-options-summary
-- Global defaults: https://neovim.io/doc/user/options.html#local-noglobal
-- (*) - Option overridden in some modes

-- >> BEHAVIOR <<
vim.o.confirm = true -- Ask to save changes before exit
vim.o.timeout = false -- Disable leader (+multi-key) timeout
vim.o.scrolloff = 4 -- Default cursor offset (global or local)
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.mouse = "" -- Disable mouse support (*)

-- >> DISPLAY <<
vim.o.number = true
vim.o.showmode = true -- Show the '-- MODE --' hint (*)
vim.o.cursorline = true -- Highlight active line
vim.o.foldenable = false -- Set default fold mode (local)
vim.o.foldlevelstart = 0 -- Initial nest depth before folding
vim.o.linebreak = true

-- >> EDITING <<
vim.o.tabstop = 4 -- Visual length of a tab character
vim.o.expandtab = false -- Prefer tab characters (*)
vim.o.shiftwidth = 4 -- Count of spaces to fill if expandtab is set
-- > Buffer options whose defaults are set globally
vim.o.clipboard = "unnamed" -- Use * register by default

-- >> SEARCH <<
vim.o.ignorecase = true -- Case-insensitive search
vim.o.smartcase = true -- ^^unless an uppercase character is used
vim.o.hlsearch = true -- Highlight search matches
vim.o.incsearch = true -- Moves view to first match when set
