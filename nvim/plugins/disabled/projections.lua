-- PLUGIN: projections.nvim
-- SOURCE: https://github.com/GnikDroy/projections.nvim
-- LEVEL: USER

-- Workspace/session management
-- Includes a telescope extension ('projections')
-- TODO: Consider setting up project.nvim to auto add projects for projections to use
-- TODO: Consider enabling/disabling projections based upon work or home computer

local plugin = {
	'gnikdroy/projections.nvim',
	cond = condUSER,
	lazy = false,
	opts = {
		patterns = { ".git" },
		workspaces = {
			"~/Projects",
		},
		store_hooks = {
			pre = function()
				-- Close nvim-tree before saving the session (if present)
				local ntstatus, ntapi = pcall(require, "nvim-tree.api")
	            if ntstatus then ntapi.tree.close() end
			end
		},
		restore_hooks = {
			post = function()
				-- Focus nvim-tree when loading a session (if present)
				-- Relevant for swapping workspaces (not opening the editor)
				local ntstatus, ntapi = pcall(require, "nvim-tree.api")
	            if ntstatus then ntapi.tree.focus() end
			end
		}
	},
	config = function(_, opts)
		require("projections").setup(opts)

		-- Autostore session on VimExit
		local session = require("projections.session")
		vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
			callback = function() session.store(vim.loop.cwd()) end
		})
	end
}

return plugin

-- Alternative: project.nvim (does not do session management)
-- local plugin = {
-- 	"ahmedkhalf/project.nvim",
-- 	lazy = false,
-- 	opts = {
-- 		-- https://github.com/ahmedkhalf/project.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
-- 		manual_mode = true,
-- 		detection_methods = { "lsp", "pattern" },
-- 		patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
-- 		ignore_lsp = {},
-- 		exclude_dirs = {},
-- 		show_hidden = false,
-- 		silent_chdir = true,
-- 		scope_chdir = 'global',
-- 		datapath = vim.fn.stdpath("data"),
-- 	},
-- 	config = function(_, opts)
-- 		require("project_nvim").setup(opts)
-- 	end
-- }
-- 
-- return plugin
