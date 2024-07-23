return {
	"ibotha/crates.nvim",
	event = "BufRead Cargo.toml",
	branch = "main",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local crates = require("crates")
		local wk = require("which-key")

		crates.setup({
			open_programs = { "start", "xdg-open", "open" },
			on_attach = function(bufnr)
				wk.add({
					{ "<leader>C", group = "Crates", buffer = bufnr },
					{ "<leader>Ct", crates.toggle, desc = "Toggle", buffer = bufnr },
					{ "<leader>Cu", crates.update_crate, desc = "Update Crate", buffer = bufnr },
					{ "<leader>CU", crates.update_all_crates, desc = "Update All", buffer = bufnr },
					{ "<leader>Cx", crates.expand_plain_crate_to_inline_table, desc = "Expand", buffer = bufnr },
					{ "<leader>CX", crates.extract_crate_into_table, desc = "Extract", buffer = bufnr },
					{ "<leader>Ch", crates.open_homepage, desc = "Home Page", buffer = bufnr },
					{ "<leader>Cr", crates.open_repository, desc = "Repository", buffer = bufnr },
					{ "<leader>Cd", crates.open_documentation, desc = "Documentation", buffer = bufnr },
					{
						"<leader>Cv",
						function()
							crates.show_versions_popup()
							crates.focus_popup()
						end,
						desc = "Versions",
						buffer = bufnr,
					},
					{
						"<leader>Cf",
						function()
							crates.show_features_popup()
							crates.focus_popup()
						end,
						desc = "Features",
						buffer = bufnr,
					},
					{
						"<leader>CD",
						function()
							crates.show_dependencies_popup()
							crates.focus_popup()
						end,
						desc = "Dependencies",
						buffer = bufnr,
					},
				})
			end,
		})
	end,
}
