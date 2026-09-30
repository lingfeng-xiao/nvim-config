vim.g.mapleader = ' '
vim.opt.rtp:prepend(vim.fn.stdpath('config'))
local plugin = vim.env.WHICH_KEY_PLUGIN_DIR
assert(plugin and plugin ~= '', 'Set WHICH_KEY_PLUGIN_DIR to the installed which-key.nvim directory')
vim.opt.rtp:prepend(plugin)

require('vim_first').setup()
require('configs.whichkey')
local wk = require('which-key')
assert(wk.did_setup, 'Which Key setup was not called')
assert(vim.fn.exists(':WhichKey') == 2, 'Which Key command was not registered')
assert(#wk._queue > 0, 'Shared key labels were not registered')

require('configs.cheatsheet').open()
local sheet = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
for _, label in ipairs({ 'WINDOWS', 'Space wv', 'Space ws', 'Space t', 'Cursor only' }) do
  assert(sheet:find(label, 1, true), 'Cheatsheet is missing ' .. label)
end
print('Neovim Which Key setup and cheatsheet verified')
