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

local files = require("files")
local buffers = require("buffer")
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
				local bufferList = {
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
				return bufferList
			end

			opts.tabline = {
				lualine_a = { genTreeButton() },
				lualine_z = { genBufLine() }
			}
		end
		require("lualine").setup(opts) -- Explicitly call setup for treebutton


		-- TODO: Enable retheming function in lua/status.lua
		-- > (explore ways this is possible with lua)
		-- > (of course, no need for this if we don't override the theme behavior)


		-- BUFFER SWAPPING (NAVIGATION)
		-- > These commands should not initalize Lualine as the information
		-- > upon which they depend would not be available until after it is
		-- > loaded - hence we place them in config()

		-- Helper function to return the index of the current buffer
		-- TODO: This might be possible to improve, right now it's just a simple search
		local getIndex = function()
			local llbuf = require("lualine.components.buffers")
			local current = vim.api.nvim_get_current_buf()

			for index, buffer in pairs(llbuf.bufpos2nr) do
				if buffer == current then
					return index
				end
			end
		end

		-- Helper function to verify the range of a buffer swap
		-- Returns nil or a positive integer
		local checkRange = function(index)
			-- Default to current buffer if no args provided
			_, idx = pcall(tonumber, index or 0)
			if not idx or (idx < 0) then 
				return nil
			end

			-- Peek at the Lualine's internal buffer list
			local llbuf = require("lualine.components.buffers")
			return (idx <= #llbuf.bufpos2nr) and idx
				or nil
		end

		-- Replace the buffer in the current window with another via lualines buffer indexing
		local swapBufferIndex = function(index)
			local target = checkRange(index)
			if not target then
				vim.notify("Invalid buffer index: " .. tostring(index or "<none>"), vim.log.levels.WARN)
			elseif target == 0 then
				-- Utility branch to display the index of the current buffer
				target = getIndex()
				vim.notify("Current buffer index: " .. tostring(target), vim.log.levels.INFO)
			else
				require("lualine.components.buffers").buffer_jump(target)
			end
			return target
		end
		
		-- Create a user command that wraps swapBufferIndex
		vim.api.nvim_create_user_command("BufferIndexSwap", function(args)
				local argstr = args.args -- Maximum of one argument is supported (no need for fargs)
				if #argstr == 0 then
					swapBufferIndex(nil) -- Call with no specified buffer
				else
					swapBufferIndex(argstr)
				end
			end, {
			nargs = "?",
			desc = "Swap to a buffer, indexed by the Lualine buffers index",
			bang = false,
		})

		-- Delete an arbitrary buffer via index
		-- NOTE: Lualine itself provides no interface for deleting buffers in
		-- > this way, so we will "break" this layer of API, and work one level
		-- > up in order to create what it would be
		local closeBufferIndex = function(index, bang)
			local target_idx = checkRange(index)
			if not target_idx then
				vim.notify("Invalid buffer index: " .. tostring(index or "<none>"), vim.log.levels.WARN)
				return -- nil
			end

			local llbuf = require("lualine.components.buffers")
			local target = (target_idx > 0) and llbuf.bufpos2nr[target_idx]
				or 0

			buffers.closeBuffer(target, bang)
		end

		-- Create a user command that wraps closeBufferIndex
		vim.api.nvim_create_user_command("BufferIndexClose", function(args)
				local argstr = args.args -- Maximum of one argument is supported (no need for fargs)
				if #argstr == 0 then
					closeBufferIndex(nil, args.bang) -- Call with no specified buffer
				else
					closeBufferIndex(argstr, args.bang)
				end
			end, {
			nargs = "?",
			desc = "Close a buffer, indexed by the Lualine buffers index",
			bang = true,
		})

		-- Keymaps for quickly jumping across open buffers (Lualine index)
		for index = 1, 10 do
			local index_str = tostring(index % 10)
			local jumpClosure = function()
				-- We know values of index, so this is just a range check
				-- > (i.e. b8 when only 3 buffers are open)
				if checkRange(index) then
					require("lualine.components.buffers").buffer_jump(index)
				else
					vim.notify("Buffer index does not exist!", vim.log.levels.WARN)
				end
			end
			map("n", "b" .. index_str, jumpClosure)
		end

		-- Create builtin-like vim commands (abbreviations)
		-- > TODO: This can conflict with /bi during a search command
		vim.cmd("ca bi BufferIndexSwap")
		vim.cmd("ca bid BufferIndexClose")
	end
}

return spec
