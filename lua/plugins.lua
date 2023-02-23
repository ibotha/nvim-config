vim.cmd("packadd packer.nvim")

return require('packer').startup(function()
    
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    use "jay-babu/mason-nvim-dap.nvim"

    use 'neovim/nvim-lspconfig'
    use 'simrat39/rust-tools.nvim'

    -- Completion framework:
    use 'hrsh7th/nvim-cmp'

    -- LSP completion source:
    use 'hrsh7th/cmp-nvim-lsp'

    -- Useful completion sources:
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-vsnip'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/vim-vsnip'

    use 'nvim-treesitter/nvim-treesitter'

    -- Rust Debugging
    use 'nvim-lua/plenary.nvim'
    use 'mfussenegger/nvim-dap'

    -- Theme
    use { "ellisonleao/gruvbox.nvim" }

    use {"wbthomason/packer.nvim", opt = true}

    use {
    	'phaazon/hop.nvim',
  	branch = 'v2', -- optional but strongly recommended
  	config = function()
    	-- you can configure Hop the way you like here; see :h hop-config
    	require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
  	end
    }

    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use {
	    'nvim-tree/nvim-tree.lua',
	    requires = {
		    'nvim-tree/nvim-web-devicons', -- optional, for file icons
	    },
    }
end)
