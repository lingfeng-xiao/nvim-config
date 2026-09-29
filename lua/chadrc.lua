---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",

  -- 覆盖 cheatsheet 配色，让分组标题更醒目
  hl_override = {
    -- 分组标题：蓝底黑字（比默认随机色更一致）
    NvChHeading = { fg = "black", bg = "blue", bold = true },
    -- 内容区：略深背景，层次清晰
    NvChSection = { fg = "white", bg = "black2" },
  },
}

M.ui = {
  tabufline = { lazyload = true },
  telescope = { style = "bordered" },
}

-- NvChad 内置速查表：simple 单列布局比 grid 更易扫读
-- excluded_groups 过滤内置噪音，只显示自定义按键
M.cheatsheet = {
  theme = "simple",
  excluded_groups = {
    "terminal (t)", "autopairs", "Nvim", "Opens",
    "general (v)", "general (i)",
  },
}

return M
