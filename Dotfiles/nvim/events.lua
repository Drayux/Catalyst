-- Open nvim-tree at startup (when directory or no path given, if plugin exists)
-- TODO: This is not behaving quite as expected yet
-- 	   - File should not show the tree
-- 	   - Directory should probably show only the tree, but an empty buffer is acceptable
-- 	   - Pure `nvim` should show both
vim.api.nvim_create_autocmd("VimEnter", {
	-- Only open the tree after the editor is ready
	callback = function(data)
		local directory = (vim.fn.isdirectory(data.file) == 1)

		-- Debug output
		-- local out = ""
		-- for x, y in pairs(data) do
		-- 	out = out .. x .. ": " .. y .. "   "
		-- end
		-- print(out .. "ft: " .. vim.bo[data.buf].ft .. ", " .. tostring(vim.fn.filereadable(data.file) == 1) .. ", " .. tostring(vim.fn.isdirectory(data.file) == 1))

		-- Restore the session if available
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

-- Make `:q` behave as expected when a tree is open
-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close#rwblokzijl
vim.api.nvim_create_autocmd("WinClosed", {
	callback = function()
		local function tab_win_closed(winnr)
			local api = require ("nvim-tree.api")
			local tabnr = vim.api.nvim_win_get_tabpage(winnr)
			local bufnr = vim.api.nvim_win_get_buf(winnr)
			local buf_info = vim.fn.getbufinfo(bufnr)[1]
			local tab_wins = vim.tbl_filter(function(w) return w~=winnr end, vim.api.nvim_tabpage_list_wins(tabnr))
			local tab_bufs = vim.tbl_map(vim.api.nvim_win_get_buf, tab_wins)
			if buf_info.name:match(".*NvimTree_%d*$") then            -- close buffer was nvim tree
				-- Close all nvim tree on :q
				if not vim.tbl_isempty(tab_bufs) then                      -- and was not the last window (not closed automatically by code below)
					api.tree.close()
				end
			else                                                      -- else closed buffer was normal buffer
				if #tab_bufs == 1 then                                    -- if there is only 1 buffer left in the tab
					local last_buf_info = vim.fn.getbufinfo(tab_bufs[1])[1]
					if last_buf_info.name:match(".*NvimTree_%d*$") then       -- and that buffer is nvim tree
						vim.schedule(function()
							if #vim.api.nvim_list_wins() == 1 then                -- if its the last buffer in vim
								vim.cmd("quit")                                        -- then close all of vim
							else                                                  -- else there are more tabs open
								vim.api.nvim_win_close(tab_wins[1], true)             -- then close only the tab
							end
						end)
					end
				end
			end
		end

		local winnr = tonumber(vim.fn.expand("<amatch>"))
		vim.schedule_wrap(tab_win_closed(winnr))
	end,
	nested = true
})

-- Add a confirm close when a modified buffer is present
-- TODO: Nvim seems somewhat unintuitive when it comes to open/closed/hidden buffers
-- vim.api.nvim_create_autocmd({"QuitPre", "BufWinLeave"}, {
-- 	callback = function()
-- 		if vim.bo.modified then
-- 			vim.cmd("confirm quit")
-- 			-- vim.schedule(function() vim.cmd("confirm quit") end)
-- 		end
-- 	end,
-- 	nested = false
-- })
