-- >>> events.lua: Extra user commands and autoevents

-- >> ALIASES <<
-- TODO: Smart windows (lua/buffer/init.lua -> closeBuffer)
vim.cmd("cnorea bq bd")
vim.cmd("cnorea bquit bd")
-- >>> TODO: Move these to buffers.closeBuffer when finished
vim.cmd("cnorea bd bp<bar>sp<bar>bn<bar>bd")
vim.cmd("cnorea bdel bp<bar>sp<bar>bn<bar>bd")
vim.cmd("cnorea bdelete bp<bar>sp<bar>bn<bar>bd")
-- <<<

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

-- Dynamically set wrap/nowrap depending on window width
-- Small windows will not wrap and big ones will (since *super* long lines
-- should be quite rare)
-- TODO: Add a setting to disable this (should it be window-local or global?)
-- > Thinking of calling it "autowrap"
vim.api.nvim_create_autocmd("WinResized", {
	callback = function()
		for _, winid in ipairs(vim.v.event.windows) do
			local wrap = vim.wo[winid].wrap
			local width = vim.api.nvim_win_get_width(winid)
			if width < 80 then
				if wrap then
					vim.wo[winid].wrap = false
				end
			else
				if not wrap then
					vim.wo[winid].wrap = true
				end
			end
		end
	end
})

-- TODO: Fancy fold behavior
-- > Also make note of referencing the default fold options in editor.lua

-- DOMAIN 1: Gentex (work) style/process
if (vim.g.envdomain == 1) then
	-- Prefer spaces over tabs for C and Ruby sources
	vim.api.nvim_create_autocmd("BufReadPost", {
		pattern = { "*.c", "*.cpp", "*.h", "*.rb" },
		callback = function()
			vim.cmd.setlocal("expandtab")
		end
	})
end
