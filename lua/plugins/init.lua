-- VSCode 环境检测：在 VSCode 内禁用不兼容的插件
local is_vscode = vim.g.vscode ~= nil

return {
  -- ---- 格式化（VSCode 内禁用，由 VSCode 自身处理）----
  {
    "stevearc/conform.nvim",
    enabled = not is_vscode,
    event   = "BufWritePre",
    opts    = require "configs.conform",
  },

  -- ---- LSP（VSCode 内禁用，由 VSCode Language Server 处理）----
  {
    "neovim/nvim-lspconfig",
    enabled = not is_vscode,
    config  = function()
      require "configs.lspconfig"
    end,
  },

  -- ---- Treesitter（VSCode 内禁用：无编译器 + VSCode 自带高亮）----
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = not is_vscode,
    build   = ":TSUpdate",
    config  = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "vim", "lua", "vimdoc",
          "html", "css", "javascript", "typescript",
          "json", "yaml", "toml",
          "java", "python", "bash",
          "markdown", "markdown_inline",
          "xml", "sql",
        },
        highlight    = { enable = true },
        indent       = { enable = true },
        auto_install = true,
      }
    end,
  },

  -- ---- Git 集成（VSCode 内禁用，由 GitLens 处理）----
  {
    "lewis6991/gitsigns.nvim",
    enabled = not is_vscode,
    event   = "BufReadPre",
    opts    = {
      signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "󰍵" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
      },
      current_line_blame = true,
    },
  },

  -- ---- 多光标（VSCode 内禁用，VSCode 自带 Ctrl+D）----
  {
    "mg979/vim-visual-multi",
    enabled = not is_vscode,
    event   = "BufReadPost",
  },

  -- ---- 括号自动补全（VSCode 内禁用，VSCode 自带）----
  {
    "windwp/nvim-autopairs",
    enabled = not is_vscode,
    event   = "InsertEnter",
    opts    = {},
  },

  -- ---- 环绕操作（两端都启用，纯文本操作无依赖）----
  {
    "kylechui/nvim-surround",
    version = "*",
    event   = "VeryLazy",
    opts    = {},
  },

  -- ---- which-key：注册分组标签（两端都启用，纯文本配置无副作用）----
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require "configs.whichkey"
    end,
  },
}
