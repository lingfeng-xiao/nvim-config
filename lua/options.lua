require "nvchad.options"

local o = vim.o

-- 相对行号（便于 vim 跳转）
o.relativenumber = true
o.number         = true

-- 缩进
o.tabstop     = 2
o.shiftwidth  = 2
o.expandtab   = true
o.smartindent = true

-- 搜索
o.ignorecase = true
o.smartcase  = true

-- 系统剪贴板（与 Windows 共享）
o.clipboard = "unnamedplus"

-- 滚动留边
o.scrolloff  = 8
o.sidescrolloff = 8

-- 更新响应时间（ms）
o.updatetime = 200

-- 光标行高亮
o.cursorline    = true
o.cursorlineopt = "both"

-- 已安装 JetBrainsMonoNerdFont，开启 Nerd Font 图标支持
vim.g.have_nerd_font = true
