require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "ts_ls", "lua_ls" },
})

-- UI Customization for LSP Diagnostics
vim.diagnostic.config({
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- Dynamically enable all LSP servers installed via Mason
local installed_servers = require("mason-lspconfig").get_installed_servers()

local capabilities = require("cmp_nvim_lsp").default_capabilities()

for _, server in ipairs(installed_servers) do
  -- Nvim 0.11+ native LSP enable
  if vim.lsp.config[server] then
    vim.lsp.config[server].capabilities = capabilities
    vim.lsp.enable(server)
  end
end