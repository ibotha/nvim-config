return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("lsp")
		end,
		dependencies = {
			{
				"mfussenegger/nvim-lint",
				event = { "BufReadPost", "BufNewFile" },
				config = function()
					local nvim_lint = require("lint")
					nvim_lint.linters_by_ft = require("lsp.nvim-lint").linters_by_ft

					vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost" }, {
						group = vim.api.nvim_create_augroup("NvimLint", {}),
						callback = function()
							nvim_lint.try_lint()
						end,
					})
				end,
			},
			{
				"stevearc/conform.nvim",
				config = function()
					require("conform").setup({
						formatters_by_ft = require("lsp.conform-nvim").formatters_by_ft,
						format_on_save = {
							lsp_format = "fallback",
							timeout_ms = 500,
						},
					})
				end,
				event = { "BufWritePre" },
				keys = {
					{
						"<Leader>F",
						function()
							require("conform").format({
								async = true,
								lsp_fallback = true,
							})
						end,
						mode = { "n", "v" },
						desc = "Format",
					},
				},
			},
			{
				"williamboman/mason.nvim",
				config = true,
				build = ":MasonUpdate",
			},
			{ "williamboman/mason-lspconfig.nvim", config = true },
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "simrat39/rust-tools.nvim" },
			{ "simrat39/rust-tools.nvim" },
			"nvim-telescope/telescope.nvim",
			{ "folke/neodev.nvim", opts = {} },
		},
	},
}
