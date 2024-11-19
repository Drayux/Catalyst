-- Starter taken from https://martinlwx.github.io/en/config-neovim-from-scratch/
-- define common options
local default_opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}

local GLOBAL = ""
local OBJECT = "o"
local NORMAL = "n"
local INSERT = "i"
local VISUAL = "v"

-- Assign leader in an obvious place
vim.g.mapleader = ";"

-----------------
-- Normal mode --
-----------------
-- >> KEYBINDS <<
-- See: cheatsheet.svg
-- Defaults will be indicated with a comment

--- NUMBER ROW
-- ` - Play macro
-- > ~ - Record macro
vim.keymap.set(NORMAL, "`", "@", default_opts)
vim.keymap.set(NORMAL, "~", "q", default_opts)

-- ! - Jump 1/2 page down
vim.keymap.set(GLOBAL, "!", "<C-u>", default_opts)

-- @ - Jump 1/2 page up
vim.keymap.set(GLOBAL, "@", "<C-d>", default_opts)

-- # - Jump to matching bracket
vim.keymap.set(GLOBAL, "#", "%", default_opts)

-- $ - Repeat last find
vim.keymap.set(GLOBAL, "$", ",", default_opts)

-- % - Repeat last replace
vim.keymap.set(GLOBAL, "%", "&", default_opts)

-- ^ - Invert case
vim.keymap.set(GLOBAL, "^", "~", default_opts)

-- & - Previous buffer
vim.keymap.set(GLOBAL, "&", "<cmd>bp<cr>", default_opts)

-- * - Next buffer
vim.keymap.set(GLOBAL, "*", "<cmd>bn<cr>", default_opts)

-- ( - Jump sequence beginning
-- > Default

-- ) - Jump sequence end
-- > Default

--- QWERTY ROW
-- TAB - Use register _
vim.keymap.set(GLOBAL, "<Tab>", "\"", default_opts)

-- Q - Jump word backwards (motion)
vim.keymap.set(GLOBAL, "q", "b", default_opts)
vim.keymap.set(GLOBAL, "Q", "B", default_opts)

-- W - Jump word forwards (motion)
-- > Default

-- E - Jump word end (motion)
-- > Default

-- R - Find char forwards (prompt/motion)
-- > Shift+R - Repeat find backwards
vim.keymap.set(GLOBAL, "r", "f", default_opts)
vim.keymap.set(GLOBAL, "R", ";", default_opts)

-- T - Cut (object)
vim.keymap.set(GLOBAL, "t", "d", default_opts)
vim.keymap.set(GLOBAL, "T", "D", default_opts)

-- Y - Yank (object)
-- > Default

-- U - Join lines
-- > Shift+U - Substitute (object)
vim.keymap.set(GLOBAL, "u", "J", default_opts)
vim.keymap.set(GLOBAL, "U", "s", default_opts)

-- I - Insert mode
-- > Shift+I - Insert mode after cursor
vim.keymap.set(NORMAL, "I", "a", default_opts)

-- O - Open line
-- > Default

-- P - Paste before cursor
-- > Shift+P - Default ~~Paste after cursor~~
-- vim.keymap.set(GLOBAL, "p", "P", default_opts)
-- vim.keymap.set(GLOBAL, "P", "p", default_opts)


--- HOME ROW
-- A - Jump to last printing character
-- > Shift+S - Jump to end of line
vim.keymap.set(GLOBAL, "a", "_", default_opts)
vim.keymap.set(GLOBAL, "A", "0", default_opts)
vim.keymap.set(OBJECT, "a", "_", default_opts) -- Motion/Object symmetry
vim.keymap.set(OBJECT, "A", "0", default_opts)  -- ^^

-- S - Jump to first printing character
-- > Shift+A - Jump to start of line
vim.keymap.set(GLOBAL, "s", "g_", default_opts)
vim.keymap.set(GLOBAL, "S", "$", default_opts)
vim.keymap.set(OBJECT, "s", "g_", default_opts) -- Motion/Object symmetry
vim.keymap.set(OBJECT, "S", "$", default_opts)  -- ^^

-- D - Replace mode
-- > Shift+D - Visual mode (block)
vim.keymap.set(GLOBAL, "d", "r", default_opts)
vim.keymap.set(GLOBAL, "D", "x", default_opts)

-- F - Visual mode
-- > Shift+F - Visual mode (lines)
vim.keymap.set(GLOBAL, "f", "v", default_opts)
vim.keymap.set(NORMAL, "F", "V", default_opts)

-- G - Change (object)
-- > Shift+G - Change to EOL
-- TODO: This is fighting with something that runs per-buffer(?)
vim.keymap.set(GLOBAL, "g", "c", default_opts)
vim.keymap.set(GLOBAL, "G", "C", default_opts)

-- H - Default
-- > Shift+H - Move buffer view down
vim.keymap.set(GLOBAL, "H", "<C-e>", default_opts)

-- J - Default
-- > Shift+J - Jump paragraph down
vim.keymap.set(GLOBAL, "J", "}", default_opts)

-- K - Default
-- > Shift+K - Jump paragraph up
vim.keymap.set(GLOBAL, "K", "{", default_opts)

-- L - Default
-- > Shift+L - Move buffer view up
vim.keymap.set(GLOBAL, "L", "<C-y>", default_opts)

-- ; - <NOP> (leader key)
vim.keymap.set(GLOBAL, ";", "<nop>", default_opts)

-- ' - [LSP] Lookup definition
-- > " - Toggle preview of filename under cursor (if present)
-- TODO


--- BOTTOM ROW
-- Z - Fold ops
-- > Default

-- X - Extra ops (TODO)
-- > Shift+X - Fix indent (TODO)
vim.keymap.set(GLOBAL, "x", "<nop>", default_opts)
vim.keymap.set(GLOBAL, "X", "<nop>", default_opts)
vim.keymap.set(NORMAL, "xo", "o<Esc>k", default_opts) -- Open a line but "stay" in normal mode
vim.keymap.set(NORMAL, "xO", "ko<Esc>j<C-e>", default_opts) -- ^^same but open the line above
-- Consider moving the following such that the x can be intuitively removed in visual mode
vim.keymap.set(NORMAL, "xm", ">>", default_opts)
vim.keymap.set(NORMAL, "xn", "<<", default_opts)
vim.keymap.set(NORMAL, "xb", "=", default_opts)

-- C - Context-based naviation oops (TODO)
-- > Shift+C - (TODO)
vim.keymap.set(GLOBAL, "c", "[", default_opts)
vim.keymap.set(GLOBAL, "C", "<nop>", default_opts)

-- V - Replace (cursor)
-- > Shift+V - Delete (cursor)
vim.keymap.set(GLOBAL, "v", "R", default_opts)
vim.keymap.set(GLOBAL, "V", "<C-v>", default_opts)

-- B - Goto operations (prompt)
-- > Shift+B - Goto end of file
vim.keymap.set(GLOBAL, "b", "g", default_opts)
vim.keymap.set(GLOBAL, "B", "G", default_opts)
vim.keymap.set(GLOBAL, "bg", "<nop>", default_opts) -- bb -> gg
vim.keymap.set(GLOBAL, "bb", "gg", default_opts)

-- N - Search next match
-- > Default but with QOL
vim.keymap.set(GLOBAL, "n", "nzz", default_opts)
vim.keymap.set(GLOBAL, "N", "Nzz", default_opts)

-- M - Jump to mark
-- > Shift+M - Set mark
vim.keymap.set(GLOBAL, "m", "'", default_opts)
vim.keymap.set(GLOBAL, "M", "m", default_opts)

-- , - Undo
-- > < - Undo line
vim.keymap.set(NORMAL, ",", "u", default_opts)
vim.keymap.set(NORMAL, "<", "U", default_opts)

-- . - Redo
-- > > - Redo line (TODO if possible)
vim.keymap.set(NORMAL, ".", "<C-r>", default_opts)
vim.keymap.set(NORMAL, ">", "<nop>", default_opts)

-- / - Search (phrase)
-- > ? - Search word at cursor
vim.keymap.set(GLOBAL, "?", "*", default_opts)


-- >> OBJECTS <<
-- Map 'o' to 'a' for "outer" word (next to 'i' for "inner" word)
vim.keymap.set(OBJECT, "o", "a", default_opts)


-- >> CONTROL COMMANDS <<
-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', default_opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', default_opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', default_opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', default_opts)

-- Window resize
-- vim.keymap.set('n', '<S-C-k>', ':resize -2<CR>', default_opts)
-- vim.keymap.set('n', '<S-C-j>', ':resize +2<CR>', default_opts)
-- vim.keymap.set('n', '<S-C-h>', ':vertical resize -2<CR>', default_opts)
-- vim.keymap.set('n', '<S-C-l>', ':vertical resize +2<CR>', default_opts)

vim.keymap.set(NORMAL, '<S-C-l>', function()
	-- TODO: Use this to vert split right
	-- (and of course add the equivalents for h, j, and k)
	print('hi')
end, default_opts)

-- Quality of life
vim.keymap.set({GLOBAL, INSERT}, "<C-/>", "<cmd>noh<cr>", default_opts)

-- >> LEADER COMMANDS <<
-- Plugin: NEOTREE
vim.keymap.set('n', "<leader>fb", "<cmd>Neofiles<cr>")
vim.keymap.set("n", "<leader>tt", "<cmd>Neotoggle<cr>")
vim.keymap.set("n", "<leader>tb", "<cmd>Neotree focus filesystem left<cr>")
vim.keymap.set("n", "<leader>ts", "<cmd>Neotree focus document_symbols left<cr>")
vim.keymap.set("n", "<leader>te", "<cmd>Neotree focus buffers left<cr>")
vim.keymap.set("n", "<leader>tg", "<cmd>Neotree focus git_status left<cr>")

-- Plugin: TELESCOPE
vim.keymap.set('n', '<leader>ff', "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fd", "<cmd>Telescope directory feature=open_dir<cr>")
vim.keymap.set('n', '<leader>fp', "<cmd>Telescope projections<cr>")
vim.keymap.set('n', '<leader>fe', "<cmd>Telescope buffers<cr>")
vim.keymap.set('n', '<leader>fg', "<cmd>Telescope live_grep<cr>")
vim.keymap.set('n', '<leader>ft', "<cmd>Telescope themes<cr>")
vim.keymap.set('n', '<leader>flt', "<cmd>Telescope themes light=true<cr>")


-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
-- vim.keymap.set('v', '<', '<gv', opts)
-- vim.keymap.set('v', '>', '>gv', opts)

-- Select text with ctrl+<arrow> (WIP)
-- vim.keymap.set('n', '<C-Down>', '<cmd>:cn<cr>')
-- vim.keymap.set('n', '<C-Up>', '<cmd>:cp<cr>')
-- vim.keymap.set('n', '<C-S-Down>', '<cmd>:cnf<cr>')
-- vim.keymap.set('n', '<C-S-Up>', '<cmd>:cpf<cr>')


