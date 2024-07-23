return vim.tbl_deep_extend("keep", require("lsp.utils").base_config, {
	settings = {
		pylsp = {
			plugins = {
				configurationSources = { "flake8" },
				flake8 = {
					enabled = false,
				},
				pycodestyle = {
					enabled = false,
				},
			},
		},
	},
})
