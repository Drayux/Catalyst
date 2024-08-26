-- Function to access the hostname of a Linux box
-- Allows for home/work "dual-boot" config
-- TODO: Consider making a new file "commands.lua" and moving this there (likely loaded at the end of init.lua)
local hostname = function()
	if vim.g.hostname then
		-- Cache hostname to reduce I/O traffic
		return vim.g.hostname
	end

	local hnfile = io.popen("/bin/hostname")
	local output = hnfile:read("*a") or ""
	hnfile:close()

	local name = output:match("(.+)\n$") or output
	vim.g.hostname = name
	return name
end

-- Add hostname command as a neovim user command
vim.api.nvim_create_user_command("Hostname", function()
	print(hostname()) end, {

	nargs = 0,
	desc = "Return the system hostname",
})

-- Prefer tabs over spaces unless coding for work
-- TODO: Test different hooks so that as little overhead is added as possible
-- ^^(BufAdd should work, but that needs verification alongside Projections)
-- https://neovim.io/doc/user/autocmd.html#autocmd-events
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "*.c", "*.h" },
	callback = function()
		if hostname():match("^LX-.*") then
			vim.cmd.setlocal("expandtab")
		end
	end
})


-- TODO: CLEAN UP EVENTS BELOW THIS --


-- IDEA:
-- On the event multiple files are specified, create a local directory (.nvim_tmp or so)
--   and symlink the listed files/directories into this temporary directory.
-- CD to the temporary directory, and open the tree, so that all of the requested files are
--   accessable at the same directory level.
-- Upon exit, delete .nvim_tmp
-- Alternatively, create .nvim_tmp inside $HOME/.local/share/nvim and always ask about the
--   session if it exists. If the user wants two sessions, then we can create another directory
--   and set the index as a variable. Session restoring should always check for any directory
--   .nvim_tmp_X (not just .nvim_tmp)
-- For that solution, three options should be presented: Yes (restore), No (delete), No (but save it)
-- QUESTIONS: 
--   What to do if opened and .nvim_tmp already exists?
--     (Possibly: destroy/recreate it OR ask the user if they wish to restore their 'session')
--   What should happen if the user creates a file within the temporary directory?
--     (Possibly: when destorying the temporary directory, delete all symlinks and move all 
--     non-symlinks to the parent directory, which would be...the directory of the first file?


-- Open nvim-tree at startup (when directory or no path given, if plugin exists)
-- TODO: This is not behaving quite as expected yet
-- 	   - File should not show the tree
-- 	   - Directory should probably show only the tree, but an empty buffer is acceptable
-- 	   - Pure `nvim` should show both
vim.api.nvim_create_autocmd("VimEnter", {
	-- Only open the tree after the editor is ready
	callback = function(data)
		local directory = (vim.fn.isdirectory(data.file) == 1)

		-- NOTE: This does not appear to work on child directories of a project
		if data.file == "" then data.file = nil end
		if not data.file or directory then
			local workspace = data.file or vim.loop.cwd()
			local psstatus, session = pcall(require, "projections.session")
			if psstatus and session.info(workspace) then
				session.restore(workspace)
				-- Tree will be displayed upon restore as per config in plugins/projects.lua
				return
			end
		end

		-- Path is a directory
		-- Change nvim to that directory, open a tree, and present an empty buffer
		-- NOTE: The funny "Nvim / No Name" tab behavior seems to be an artifact how vim buffers work
		-- Design:	Running nvim on a directory assumes that I would want to create a file in that
		-- 			directory or secondary to that, open a file or workspace in that directory
		if directory then
			vim.cmd.cd(data.file)
			vim.cmd.enew()
			
			local ntstatus, ntapi = pcall(require, "nvim-tree.api")
			if not ntstatus then return end
			ntapi.tree.toggle({ focus = false })
		end

		-- If a direct path was given, then we're done
		if data.file then return end

		-- No path
		-- Open workspace if present, else open a dashboard (and do not show the tree)
		-- Design:	Opening it "raw dog" means that I am either trying to use a workspace
		-- 			or create a quick and dirty file; chances are that the tree won't show helpful
		-- 			information, or will otherwise be opened upon the "create workspace" action

		-- Show the NvChad/ui dash if present and dir is not a workspace
		-- TODO: This runs on the lazy loader window if open (and it should not do this)
		local nvstatus, nvdash = pcall(require, "nvchad.nvdash")
		if not nvstatus then return end
		nvdash.open()
	end
})

