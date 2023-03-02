local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

vim.cmd([[
augroup packer_user_config
autocmd!
autocmd BufWritePost plugins.lua source <afile> | PackerSync
augroup end
]])

local packer_bootstrap = ensure_packer()

vim.cmd("packadd packer.nvim")

return require('packer').startup(function(use)
    use {"wbthomason/packer.nvim"}

    -- Mason for LSP and DAP installations
    use {
        'williamboman/mason.nvim',
        config = function ()
            require('mason').setup()
        end
    }

    -- Mason LSP
    use {
        'williamboman/mason-lspconfig.nvim',
        requires = {"neovim/nvim-lspconfig", "hrsh7th/nvim-cmp"},
        after = {"mason.nvim"},
        config = function ()
            require("mason-lspconfig").setup{
                ensure_installed = {"lua_ls", "rust_analyzer"}
            }

            require("mason-lspconfig").setup_handlers({
                -- The first entry (without a key) will be the default handler
                -- and will be called for each installed server that doesn't have
                -- a dedicated handler.
                function (server_name) -- default handler (optional)
                    local capabilities = require('cmp_nvim_lsp').default_capabilities()
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,
                ["rust_analyzer"] = function() end,
                ["lua_ls"] = function ()
                    local capabilities = require('cmp_nvim_lsp').default_capabilities()
                    require('lspconfig').lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim" }
                                }
                            }
                        }
                    }
                end,
            })
        end,
    }

    -- Mason DAP
    use {
        "jay-babu/mason-nvim-dap.nvim",
        requires = {"mfussenegger/nvim-dap"},
        after = {"mason.nvim"},
        config = function ()
            require("mason-nvim-dap").setup({
                ensure_installed = {"codelldb"},
                automatic_installation = true,
                --automatic_setup = true,
            })

            --require('mason-nvim-dap').setup_handlers {}
        end,
    }

    --Rust Tools
    use {
        'simrat39/rust-tools.nvim',
        after={"mason-lspconfig.nvim", "mason-nvim-dap.nvim", "which-key.nvim"},
        config = function ()
            local rt = require('rust-tools')

            local codelldb_command = "codelldb"
            if vim.fn.has('win32') == 1 then
                codelldb_command = "codelldb.cmd"
            end
            rt.setup{
                server = {
                    on_attach=function(_, bufnr)
                        local wk = require("which-key")

                        wk.register({
                            name="Rust Tools",
                            ["a"] = {rt.hover_actions.hover_actions, "Hover actions"},
                            ["c"] = {rt.code_action_group.code_action_group, "Code actions"},
                        }, {
                            prefix = "<leader>r",
                            buffer = bufnr
                        })
                    end,
                },
                dap = {
                    adapter = {
                        type="server",
                        port="${port}",
                        executable={
                            command=codelldb_command,
                            args={"--port", "${port}"}
                        }
                    }
                }
            }
        end
    }

    -- Completion framework:
    use {
        'hrsh7th/nvim-cmp',
        requires = {'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-nvim-lsp-signature-help',
        'hrsh7th/cmp-vsnip',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-buffer',
        'hrsh7th/vim-vsnip'},
        config = function ()
            local cmp = require'cmp'

            cmp.setup({
                -- Enable LSP snippets
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                -- Installed sources:
                mapping = {
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    -- Add tab support
                    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                    ['<Tab>'] = cmp.mapping.select_next_item(),
                    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.close(),
                    ['<CR>'] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    }),
                },
                sources = {
                    { name = 'path' },                              -- file paths
                    { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
                    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
                    { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
                    { name = 'buffer', keyword_length = 2 },        -- source current buffer
                    { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip 
                    { name = 'calc'},                               -- source for math calculation
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                formatting = {
                    fields = {'menu', 'abbr', 'kind'},
                    format = function(entry, item)
                        local menu_icon ={
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
    }

    -- TreeSitter
    use {
        'nvim-treesitter/nvim-treesitter',
        config = function ()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { "lua", "rust", "toml", "vim" },
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting=false,
                },
                ident = { enable = true },
                rainbow = {
                    enable = true,
                    extended_mode = true,
                    max_file_lines = nil,
                }
            }
        end,
    }

    -- Theme
    use {
        "ellisonleao/gruvbox.nvim",

        config = function ()
            require("gruvbox").setup({
                undercurl = true,
                underline = true,
                bold = true,
                italic = true,
                strikethrough = true,
                invert_selection = false,
                invert_signs = false,
                invert_tabline = false,
                invert_intend_guides = false,
                inverse = true, -- invert background for search, diffs, statuslines and errors
                contrast = "", -- can be "hard", "soft" or empty string
                palette_overrides = {},
                overrides = {},
                dim_inactive = false,
                transparent_mode = false,
            })
            vim.cmd("colorscheme gruvbox")
        end
    }

    -- Hop
    use {
        'phaazon/hop.nvim',
        branch = 'v2', -- optional but strongly recommended
        after = {'which-key.nvim'},
        config = function()
            -- you can configure Hop the way you like here; see :h hop-config
            local hop = require'hop'
            local wk = require'which-key'
            local directions = require('hop.hint').HintDirection

            hop.setup {}

            wk.register({["<leader>h"]={function () hop.hint_char1() end, "Hop"}},{mode="n"})

            wk.register({
                ['f']={function () hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true }) end, "Hop Next"},
                ['F']={function () hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true }) end, "Hop Previous"},
                ['t']={function () hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 }) end, "Hop Before Next"},
                ['T']={function () hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = -1 }) end, "Hop Before Previous"},
            }, {mode='n'});
        end
    }

    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release; cmake --build build --config Release; cmake --install build --prefix build' }

    -- Telescope
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        requires = { {'nvim-lua/plenary.nvim'} },
        after = {"telescope-fzf-native.nvim", 'project.nvim'},
        config = function ()
            require('telescope').setup{
                extentions = {
                    fzf = {
                        fuzzy = true,                    -- false will only do exact matching
                        override_generic_sorter = true,  -- override the generic sorter
                        override_file_sorter = true,     -- override the file sorter
                        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    },
                }
            }
            require('telescope').load_extension('projects')
            require('telescope').load_extension('fzf')
        end
    }

    use {'mhinz/vim-startify'}

    -- Nvim Tree
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons', -- optional, for file icons
        },
        config = function ()
            require("nvim-tree").setup{
                prefer_startup_root = true,
                sync_root_with_cwd = true,
                respect_buf_cwd = true,
                update_focused_file = {
                    enable = true,
                    update_root = true
                },
                view={
                    float={enable=true}
                }
            }
        end
    }

    -- Which Key
    use {
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end
    }

    -- Floating Terminal
    use {
        'voldikss/vim-floaterm',
        after = {'which-key.nvim'},
        config = function ()
            local wk = require'which-key'

            vim.cmd([[
            let g:floaterm_width = 0.4
            let g:floaterm_height = 0.9
            let g:floaterm_borderchars = "─│─│╭╮╯╰"
            let g:floaterm_position = "right"
            let g:floaterm_wintype = "vsplit"
            ]]);

            wk.register({
                ['<C-t>']={function () vim.cmd([[FloatermToggle myfloat]]) end, "toggle"},
            }, {mode={'n','t'}})
        end
    }

    -- Project
    use {
        'ahmedkhalf/project.nvim',
        config = function ()
            require'project_nvim'.setup {
                detection_methods = {'pattern'}
            }
        end
    }

    -- NeoGit
    use {
        'TimUntersberger/neogit',
        requires = 'nvim-lua/plenary.nvim',
        after = {"which-key.nvim"},
        config = function ()
            local neogit = require('neogit')
            local wk = require('which-key')

            neogit.setup {}

            wk.register({
                g={function () neogit.open() end, "Git"}
            },{mode='n', prefix="<leader>"})
        end
    }

    if packer_bootstrap then
        require('packer').sync()
    end
end)
