local formatters_by_ft = {
	lua = { "stylua" },
	python = { "ruff" },
	cmake = { "cmakelang" },
}

local prettierd_filetypes = {
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
	"vue",
	"css",
	"scss",
	"less",
	"html",
	"json",
	"jsonc",
	"yaml",
	"toml",
	"markdown",
	"markdown.mdx",
	"graphql",
	"handlebars",
}

for _, prettierd_filetype in ipairs(prettierd_filetypes) do
	local existing_ft_formatters = formatters_by_ft[prettierd_filetype]

	if existing_ft_formatters ~= nil then
		table.insert(existing_ft_formatters, "prettierd")
	else
		formatters_by_ft[prettierd_filetype] = { "prettierd" }
	end
end

return {
	formatters_by_ft = formatters_by_ft,
}
