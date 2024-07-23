return {
	on_attach = require("lsp.utils").on_attach,
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
		},
	},
}
