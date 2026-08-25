-- PLUGIN: copilot.lua
-- SOURCE: 
-- LEVEL: USER

-- Copilot language server
-- (Supplies the language server as well as neovim interface to it so that it
-- need not be installed system-wide)

-- TODO: Not sure if the LSP should be just the Mason manager stuff, or also
-- all the tools that go alongside it. (For example, the copilot stuff, which
-- needs the LSP to work...but isn't really just an LSP from an organization
-- standpoint.)

local previous_provider = nil

local spec = {
	"zbirenbaum/copilot.lua", -- https://github.com/zbirenbaum/copilot.lua
	event = { "BufEnter *.c", "BufEnter *.h" },
	cmd = { "Copilot" },
	dependencies = {
		-- "neovim/nvim-lspconfig",
		"giuxtaposition/blink-cmp-copilot",
		{ "saghen/blink.cmp", -- TODO: Probably want to move this elsewhere
			branch = "v1",
			opts = {
				sources = {
					-- default = { "buffer", "snippets", "path", "copilot" },
					default = { "buffer", "copilot" },

					-- require("blink.cmp").add_provider("copilot", {
						-- <same opts as below>
					-- })
					providers = {
						copilot = {
							name = "copilot",
							module = "blink-cmp-copilot",
							-- async = true,
							-- score_offset = -100,
						}
					}
				},
				completion = {
					menu = {
						auto_show = false
					}
				},
				keymap = {
					preset = "none",
					["<Tab>"] = {
						function(cmp)
							-- Return early if the cursor is on whitespace
							local cursor = vim.api.nvim_win_get_cursor(0)
							if cursor then
								local line = vim.api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], false)[1] -- last arg clamps range
								local text = line:sub(1, cursor[2])
								if not text or text:match("^%s*$") then
									-- NOTE: This may be incompatbile with advanced TAB functionality if I add it in the future
									return "\t"
								end
							end
							-- If the suggestions window is already open, move to next operation
							local _PROVIDER_NAME = "buffer"
							if require("blink.cmp.completion.windows.menu").win:is_open() then
								if previous_provider == _PROVIDER_NAME then
									-- Begin the next selection
									return false
								end
							end

							-- Otherwise, show the suggestions popup window with our provider
							cmp.show({
								providers = { _PROVIDER_NAME },
								initial_selected_item_idx = 1
							})
							previous_provider = _PROVIDER_NAME
							return true
						end,
						"select_next",
						"fallback"
					},
					["<S-Tab>"] = {
						function(cmp)
							-- (No whitespace check for copilot suggestions)

							-- If the suggestions window is already open, move to next operation
							local _PROVIDER_NAME = "copilot"
							if require("blink.cmp.completion.windows.menu").win:is_open() then
								if previous_provider == _PROVIDER_NAME then
									-- Begin the next selection
									return false
								end
							end

							-- Otherwise, show the suggestions popup window with our provider
							cmp.show({
								providers = { _PROVIDER_NAME },
								auto_insert = false,
							})
							previous_provider = _PROVIDER_NAME
							return true
						end,
						"select_next",
						"fallback"
					},
					["\\"] = {
						-- function(cmp) end, -- TODO: Consider doing nothing if copilot provider is open
						"select_prev",
						"fallback"
					},
					["<Esc>"] = { "cancel", "fallback" },
					["<Enter>"] = { "accept", "fallback" },
					["<Up>"] = { "select_prev" },
					["<Down>"] = { "select_next" },
				}
			},
		},
		{ "copilotc-nvim/copilotchat.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {
				model = "gpt-4.1",
				window = {
					width = 0.333,
				},
				-- mappings = {},
			},
			init = function(plugin)
				-- Configure window settings
				vim.api.nvim_create_autocmd("BufEnter", {
					pattern = "copilot-*",
					callback = function()
						vim.opt_local.number = false
						vim.opt_local.conceallevel = 0
						vim.opt_local.wrap = true
					end,
				})
			end
		}
	},
	opts = {
		-- Primary use of this plugin is the bundled copilot LSP server
		panel = { enabled = false },

		-- Secondary use is completions; This could also be implemented with a language LSP (like clangd)
		suggestion = { enabled = false },

		-- The NES implementation in this plugin depends on another;
		-- Instead, all of NES will be made available through our main interface plugin: Sidekick
		nes = { enabled = false },
		filetypes = {
			c = true,
			cpp = true,
			h = true,
			["*"] = false -- Disable defaults
		},
	},
	-- Sane LSP client config for the Copilot server
	-- Commented because the copilot.lua plugin ignores this and generates its
	-- own from the options table we provide (above^^)
	--[[ init = function(plugin)
		vim.lsp.config["copilot"] = {
			cmd = {
				'copilot-language-server',
				'--stdio',
			},
			root_markers = { '.git' },
			init_options = {
				editorInfo = {
					name = 'Neovim',
					version = tostring(vim.version()),
				},
				editorPluginInfo = {
					name = 'Neovim',
					version = tostring(vim.version()),
				},
			}
		}
	end, ]]
}

return spec
