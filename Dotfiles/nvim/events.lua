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

