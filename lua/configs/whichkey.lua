-- The same manifest drives Neovim mappings, Cursor menu entries and the cheatsheet.
local wk = require('which-key')
wk.setup({
  preset = 'modern',
  delay = 120,
})
local path = vim.fn.stdpath('config') .. '/vim-first-keymap.json'
local spec = vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))
local registered = {}
for _, b in ipairs(spec.bindings) do
  if b.nvim ~= vim.NIL then
    local prefix = b.keys:match('^<leader>(.)')
    if prefix and #b.keys > #'<leader>' + 1 and not registered[prefix] then
      local group = b.group
      if prefix == 'c' then group = 'Code / Help' end
      wk.add({ { '<leader>' .. prefix, group = group } })
      registered[prefix] = true
    end
    wk.add({ { b.keys, desc = b.label } })
  end
end
