-- Starter taken from https://martinlwx.github.io/en/config-neovim-from-scratch/
-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}

-----------------
-- Normal mode --
-----------------

-- Close a buffer while retaining its window
-- (Also better compatibilty with NeoTree)
vim.cmd("cnorea bq bd")
vim.cmd("cnorea bquit bd")
vim.cmd("cnorea bd bp<bar>sp<bar>bn<bar>bd")
vim.cmd("cnorea bdel bp<bar>sp<bar>bn<bar>bd")
vim.cmd("cnorea bdelete bp<bar>sp<bar>bn<bar>bd")

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Resize with arrows
-- delta: 2 lines
-- vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
-- vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
-- vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
-- vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Select text with ctrl+<arrow> (WIP)
vim.keymap.set('n', '<C-Down>', '<cmd>:cn<cr>')
vim.keymap.set('n', '<C-Up>', '<cmd>:cp<cr>')
vim.keymap.set('n', '<C-S-Down>', '<cmd>:cnf<cr>')
vim.keymap.set('n', '<C-S-Up>', '<cmd>:cpf<cr>')

-----------------
-- Plugins     --
-----------------

-- TELESCOPE
-- TODO: /fd doesn't let me select a parent directory
-- TODO: /fb doesn't change the working directory when in a workspace(?)
vim.keymap.set('n', '<leader>ff', "<cmd>Telescope find_files<cr>", {})
vim.keymap.set("n", "<leader>fd", "<cmd>Telescope directory feature=open_dir<cr>", {})
vim.keymap.set('n', '<leader>fp', "<cmd>Telescope projections<cr>", {})
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", {})
vim.keymap.set('n', '<leader>fe', "<cmd>Telescope buffers<cr>", {})
vim.keymap.set('n', '<leader>fg', "<cmd>Telescope live_grep<cr>", {})
vim.keymap.set('n', '<leader>ft', "<cmd>Telescope themes<cr>", {})

