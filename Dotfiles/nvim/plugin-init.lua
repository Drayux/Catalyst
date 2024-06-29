-- The list of plugins for lazy to load
local list = {
	-- Both of the following are valid (example)
	-- "tanvirtin/monokai.nvim",
	-- { "tanvirtin/monokai.nvim" },

	{ "nvim-lua/plenary.nvim" },
	{ "nvim-tree/nvim-web-devicons",
		config = function() --function(_, opts)
			dofile(vim.g.base46_cache .. "devicons")
			-- require("nvim-web-devicons").setup(opts)
		end
	},
	{ "nvim-tree/nvim-tree.lua",
	-- Filesystem tree pane
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
	},
    { "nvim-telescope/telescope.nvim",
    -- Fuzzy finder utility
    -- TODO: Don't save an empty buffer as "No title" window when opening something else
        tag = "0.1.8",
        dependencies = { 'nvim-lua/plenary.nvim' },
        cmd = "Telescope"
    },
    { "nvim-treesitter/nvim-treesitter",
    -- Advanced syntax highlighting
		event = { "BufReadPost", "BufNewFile" },
		cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
		build = ":TSUpdate",
		-- opts = function() return require "nvchad.configs.treesitter" end,
		-- config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end
	},
	{ "NvChad/ui",
	-- Provides the status bar and base46 theming dependencies
		branch = "v2.5",
		lazy = false,
		config = function() require("nvchad") end
	},
	{ "NvChad/base46",
	-- ^^Depends on NvChad/ui (for "nvconfig") and nvim-lua/plenary.nvim (to build bytecode)
		branch = "v2.5",
		lazy = false,
        dependencies = { 'nvim-lua/plenary.nvim' },
		build = function() require("base46").load_all_highlights() end,
		config = function()
			require("base46").load_all_highlights()
			dofile(vim.g.base46_cache .. "defaults")
			dofile(vim.g.base46_cache .. "statusline")
		end
	},
	{ "NvChad/nvim-colorizer.lua",
	-- Highlights color codes (i.e. #551bdf) with the reflected color
		event = "User FilePost",
		opts = {
			user_default_options = { names = false }
		},
		config = function(_, opts)
			require("colorizer").setup(opts)
			vim.defer_fn(function()
				require("colorizer").attach_to_buffer(0)
			end, 0)
		end
	},
}

return list
