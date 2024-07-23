return vim.tbl_deep_extend("keep", require("lsp.utils").base_config, {
	settings = {
		pylsp = {
			plugins = {
				configurationSources = { "flake8" },
				flake8 = {
					enabled = false,
				},
				jedi_completion = {
					eager = false, -- Attempts to eagerly resolve documentation and detail.
					--rename = false
				},
				pycodestyle = {
					enabled = false,
				},
				pyflakes = {
					enabled = false,
				},
				pylint = {
					enabled = false,
				},
				pylsp_mypy = {
					enabled = false,
					live_mode = true,
				},
			},
		},
	},
})
