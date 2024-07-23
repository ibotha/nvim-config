return {
    "nvim-treesitter/nvim-treesitter",
    init = function()
        -- Treesitter folding 
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
        vim.wo.foldenable = false
    end,
    build = ":TSUpdate"
}
