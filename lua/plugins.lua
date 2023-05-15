return {
	-- Mason
	{
		'williamboman/mason.nvim',
		config = function()
			require('mason').setup()
		end
	},

	-- Mason LSP
	{
		'williamboman/mason-lspconfig.nvim',
		dependencies = { "neovim/nvim-lspconfig", "hrsh7th/nvim-cmp" },
		config = function()
			require("mason-lspconfig").setup {
				ensure_installed = { "lua_ls", "rust_analyzer" }
			}
			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('UserLspConfig', {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					local wk = require('which-key')

					wk.register({
						f = { function() vim.lsp.buf.format() end, "Format" },
						n = { function() vim.lsp.buf.rename() end, "Rename" },
						c = { function() vim.lsp.buf.code_action() end, "Code Action" }
					}, { prefix = "<leader>l", buffer = ev.buf })
				end,
			})
			require("mason-lspconfig").setup_handlers({
				-- The first entry (without a key) will be the default handler
				-- and will be called for each installed server that doesn't have
				-- a dedicated handler.
				function(server_name) -- default handler (optional)
					local capabilities = require('cmp_nvim_lsp').default_capabilities()
					require("lspconfig")[server_name].setup {
						capabilities = capabilities,
					}
				end,
				["rust_analyzer"] = function()
				end,
				["lua_ls"] = function()
					local capabilities = require('cmp_nvim_lsp').default_capabilities()
					require('lspconfig').lua_ls.setup {
						capabilities = capabilities,
					}
				end,
			})
			local sign = function(opts)
				vim.fn.sign_define(opts.name, {
					texthl = opts.name,
					text = opts.text,
					numhl = ''
				})
			end

			sign({ name = 'DiagnosticSignError', text = '' })
			sign({ name = 'DiagnosticSignWarn', text = '' })
			sign({ name = 'DiagnosticSignHint', text = '' })
			sign({ name = 'DiagnosticSignInfo', text = '' })

			vim.diagnostic.config({
				virtual_text = {
					prefix = '',
					spacing = 2,
					source = 'if_many',
				},
				signs = true,
				update_in_insert = true,
				underline = false,
				severity_sort = true,
			})

			vim.cmd([[
            set signcolumn=yes
            ]])
		end,
	},

	-- Mason DAP
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("mason-nvim-dap").setup({
				ensure_installed = { "codelldb" },
				automatic_installation = true,
				--automatic_setup = true,
			})

			--require('mason-nvim-dap').setup_handlers {}
			local wk = require 'which-key'
			local dap = require 'dap'
			local dap_widgets = require 'dap.ui.widgets'

			dap.defaults.fallback.terminal_win_cmd = 'tabnew'
			vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = 'DapBreakpoint', linehl = '', numhl = '' })

			wk.register({
				name = "DAP",
				b = { dap.toggle_breakpoint, "Toggle Breakpoint" },
				c = { dap.continue, "Continue" },
				o = { dap.step_over, "Step Over" },
				i = { dap.step_into, "Step Into" },
				r = { dap.repl.open, "REPL" },
				h = { dap_widgets.hover, "Hover" },
				p = { dap_widgets.preview, "Preview" },
				f = { function()
					dap_widgets.centered_float(dap_widgets.frames)
				end, "Frames" },
				s = { function()
					dap_widgets.centered_float(dap_widgets.scopes)
				end, "Scopes" },
			}, { mode = 'n', prefix = '<leader>d' })
		end,
	},

	--Neodev: Sets up lua-lsp for nvim configurations so that it isn't so ass.
	{
		'folke/neodev.nvim',
		config = function()
			require("neodev").setup({
				-- add any options here, or leave empty to use the default settings
			})
		end
	},

	--Rust Tools
	{
		'simrat39/rust-tools.nvim',
		ft = 'rust',
		config = function()
			local rt = require('rust-tools')

			local codelldb_command = "codelldb"
			if vim.loop.os_uname == "Windows_NT" then
				codelldb_command = "codelldb.cmd"
			end
			rt.setup {
				server = {
					on_attach = function(_, bufnr)
						local wk = require("which-key")

						wk.register({
							name = "Rust Tools",
							["a"] = { rt.hover_actions.hover_actions, "Hover actions" },
							["c"] = { rt.code_action_group.code_action_group, "Code actions" },
							["r"] = { rt.runnables.runnables, "Runnables" },
							["e"] = { rt.expand_macro.expand_macro, "Expand Macro" },
							["d"] = { rt.debuggables.debuggables, "Debuggables" },
							["j"] = { function() rt.move_item.move_item(false) end, "Move Down" },
							["k"] = { function() rt.move_item.move_item(true) end, "Move Up" },
							["~"] = { rt.open_cargo_toml.open_cargo_toml, "Open cargo.toml" },
							["p"] = { rt.parent_module.parent_module, "Parent Module" },
						}, {
							prefix = "<leader>r",
							buffer = bufnr
						})
					end,
				},
				dap = {
					adapter = {
						type = "server",
						port = "${port}",
						executable = {
							command = codelldb_command,
							args = { "--port", "${port}" },
							detached = not vim.loop.os_uname == "Windows_NT",
						},
					}
				}
			}
		end
	},

	-- Completion framework:
	{
		'hrsh7th/nvim-cmp',
		dependencies = { 'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-nvim-lua',
			'hrsh7th/cmp-nvim-lsp-signature-help',
			'hrsh7th/cmp-vsnip',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-buffer',
			'hrsh7th/vim-vsnip' },
		config = function()
			local cmp = require 'cmp'

			cmp.setup({
				-- Enable LSP snippets
				snippet = {
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body)
					end,
				},
				-- Installed sources:
				mapping = {
					['<C-k>'] = cmp.mapping.select_prev_item(),
					['<C-j>'] = cmp.mapping.select_next_item(),
					-- Add tab support
					['<C-h>'] = cmp.mapping.scroll_docs(-4),
					['<C-l>'] = cmp.mapping.scroll_docs(4),
					['<C-a>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.close(),
					['<C-y>'] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Insert,
						select = true,
					}),
				},
				completion = {
					autocomplete = false
				},
				sources = {
					{ name = 'path' },                    -- file paths
					{ name = 'nvim_lsp' },                -- from language server
					{ name = 'nvim_lsp_signature_help' }, -- display function signatures with current parameter emphasized
					{ name = 'nvim_lua' },                -- complete neovim's Lua runtime API such vim.lsp.*
					{ name = 'buffer' },                  -- source current buffer
					{ name = 'vsnip' },                   -- nvim-cmp source for vim-vsnip
					{ name = 'calc' },                    -- source for math calculation
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					fields = { 'menu', 'abbr', 'kind' },
					format = function(entry, item)
						local menu_icon = {
							nvim_lsp = 'λ',
							vsnip = '⋗',
							buffer = 'Ω',
							path = '🖫',
						}
						item.menu = menu_icon[entry.source.name]
						return item
					end,
				},
			})
		end
	},

	-- TreeSitter
	{
		'nvim-treesitter/nvim-treesitter',
		config = function()
			require('nvim-treesitter.configs').setup {
				ensure_installed = { "lua", "rust", "toml", "vim" },
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				ident = { enable = true },
				rainbow = {
					enable = true,
					extended_mode = true,
					max_file_lines = nil,
				}
			}
			vim.cmd([[
        set foldmethod=expr
        set foldexpr=nvim_treesitter#foldexpr()
        set nofoldenable                     " Disable folding at startup.
        ]])
		end,
	},

	-- Theme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				style = "moon",         -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
				light_style = "day",    -- The theme is used when the background is set to light
				transparent = true,     -- Enable this to disable setting the background color
				terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
				styles = {
					-- Style to be applied to different syntax groups
					-- Value is any valid attr-list value for `:help nvim_set_hl`
					comments = { italic = true },
					keywords = { italic = true },
					functions = {},
					variables = {},
					-- Background styles. Can be "dark", "transparent" or "normal"
					sidebars = "transparent",     -- style for sidebars, see below
					floats = "dark",              -- style for floating windows
				},
				sidebars = { "qf", "help" },      -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
				day_brightness = 0.3,             -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
				hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
				dim_inactive = false,             -- dims inactive windows
				lualine_bold = false,             -- When `true`, section headers in the lualine theme will be bold
			})
			vim.cmd("colorscheme tokyonight")
		end
	},

	-- Lua Line
	{
		'nvim-lualine/lualine.nvim',
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons", "arkav/lualine-lsp-progress" },
		config = function()
			require('lualine').setup {
				options = {
					theme = 'horizon'
				},
				sections = {
					lualine_a = { 'mode' },
					lualine_b = { 'branch', 'diff', 'diagnostics' },
					lualine_c = { 'filename', 'lsp_progress' },
					lualine_x = { 'encoding', 'fileformat', 'filetype' },
					lualine_y = { 'progress' },
					lualine_z = { 'location' }
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { 'filename' },
					lualine_x = { 'location', 'encoding', 'fileformat', 'filetype' },
					lualine_y = {},
					lualine_z = {}
				},
			}
		end
	},

	-- Hop
	{
		'phaazon/hop.nvim',
		branch = 'v2', -- optional but strongly recommended
		config = function()
			-- you can configure Hop the way you like here; see :h hop-config
			local hop = require 'hop'
			local wk = require 'which-key'

			hop.setup {}

			wk.register({ ["<leader>h"] = { function() hop.hint_char1() end, "Hop" } }, { mode = "n" })
		end
	},

	-- fzf-native
	{
		'nvim-telescope/telescope-fzf-native.nvim',
		build =
		'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release; cmake --build build --config Release; cmake --install build --prefix build'
	},

	-- Telescope
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.1',
		dependencies = { 'nvim-lua/plenary.nvim', 'ahmedkhalf/project.nvim' },
		lazy = false,
		config = function()
			require('telescope').setup {
				extentions = {
					fzf = {
						fuzzy = true,                   -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true,    -- override the file sorter
						case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
						-- the default case_mode is "smart_case"
					},
				}
			}
			require('telescope').load_extension('fzf')
			local wk = require("which-key")

			-- Location bindings
			wk.register({
				["<leader>"] = {
					f = {
						name = "Find",
						f = { function() require('telescope.builtin').find_files() end, "Files" },
						b = { function() require('telescope.builtin').buffers() end, "Buffers" },
						k = { function() require('telescope.builtin').keymaps() end, "Keymaps" },
						r = { function() require('telescope.builtin').resume() end, "Resume" },
						t = { function() require('telescope.builtin').current_buffer_fuzzy_find() end, "Text in buffer" },
						T = { function() require('telescope.builtin').live_grep() end, "Text in workspace" },
						d = { function() require('telescope.builtin').diagnostics() end, "Diagnostics" },
					},
					l = {
						name = "LSP",
						r = { function() require('telescope.builtin').lsp_references() end, "References" },
						[','] = { function() require('telescope.builtin').lsp_incoming_calls() end, "Incoming Calls" },
						['.'] = { function() require('telescope.builtin').lsp_outgoing_calls() end, "Outgoing Calls" },
						d = { function() require('telescope.builtin').lsp_definitions() end, "Definition" },
						D = { function() require('telescope.builtin').diagnostics() end, "Diagnostics" },
						t = { function() require('telescope.builtin').lsp_type_definitions() end, "Type Definition" },
						i = { function() require('telescope.builtin').lsp_implementations() end, "Implementation" },
						s = {
							name = "Symbols",
							d = { function() require('telescope.builtin').lsp_document_symbols() end, "In Document" },
							w = { function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
								"In Workspace" },
						}
					}
				},
				g = {
					F = { function() require('telescope.builtin').find_files() end, "Files" },
					d = { function() require('telescope.builtin').lsp_definitions() end, "Definition" },
					i = { function() require('telescope.builtin').lsp_implementations() end, "Implementation" },
					t = { function() require('telescope.builtin').current_buffer_fuzzy_find() end, "Text in buffer" },
				},
			}, {
				mode = "n",
				prefix = "",
			})
		end
	},

	-- Nvim Tree
	{
		'nvim-tree/nvim-tree.lua',
		dependencies = {
			'nvim-tree/nvim-web-devicons', -- optional, for file icons
		},
		lazy = false,
		config = function()
			require("nvim-tree").setup {
				prefer_startup_root = true,
				actions = {
					open_file = {
						quit_on_open = true,
					}
				}
			}
			local wk = require("which-key")

			-- Location bindings
			wk.register({
				e = { function() require('nvim-tree').focus() end, "Explore" }
			}, {
				mode = "n",
				prefix = "<leader>",
			})
		end
	},

	-- Which Key
	{
		"folke/which-key.nvim",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup {
			}
		end
	},

	-- Fugitive
	{
		'tpope/vim-fugitive',
		lazy = false,
		config = function()
			local wk = require('which-key')

			wk.register({
				g = { function() vim.cmd("Git") end, "Git" }
			}, { mode = 'n', prefix = "<leader>" })
		end
	},

	-- Undo Tree
	{
		'mbbill/undotree',
		config = function()
			local wk = require('which-key')

			wk.register({
				u = { function() vim.cmd("UndotreeToggle") end, "Undotree" }

			}, { mode = 'n', prefix = "<leader>" })
		end
	},

	-- Github Co-Pilot
	{
		'github/copilot.vim',
		config = function()
			local wk = require('which-key')

			vim.cmd("Copilot setup")
			wk.register({
				["<leader>c"] = {
					name = "Co-Pilot",
					e = { function() vim.cmd("Copilot enable") end, "Enable Co-pilot" },
					d = { function() vim.cmd("Copilot disable") end, "Disable Co-pilot" },
				}
			}, { mode = 'n' })
		end
	}
}
