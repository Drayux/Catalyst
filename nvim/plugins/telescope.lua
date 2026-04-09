-- PLUGIN: telescope.nvim
-- SOURCE: https://github.com/nvim-telescope/telescope.nvim
-- LEVEL: CORE

-- Fuzzy finder utility

-- Options generator for choice telescope pickers that allows the inclusion of
-- hidden files to be toggled with a keybind - Always starts in hidden mode
-- NOTE: If inverting with _show, it is recommended to set prompt_title in opts
-- before calling toggle_find (else the + indicator cannot be appended on init)
-- > Adapted from https://github.com/nvim-telescope/telescope.nvim/issues/2874#issuecomment-1900967890
local toggle_find = function(picker_fn, opts, _show)
	opts = (type(opts) == "table") and opts or {}

	local title = opts.prompt_title -- or nil (holds original title)
	local state = require("telescope.actions.state")
	local toggle = function(prompt_bufnr)
		if prompt_bufnr then
			local picker = state.get_current_picker(prompt_bufnr)
			if not title then
				title = picker and picker.prompt_title or "<unknown>"
			end

			-- TODO: I don't think we need this line - it should be handled by picker:find()
			-- require("telescope.actions").close(prompt_bufnr)
		end

		opts.default_text = state.get_current_line()
		if opts.hidden then
			opts.hidden = false
			opts.no_ignore = false
			opts.prompt_title = title
		else
			opts.hidden = true
			opts.no_ignore = true
			if type(title) == "string" then
				opts.prompt_title = title .. " (+)"
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

	opts.attach_mappings = function(_, map_fn)
		map_fn({ "n", "i" }, "<C-h>", toggle)
		return true
	end

	if _show then
		-- Start with hidden files visible
		toggle()
	else
		-- Run the picker like normal
		picker_fn(opts)
	end
end

-- Wrapped :Telescope find_files
local ffplus = function()
	local picker = require("telescope.builtin").find_files
	toggle_find(picker)
end

-- Wrapped :Telescope live_grep
local lgplus = function()
	local picker = require("telescope.builtin").live_grep
	toggle_find(picker)
end

local spec = { 
	"nvim-telescope/telescope.nvim",	
	cond = condCORE,
	cmd = { "Telescope" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-ui-select.nvim", -- Setup sets vim.ui.select
		-- { "nvim-telescope/telescope-ui-select.nvim", -- Setup sets vim.ui.select
			-- cmd = { "CopilotChatModels" },
			-- config = function(_, opts)
				-- require("telescope").load_extension("ui-select")
			-- end
		-- },
	},
	opts = {
		-- This doesn't appear to work in this format: I'm not sure what to tweak just yet
		-- extensions = {
			-- "directory",
			-- "projections",
			-- "file_browser",
			-- "themes",
			-- "ui_select", -- nvim-telescope/telescope-ui-select.nvim
		-- },
		defaults = {
			mappings = {
				-- Close immediately on escape (rather than the weird double-escape by default)
				i = { ["<Esc>"] = "close" }
			}
		}
	},
	init = function()
		vim.g.telescope_enabled = true

		-- Plugin keybinds
		require("editor.binds").command("fe", "Telescope buffers")
		require("editor.binds").command("fs", "Telescope treesitter")

		require("editor.binds").set("n", "<leader>ff", ffplus)
		require("editor.binds").set("n", "<leader>fg", lgplus)
		require("editor.binds").set({ "n", "v" }, "\"", "<cmd>Telescope registers<cr>")

		vim.ui.select = function(items, opts, on_choice)
			-- Initiate telescope load
			require("telescope").load_extension("ui-select")

			-- Forward the params to the actual function
			vim.ui.select(items, opts, on_choice)
		end
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
		-- https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#loading-extensions

		-- Projections
		-- vim.keymap.set('n', '<leader>fp', "<cmd>Telescope projections<cr>")

		require("telescope").setup(opts)
	end
}

return spec
