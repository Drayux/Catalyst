-- PLUGIN: lualine.nvim
-- SOURCE: https://github.com/nvim-lualine/lualine.nvim
-- LEVEL: GUI

-- Customizable status line

-- winbar = {
-- 	lualine_c = { "buffers" },
-- },
-- inactive_winbar = {
-- 	lualine_c = { "filename" },
-- },
-- extensions = {},

local api = require("status")
local files = require("files")
local spec = {
	"nvim-lualine/lualine.nvim",
	cond = condGUI,
	lazy = false, -- NOTE: False here is loosely handling a theme race condition
	-- event = { "VimEnter" },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			component_separators = "",
			section_separators = { left = "", right = "" },
			disabled_filetypes = { "neo-tree", "neo-tree-popup", "notify" },
			enable_tabline = true -- Custom option for dynamic initialization
		},
		sections = {
			lualine_a = {
				{ "mode", separator = { left = " " }, right_padding = 2 }
			},
			lualine_b = { "filename", "branch" },
			lualine_c = {
				"%=", -- add center components here
			},
			lualine_y = { "filetype", "progress" },
			lualine_z = {
				{ "location", separator = { right = " " }, left_padding = 2 },
			}
		},
		inactive_sections = {
			lualine_a = { "filename" },
			lualine_z = { "location" },
		}
	},
	init = function()
		vim.g.lualine_enabled = true
		vim.o.showmode = false

		-- Akin to LualineBuffersJump, delete an arbitrary buffer via index
		-- TODO: For some reason, using the BANG causes the window to close in the same conditions
		-- that not using the bang would not
		vim.api.nvim_create_user_command("LualineBuffersDelete", api.delete, {
			nargs = "?",
			desc = "Delete a buffer, indexed by the Lualine buffers index",
			bang = true,
		})
	end,
	config = function(_, opts)
		if opts.options.enable_tabline then
			local genTreeButton = function()
				if not vim.g.neotree_enabled then return nil end
				local button = {
					-- Display a (   /  ) icon for the button
					function()
							if files.open() then return "" end
							return ""
						end,
					on_click = function()
						vim.cmd("Neotoggle")
					end
				}
				return button
			end

			local genBufLine = function()
				local buffers = {
					"buffers",
					show_filename_only = true,
					hide_filename_extension = false,
					show_modified_status = true,

					mode = 2, -- 4,
					max_length = vim.o.columns - 2,

					filetype_names = {
						["neo-tree"] = "  Neotree",
						["TelescopePrompt"] = "  Telescope",
					},

					use_mode_colors = true,
					
					symbols = {
						modified = ' ●',
						alternate_file = '',
						directory =  '',
					}
				}
				return buffers
			end

			opts.tabline = {
				lualine_a = { genTreeButton() },
				lualine_z = { genBufLine() }
			}

			require("lualine").setup(opts)
		end

		-- TODO: Enable retheming function in lua/status.lua
		-- > (explore ways this is possible with lua)
		-- > (of course, no need for this if we don't override the theme
		-- > 	behavior)

		-- Alias to jump buffers via the lualine index
		-- > These commands should not initalize Lualine as the information
		-- > upon which they depend would not be available until after it is
		-- > loaded - hence we place them in config()
		-- vim.cmd("cnorea b LualineBuffersJump")
		vim.cmd("ca bi LualineBuffersJump")
		vim.cmd("ca bindex LualineBuffersJump")
		vim.cmd("ca bid LualineBuffersDelete")
		-- TODO: bid -> Jump to buffer index and call :bd, then move to original buffer

		-- Keymaps for quickly jumping across open buffers (Lualine index)
		local mapBufferJump = function(index)
			local index_str = tostring(index)
			vim.keymap.set("n", "b" .. index_str,
				"<cmd>LualineBuffersJump " .. index_str .. "<cr>")
		end
		for index = 1, 9 do
			mapBufferJump(index)
		end

		require("lualine").setup(opts) -- Explicitly call setup for treebutton
	end
}

return spec
