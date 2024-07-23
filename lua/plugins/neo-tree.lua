return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"folke/which-key.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	init = function()
		-- disable netrw at the very start of your init.lua
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- optionally enable 24-bit colour
		vim.opt.termguicolors = true
	end,
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			window = {
				mappings = {
					["l"] = "open",
				},
			},
		})
		local wk = require("which-key")
		wk.add({
			{ "<leader>f", group = "File" },
			{ "<leader>ft", "<cmd>Neotree reveal<CR>", desc = "Tree" },
		})
	end,
}
