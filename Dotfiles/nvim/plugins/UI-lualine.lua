-- PLUGIN: lualine.nvim
-- SOURCE: https://github.com/nvim-lualine/lualine.nvim

-- Customizable status line

--------------
-- For reference
local colors = {
	black  = "#080808",
	grey   = "#303030",
	white  = "#c6c6c6",
	red    = "#ff5189",
	orange = "#fa9a55",
	green  = "#80ff82",
	cyan   = "#79dac8",
	blue   = "#80a0ff",
	purple = "#a877ed",
	violet = "#d183e8",
}

local theme = {
	normal = {
		a = { fg = colors.black, bg = colors.blue },
		b = { fg = colors.white, bg = colors.grey },
		c = { fg = colors.white },
	},

	insert = { a = { fg = colors.black, bg = colors.green }},
	visual = { a = { fg = colors.black, bg = colors.cyan }},
	replace = { a = { fg = colors.black, bg = colors.orange }},
	command = { a = { fg = colors.black, bg = colors.purple }},

	inactive = {
		a = { fg = colors.white, bg = colors.black },
		b = { fg = colors.white, bg = colors.black },
		c = { fg = colors.white },
	},
}
--------------


local plugin = {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			component_separators = "",
			section_separators = { left = "", right = "" },
			disabled_filetypes = { "neo-tree", "neo-tree-popup", "notify" },
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
			},
		},
		inactive_sections = {
			lualine_a = { "filename" },
			lualine_z = { "location" },
		},
		-- winbar = {
		-- 	lualine_c = { "buffers" },
		-- },
		-- inactive_winbar = {
		-- 	lualine_c = { "filename" },
		-- },
		tabline = {
			-- lualine_a = { treebutton() },
			lualine_z = {
				-- {
				-- 	"tabs",
				-- },
				{	"buffers",
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
					-- buffers_color = {
					-- 	active = 'lualine_{section}_normal',
					-- 	inactive = 'lualine_{section}_inactive',
					-- },

					symbols = {
						modified = ' ●',      -- Text to show when the buffer is modified
						alternate_file = '', -- Text to show to identify the alternate file
						directory =  '',     -- Text to show when the buffer is a directory
					}},
			},
		},
		extensions = {},
	},
	config = function(_, opts)
		local treebutton = function()
			local status, api = pcall(require, "neo-tree")
			if not status then return nil end

			-- TODO: This function is duplicated from plugins/UI-neotree.lua
			local manager = require("neo-tree.sources.manager")
			local renderer = require("neo-tree.ui.renderer")
			local getState ; getState = function(source, ...)
				-- Recursive base case
				if not source then return false end

				local state = manager.get_state(source)
				return renderer.window_exists(state)
					or getState(...) -- Recursion will stop if the window is found
			end
			---

			return {
				-- Display a (   /  ) icon for the button
				function()
					if getState("filesystem", "document_symbols", "buffers", "git_status") then
						return ""
					end

					return ""
				end,

				on_click = function()
					vim.cmd("Neotoggle")
				end
			}
		end

		opts.tabline.lualine_a = { treebutton() }
		require("lualine").setup(opts)

		-- Akin to LualineBuffersJump, delete an arbitrary buffer via index
		-- TODO: For some reason, using the BANG causes the window to close in the same conditions
		-- that not using the bang would not
		local LualineBuffersDelete = function(argtable)
			local idx = argtable.args
			if #idx == 0 then idx = 0
			else
				_, idx = pcall(tonumber, argtable.args)
				if not idx then 
					print("Could not close `" .. tostring(idx) .. "`")
					return
				end
			end

			-- sp  : Split screen
			-- LualineBuffersJump : Jump to the previous buffer
			-- bd!(?) : Delete current buffer (including the split, so the new one takes its place)
			--	^^Original split has the active buffer before deleting

			if idx > 0 then
				vim.cmd("bp")
			end

			vim.cmd("sp")
			vim.cmd("LualineBuffersJump " .. tostring(idx))
			vim.cmd("bd" .. (argtable.bang and "!" or ""))
		end
		vim.api.nvim_create_user_command("LualineBuffersDelete", LualineBuffersDelete, {
			nargs = "?",
			desc = "Delete a buffer, indexed by the Lualine buffers index",
			bang = true,
		})

		-- Alias to jump buffers via the lualine index
		-- vim.cmd("cnorea b LualineBuffersJump")
		vim.cmd("ca bi LualineBuffersJump")
		vim.cmd("ca bindex LualineBuffersJump")
		vim.cmd("ca bid LualineBuffersDelete")

		-- TODO: bid -> Jump to buffer index and call :bd, then move to original buffer
	end
}

return plugin

