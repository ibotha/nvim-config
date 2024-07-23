return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/which-key.nvim",
	},
	keys = {
		{ "<Leader>s", group = "Search" },
		{
			"<Leader>sf",
			function()
				require("telescope.builtin").find_files()
			end,
			desc = "Files",
		},
		{
			"<Leader>st",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Text",
		},
		{
			"<Leader>sb",
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "Buffers",
		},
		{
			"<Leader>sc",
			function()
				require("telescope.builtin").commands()
			end,
			desc = "Commands",
		},
		{
			"<Leader>ss",
			function()
				require("telescope.builtin").spell_suggest()
			end,
			desc = "Spelling",
		},
		{
			"<Leader>sr",
			function()
				require("telescope.builtin").resume()
			end,
			desc = "Resume",
		},
		{
			"<Leader>sp",
			function()
				require("telescope.builtin").pickers()
			end,
			desc = "Pickers",
		},
	},
	config = function()
		require("telescope").setup()
	end,
}
