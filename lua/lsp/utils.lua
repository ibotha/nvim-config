local M = {}

local function setup_lsp_keymaps(_client, bufnr)
	local wk = require("which-key")

	wk.add({
		{ "<Leader>gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", desc = "Go to declaration", buffer = bufnr },
		{
			"<Leader>gd",
			function()
				require("telescope.builtin").lsp_definitions()
			end,
			desc = "Go to definition",
			buffer = bufnr,
		},
		{
			"<Leader>gi",
			function()
				require("telescope.builtin").lsp_implementations()
			end,
			desc = "Go to implementation",
			buffer = bufnr,
		},
		{
			"<Leader>gr",
			function()
				require("telescope.builtin").lsp_references()
			end,
			desc = "Go to references",
			buffer = bufnr,
		},
		{ "<Leader>c", group = "Call hierarchy", buffer = bufnr },
		{
			"<Leader>ci",
			function()
				require("telescope.builtin").lsp_incoming_calls()
			end,
			desc = "Go to incoming calls",
			buffer = bufnr,
		},
		{
			"<Leader>co",
			function()
				require("telescope.builtin").lsp_outgoing_calls()
			end,
			desc = "Go to outgoing calls",
			buffer = bufnr,
		},
		{
			"<Leader>t",
			function()
				require("telescope.builtin").lsp_type_definitions()
			end,
			desc = "Go to type definition",
			buffer = bufnr,
		},
		{
			"<Leader>sS",
			function()
				require("telescope.builtin").lsp_document_symbols()
			end,
			desc = "Local Symbols",
			buffer = bufnr,
		},
		{
			"<Leader>sW",
			function()
				require("telescope.builtin").lsp_workspace_symbols()
			end,
			desc = "Symbols",
			buffer = bufnr,
		},
		{
			"<C-W>gd",
			"<cmd>tab split | norm gd<CR>",
			desc = "Go to definition in a new tab",
			buffer = bufnr,
		},
		{ "<Leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Rename", buffer = bufnr },
		{
			"<leader>d",
			function()
				vim.diagnostic.open_float()
			end,
			desc = "Show diagnostics for current line",
			buffer = bufnr,
		},
		{
			"<leader>ac",
			"<cmd>lua vim.lsp.buf.code_action()<CR>",
			desc = "Code actions",
			mode = { "v", "n" },
			buffer = bufnr,
		},
		{
			"<leader>q",
			function()
				require("telescope.builtin").diagnostics({ bufnr = 0 })
			end,
			desc = "Show all diagnostics in location list",
			buffer = bufnr,
		},
		{
			"<leader>Q",
			function()
				require("telescope.builtin").diagnostics()
			end,
			desc = "Show all diagnostics in location list",
			buffer = bufnr,
		},
		{ "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", desc = "Show signature help", buffer = bufnr },
		{
			"<C-j>",
			"<cmd>lua vim.lsp.buf.signature_help()<CR>",
			desc = "Show signature help",
			mode = "i",
			buffer = bufnr,
		},
	})
end

local function setup_document_highlight(client)
	if not client.supports_method("textDocument/documentHighlight") then
		return
	end

	vim.cmd([[
    hi LspReferenceText  cterm=bold ctermbg=red guibg=#404040
    hi LspReferenceRead  cterm=bold ctermbg=red guibg=#404040
    hi LspReferenceWrite cterm=bold ctermbg=red guibg=#404040
    augroup LSPDocumentHighlight
      autocmd! * <buffer>
      autocmd CursorHold,CursorHoldI  <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    augroup END
  ]])
end

function M.on_attach(client, bufnr)
	vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

	setup_lsp_keymaps(client, bufnr)
	setup_document_highlight(client)
end

-- See https://github.com/hrsh7th/cmp-nvim-lsp
-- Takes care of autocomplete support using snippets for some LSP servers (cssls, jsonls)
local ok, cmp_capabilities = pcall(function()
	return require("cmp_nvim_lsp").default_capabilities()
end)
if ok then
	M.capabilities = cmp_capabilities
else
	M.capabilities = vim.lsp.protocol.make_client_capabilities()
end

-- https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
M.capabilities = vim.tbl_deep_extend("force", M.capabilities, {
	textDocument = {
		foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		},
	},
})

-- Return a function that runs functions passed in the argument.
-- They will be called in the same order that they were passed in.
-- Useful for composing multiple `on_attach` functions.
---@diagnostic disable-next-line: unused-vararg
function M.run_all(...)
	local fns = { ... }

	return function(...)
		for _, fn in ipairs(fns) do
			fn(...)
		end
	end
end

-- Disables formatting for an LSP client
-- Useful when multiple clients are capable of formatting
-- but we want to enable only one of them.
function M.disable_formatting(client)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

-- Base config for LSP's setup method
M.base_config = {
	on_attach = M.on_attach,
	capabilities = M.capabilities,
}

-- Base config for LSP's setup method that disables client's formatting
-- Useful when there is another client that is responsible for formatting.
M.base_config_without_formatting = vim.tbl_extend("force", M.base_config, {
	on_attach = M.run_all(M.disable_formatting, M.on_attach),
})

--- https://github.com/hrsh7th/nvim-cmp/blob/fc0f694af1a742ada77e5b1c91ff405c746f4a26/lua/cmp/view/custom_entries_view.lua#L207
local completions_menu_zindex = 1001
M.zindex = {
	completions_menu = completions_menu_zindex,
	--- https://github.com/hrsh7th/nvim-cmp/blob/fc0f694af1a742ada77e5b1c91ff405c746f4a26/lua/cmp/view/docs_view.lua#L104
	completion_documentation = 50,
	lsp_signature = completions_menu_zindex + 1,
}

return M
