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

-- TODO: Fancy fold behavior
-- > Also make note of referencing the default fold options in editor.lua

-- Work style guideline options
if (vim.g.host == "WORK") then
	vim.api.nvim_create_autocmd("BufReadPost", {
		pattern = { "*.c", "*.cpp", "*.h", "*.rb" },
		callback = function()
			vim.cmd.setlocal("expandtab")
		end
	})
end
