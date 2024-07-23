return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	dependencies = {
		{
			"echasnovski/mini.icons",
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
			version = false,
			config = function()
				require("mini.icons").setup()
				MiniIcons.mock_nvim_web_devicons()
			end,
		},
	},
	keys = {
		{ "<C-h>", "<CMD>WhichKey<CR>", desc = "Which Key" },
	},
	opts = {
		triggers = {
			{ "<leader>", mode = { "n", "v" } },
		},
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
}
