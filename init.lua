-- NvChad init.lua
vim.g.base46_cache = vim.fn.stdpath("data") .. "/lazy/base46"
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")

-- Set leader to space BEFORE loading anything
vim.g.mapleader = " "

require("lazy").setup("nvchad.plugins")

-- Load custom chadrc first
pcall(require, "chadrc")

-- Load NvChad core from plugin
require("nvchad")

-- Load local nvchad config (options, mappings, autocmds)
require("nvchad.options")
require("nvchad.mappings")
vim.schedule(function()
  require("nvchad.autocmds")
end)

-- Load custom LSP config after NvChad defaults
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- TypeScript / JavaScript
    vim.lsp.config('ts_ls', {
      capabilities = capabilities,
      cmd = { vim.fn.expand("~/.local/bin/typescript-language-server"), "--stdio" },
      filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    })

    -- Java (jdtls)
    local jdtls_cmd = vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/bin/jdtls")
    if vim.fn.executable(jdtls_cmd) == 1 then
      vim.lsp.config('jdtls', {
        capabilities = capabilities,
        cmd = { jdtls_cmd },
      })
    end

    -- Enable configured servers
    vim.lsp.enable('ts_ls', true)
    vim.lsp.enable('jdtls', true)
  end,
})