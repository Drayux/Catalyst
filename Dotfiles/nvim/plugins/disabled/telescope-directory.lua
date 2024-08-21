-- PLUGIN: telescope-directory.nvim
-- SOURCE: https://github.com/fbuchlak/telescope-directory.nvim

-- Telescope extension to search for directories

local plugin = {
    "fbuchlak/telescope-directory.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    opts = {
    	features = {
    		{	-- When a directory is selected, cd, create new buffer, show nvim-tree
    			name = "open_dir",
	    		callback = function(dirs)
					vim.cmd.cd(dirs[1])
					vim.cmd.enew()

					local ntstatus, ntapi = pcall(require, "nvim-tree.api")
					if ntstatus then
						ntapi.tree.close()
						ntapi.tree.toggle({ focus = false })
					end
				end
			}
    	}
    },
    config = function(_, opts)
        require("telescope-directory").setup(opts)
    end
}

return plugin
