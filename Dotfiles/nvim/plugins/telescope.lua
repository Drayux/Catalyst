-- PLUGIN: telescope.nvim
-- SOURCE: https://github.com/nvim-telescope/telescope.nvim
-- LEVEL: CORE

-- Fuzzy finder utility

-- Options generator for choice telescope pickers that allows the inclusion of
-- hidden files to be toggled with a keybind - Always starts in hidden mode
-- > Adapted from https://github.com/nvim-telescope/telescope.nvim/issues/2874#issuecomment-1900967890
local _toggler = function(picker_fn, _title)
	local opts; opts = {
		attach_mappings = function(_, map_fn)
			local toggle = function(prompt_bufnr)
				local prompt_text = require("telescope.actions.state").get_current_line()
				require("telescope.actions").close(prompt_bufnr)

				opts.default_text = prompt_text
				if opts.hidden then
					opts.hidden = false
					opts.no_ignore = false
					opts.prompt_title = _title
				else
					opts.hidden = true
					opts.no_ignore = true
					if type(_title) == "string" then
						opts.prompt_title = _title .. " (+)"
					end
				end

				-- This looks like a recursive call, but (I think) it is leak-safe!
				-- Telescope's :find() call returns immediately, spawning an async
				-- thread to handle the picker logic, so the hide mapping would spawn
				-- a new picker instance in the same "async type of vibe" that any
				-- regular keybind would.
				-- TLDR: Neovim's event handler is the parent function in the call
				-- stack that invokes the new picker, not the picker logic itself,
				-- despite the nested closure ref. (I think.)
				picker_fn(opts)
			end

			map_fn({ "n", "i" }, "<C-h>", toggle)
			return true
		end,

		-- Defaults - modified by attach_mappings
		hidden = false,
		no_ignore = false,
		prompt_title = _title
	}

	picker_fn(opts)
end

-- Wrapped :Telescope find_files
local ffplus = function()
	local picker = require("telescope.builtin").find_files
	local title = "Find Files"
	_toggler(picker, title)
end

-- Wrapped :Telescope live_grep
local lgplus = function()
	local picker = require("telescope.builtin").live_grep
	local title = "Live Grep"
	_toggler(picker, title)
end

local spec = { 
	"nvim-telescope/telescope.nvim",	
	cond = condCORE,
	cmd = { "Telescope" },
	dependencies = { 'nvim-lua/plenary.nvim' },
	init = function()
		vim.g.telescope_enabled = true

		-- Plugin keybinds
		require("editor.binds").command("fe", "Telescope buffers")
		require("editor.binds").command("fs", "Telescope treesitter")

		require("editor.binds").set("n", "<leader>ff", ffplus)
		require("editor.binds").set("n", "<leader>fg", lgplus)
	end,
	config = function(_, opts)
		-- Load plugin integrations
		if vim.g.themer_enabled then
			local _, api = pcall(require, "editor.colors")
			if api then
				local extmgr = require("telescope._extensions").manager
				extmgr["themes"] = { themes = api.extension }
			end
		end

		-- Load extensions early so that their autocompletes are generated
		-- opts = { extensions = { "directory", "projections", "file_browser", "themes" }}
		-- telescope.load_extension(ext)

		-- Projections
		-- vim.keymap.set('n', '<leader>fp', "<cmd>Telescope projections<cr>")
	end
}

return spec
