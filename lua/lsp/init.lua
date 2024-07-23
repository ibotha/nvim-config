require("lsp.filetypes")
local utils = require("lsp.utils")

local default_server_config = utils.base_config

---Configs for known LSP servers.
local server_configs = {
	lua_ls = require("lsp.lua"),
	rust_analyzer = default_server_config,
	ruff_lsp = default_server_config,
	--jedi_language_server = default_server_config,
	pylsp = require("lsp.python"),
}

local mason_lspconfig = require("mason-lspconfig")
local function get_servers_to_install()
	local configured_server_names = vim.tbl_keys(server_configs)
	local available_servers_map = mason_lspconfig.get_mappings().lspconfig_to_mason

	return vim.tbl_filter(function(server_name)
		return available_servers_map[server_name] ~= nil
	end, configured_server_names)
end

mason_lspconfig.setup({
	ensure_installed = get_servers_to_install(),
})

---@param top_level_table table<string, unknown>
---@return string[]
local function get_all_values_deep(top_level_table)
	---@type table<string, boolean>
	local values = {}

	---@param tbl table<string, unknown>
	local function walk_table(tbl)
		for _, value_or_tbl in pairs(tbl) do
			if type(value_or_tbl) == "table" then
				walk_table(value_or_tbl)
			else
				values[value_or_tbl] = true
			end
		end
	end

	walk_table(top_level_table)

	return vim.tbl_keys(values)
end

local function get_linters_to_install()
	return get_all_values_deep(require("lsp.nvim-lint").linters_by_ft)
end

local function get_formatters_to_install()
	return get_all_values_deep(require("lsp.conform-nvim").formatters_by_ft)
end

require("mason-tool-installer").setup({
	ensure_installed = vim.tbl_filter(function(tool_name)
		return require("mason-registry").has_package(tool_name)
	end, vim.list_extend(get_formatters_to_install(), get_linters_to_install())),
})

local lspconfig = require("lspconfig")
local function setup_lsp_servers()
	for server_name, server_config in pairs(server_configs) do
		lspconfig[server_name].setup(server_config)
	end
end

setup_lsp_servers()

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "single",
	zindex = utils.zindex.lsp_signature,
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })

vim.diagnostic.config({
	float = {
		scope = "line",
		source = true,
		border = "single",
	},
	jump = {
		wrap = false,
	},
})

local function use_icons_for_diagnostic_signs()
	-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-diagnostic-symbols-in-the-sign-column-gutter
	vim.diagnostic.config({
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚 ",
				[vim.diagnostic.severity.WARN] = "󰀪 ",
				[vim.diagnostic.severity.HINT] = "󰌶 ",
				[vim.diagnostic.severity.INFO] = " ",
			},
			linehl = {},
			numhl = {
				[vim.diagnostic.severity.WARN] = "WarningMsg",
				[vim.diagnostic.severity.ERROR] = "ErrorMsg",
			},
		},
	})
end

use_icons_for_diagnostic_signs()
