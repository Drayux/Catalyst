-- PLUGIN: nvim-tree.lua
-- SOURCE: https://github.com/nvim-tree/nvim-tree.lua

-- Filesystem tree pane
return {
	"nvim-tree/nvim-tree.lua",
	lazy = false,
	dependencies = "nvim-tree/nvim-web-devicons",
       -- cmd = { "NvimTreeOpen", "NvimTreeToggle", "NvimTreeFocus" }, (use if lazy-loading)
	config = function()
           -- (All options can be found at `:help nvim-tree-setup`)
           local options = {
               view = { width = 36 }
           }
		
		-- Enable tree and configure options
           require("nvim-tree").setup(options)
		local nvimtree_api = require("nvim-tree.api")

		-- Open the tree at startup (when directory or no path given)
		-- TODO: This is not behaving quite as expected yet
		-- 	   - File should not show the tree
		-- 	   - Directory should probably show only the tree, but an empty buffer is acceptable
		-- 	   - Pure `nvim` should show both
		vim.api.nvim_create_autocmd("VimEnter", {
			-- Only open the tree after the editor is ready
			callback = function(data)
				-- local out = ""
				-- for x, y in pairs(data) do
				-- 	out = out .. x .. ": " .. y .. "   "
				-- end
				-- print(out .. "ft: " .. vim.bo[data.buf].ft)
			
				-- No file/path given
				if vim.bo[data.buf].ft == "" then
					nvimtree_api.tree.toggle({ focus = false, find_file = true, })

				-- Path is a directory
				elseif vim.bo[data.buf].ft == "NvimTree" then
					-- // Show tree alongside empty buffer
					-- When a directory is specified, Neovim seems to show a "fake" buffer
					-- require("nvim-tree.api").tree.toggle()
					-- require("nvim-tree.api").tree.toggle({ focus = false })

					-- // Show "fullscreen" tree if directory is specified
					nvimtree_api.tree.open()
					
				end
			end
		})

		-- Make `:q` behave as expected
		-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close#beauwilliams
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("NvimTreeClose", { clear = true }),
			pattern = "NvimTree_*",
			callback = function()
				local layout = vim.api.nvim_call_function("winlayout", {})
				if layout[1] == "leaf" and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree" and layout[3] == nil then 
					vim.cmd("confirm quit")
				end
			end
		})
		
		-- Don't show a status line for the tree
		nvimtree_api.events.subscribe(nvimtree_api.events.Event.TreeOpen, function()
			local tree_winid = nvimtree_api.tree.winid()

			if tree_winid ~= nil then
				vim.api.nvim_set_option_value('statusline', ' ', { win = tree_winid })
			end
		end)
	end
}
