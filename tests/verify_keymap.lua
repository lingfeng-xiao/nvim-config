vim.g.mapleader = ' '
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.rtp:prepend(vim.fn.stdpath('config'))
require('vim_first').setup()

local function invoke(lhs)
  for _, mapping in ipairs(vim.api.nvim_get_keymap('n')) do
    if mapping.lhs:lower() == lhs:lower() then
      assert(mapping.callback, 'Expected Lua callback for ' .. lhs)
      mapping.callback()
      return
    end
  end
  error('Missing mapping: ' .. lhs)
end

for _, lhs in ipairs({ '<C-H>', '<C-J>', '<C-K>', '<C-L>', ' t', ' wv', ' ws', ' ff', ' fg', ' fb', ' e', ' bd' }) do
  for _, mapping in ipairs(vim.api.nvim_get_keymap('n')) do
    if mapping.lhs:lower() == lhs:lower() then goto found end
  end
  error('Missing mapping: ' .. lhs)
  ::found::
end

local first = vim.api.nvim_get_current_win()
invoke(' wv')
local right = vim.api.nvim_get_current_win()
assert(first ~= right and #vim.api.nvim_tabpage_list_wins(0) == 2, 'Vertical split failed')
invoke('<C-H>')
assert(vim.api.nvim_get_current_win() == first, 'Focus left failed')
invoke('<C-L>')
assert(vim.api.nvim_get_current_win() == right, 'Focus right failed')
invoke(' ws')
local lower = vim.api.nvim_get_current_win()
assert(#vim.api.nvim_tabpage_list_wins(0) == 3, 'Horizontal split failed')
invoke('<C-K>')
assert(vim.api.nvim_get_current_win() ~= lower, 'Focus up failed')
invoke('<C-J>')
assert(vim.api.nvim_get_current_win() == lower, 'Focus down failed')

assert(vim.fn.maparg('<Tab>', 'n') == '', 'Ctrl-i jumplist overridden')
for _, key in ipairs({ 's', 'S', 'r', 'R' }) do
  assert(vim.fn.maparg(key, 'n') == '', 'Native Vim key overridden: ' .. key)
end
print('Neovim Vim-first keymap verified')
