-- >>> events.lua: Extra user commands and autoevents

-- >> ALIASES <<
-- TODO: Smart windows
vim.cmd("cnorea bq bd")
vim.cmd("cnorea bquit bd")
vim.cmd("cnorea bd bp<bar>sp<bar>bn<bar>bd")
vim.cmd("cnorea bdel bp<bar>sp<bar>bn<bar>bd")
vim.cmd("cnorea bdelete bp<bar>sp<bar>bn<bar>bd")

-- >> COMMANDS <<
-- (none....yet)

-- >> BUFFER-OPTIONS <<
-- Comment newline behavior is set by the builtin FileType plugin
-- > https://www.reddit.com/r/neovim/comments/1bduxqd/prevent_vimofo_reset_by/
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		-- vim.cmd.setlocal("formatoptions-=o")
		vim.opt_local.formatoptions:remove("o")
	end
})

-- Code folding options
-- > All fold options are local to windows
-- > vim.o invokation sets the following as defaults
-- TODO: These settings still need tweaking: some form of auto-open/auto-close functionality would be nice for quick file navigation
vim.o.foldenable = false
vim.o.foldminlines = 2 -- Include block start/end, +1 (2 = skip one-liners)
vim.o.foldopen = "block,hor,insert,jump,mark,percent,quickfix,search,tag,undo"
vim.o.foldclose = "all"
vim.o.foldtext = "" -- (look into: v:lua.vim.treesitter.foldtext())
-- TODO: Set foldmethod and foldexpr inside of treesitter plugin config
-- vim.o.foldmethod = "expr"
-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"

-- Work style guideline options
if (vim.g.host == "WORK") then
	vim.api.nvim_create_autocmd("BufReadPost", {
		pattern = { "*.c", "*.h", "*.rb" },
		callback = function()
			vim.cmd.setlocal("expandtab")
		end
	})
end
