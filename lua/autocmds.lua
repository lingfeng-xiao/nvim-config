require "nvchad.autocmds"

-- Filter DSR warning on Windows terminals (Neovim 0.12+)
local _orig_notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == "string" and msg:find("Did not detect DSR") then return end
  _orig_notify(msg, level, opts)
end