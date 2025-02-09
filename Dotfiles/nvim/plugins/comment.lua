-- PLUGIN: comment.nvim
-- SOURCE: https://github.com/numToStr/Comment.nvim
-- LEVEL: USER

-- Extra comment string functionality

local escapeKey = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
local spec = {
	"numToStr/Comment.nvim",
	cond = condUSER,
	opts = {
		ignore = "^$", -- Ignore empty lines (lua match str)
		mappings = {
			basic = false,
			extra = false
		},
	},
	init = function()
		-- Toggles the current line and `count` following lines (add comment if mixed)
		local toggleLine = function()
			local mode = vim.api.nvim_get_mode().mode
			if mode == "v"
				or mode == "V"
				-- or mode == "^V"
			then
				vim.api.nvim_feedkeys(escapeKey, "nx", false)
				require("Comment.api").toggle.linewise(mode)
			else
				local count = (vim.v.count > 0) and vim.v.count or 1
				require("Comment.api").toggle.linewise.count(count)
			end
		end

		-- Uncomment all targeted lines (toggle prioritizes commenting)
		local uncommentLine = function()
			local utils = require("Comment.utils")
			local mode = vim.api.nvim_get_mode().mode

			-- Leave visual mode if active
			if mode == "v" or mode == "V" then
				vim.api.nvim_feedkeys(escapeKey, "nx", false)
			else
				mode = "line" -- Convert to Comment.nvim's expected format
			end

			local range = utils.get_region(mode)
			local lines = utils.get_lines(range)

			-- Recreate internal API to construct the "comment context"
			-- > https://github.com/numToStr/Comment.nvim/blob/master/lua/Comment/opfunc.lua#L46
			local left_cs, right_cs = utils.parse_cstr({}, {
				cmode = utils.cmode.uncomment,
				cmotion = "line",
				ctype = utils.ctype.linewise,
				range = range,
			})

			-- Closures to perform the uncomment operation
			-- > Boolean params enable padding (yes please, daddy!)
			local check = utils.is_commented(left_cs, right_cs, true)
			local uncomment = utils.uncommenter(left_cs, right_cs, true)
			local changes = false
			for idx, line in pairs(lines) do
				if check(line) then
					lines[idx] = uncomment(line)
					changes = true
				end
			end

			-- TODO: Currently, nvim_buf_set_lines has a bug where all marks that are
			-- > within the changed content region are cleared
			-- > Currently only in the nightly builds is the vim._with function, which
			-- > should resolve this bug
			-- > https://github.com/neovim/neovim/pull/29168

			-- Call nvim api to update the buffer
			-- vim._with({ lockmarks = true }, function()
				if changes then
					vim.api.nvim_buf_set_lines(0, range.srow - 1, range.erow, false, lines)
				else
					vim.notify("Nothing to uncomment!", vim.log.levels.WARN)
				end
			-- end)

			-- Re-enter previous visual mode selection
			-- if mode == "v" or mode == "V" then
				-- vim.api.nvim_feedkeys("gv", "nx", false)
			-- end
		end

		-- Uncomment a multline comment if exists, else create a new one from the motion
		local toggleBlock = function()
			-- local count = (vim.v.count > 0) and vim.v.count or 1
			require("Comment.api").toggle.blockwise()
		end

		-- Set keybinds (will invoke lazy load)
		local EDITOR = { "n", "v" } -- Taken directly from layout (keymaps)
		map(EDITOR, "xc", toggleLine, { expr = true })
		map(EDITOR, "xC", uncommentLine, { expr = true })

		-- block commenting
		-- normal mode xd -> Take o-pending and always comment that much
		-- normal mode xD -> Uncomment entire surrounding block
		-- visual modes follow suit
		-- Visual mode uncomment (xD) should ignore visual block and uncomment
		-- > at cursor??

		-- TODO: What to do if toggling linewise inside of a block?
		-- map(EDITOR, "xd", toggleBlock, { expr = true })
	end
}

return spec

