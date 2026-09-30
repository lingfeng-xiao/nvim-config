-- Shared Vim-first actions. The JSON manifest is the key/label source for both editors.
local M = {}
local path = vim.fn.stdpath('config') .. '/vim-first-keymap.json'

local function read_spec()
  local lines = vim.fn.readfile(path)
  if #lines == 0 then error('Missing Vim-first keymap: ' .. path) end
  return vim.json.decode(table.concat(lines, '\n'))
end

function M.explorer_toggle_focus()
  if vim.bo.filetype == 'NvimTree' then
    vim.cmd('wincmd p')
  else
    vim.cmd('NvimTreeFocus')
  end
end

function M.terminal_toggle()
  local buf = vim.g.vim_first_terminal_buf
  if buf and vim.api.nvim_buf_is_valid(buf) then
    local windows = vim.fn.win_findbuf(buf)
    if #windows > 0 then
      if #vim.api.nvim_tabpage_list_wins(0) > 1 then
        vim.api.nvim_win_close(windows[1], true)
      else
        vim.cmd('wincmd p')
      end
      return
    end
  end
  vim.cmd('botright split')
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_win_set_buf(0, buf)
  else
    vim.cmd('terminal')
    vim.g.vim_first_terminal_buf = vim.api.nvim_get_current_buf()
  end
  vim.cmd('startinsert')
end

local function resolve(action)
  if action == 'vim-first.explorer-toggle-focus' then return M.explorer_toggle_focus end
  if action == 'vim-first.terminal-toggle' then return M.terminal_toggle end
  if action == 'vim-first.cheatsheet' then return function() require('configs.cheatsheet').open() end end
  local direction = action:match('^vim%-first%.window%-(%a+)$')
  local window_command = { left = 'h', right = 'l', up = 'k', down = 'j' }
  if window_command[direction] then
    return function() vim.cmd('wincmd ' .. window_command[direction]) end
  end
  if action == 'vim-first.window-vsplit' then return function() vim.cmd('vsplit') end end
  if action == 'vim-first.window-split' then return function() vim.cmd('split') end end
  if action == 'vim.diagnostic.jump-prev' then return function() vim.diagnostic.jump({ count = -1 }) end end
  if action == 'vim.diagnostic.jump-next' then return function() vim.diagnostic.jump({ count = 1 }) end end
  if action:sub(1, 8) == 'vim.lsp.' then
    local name = action:match('^vim%.lsp%.buf%.([%w_]+)$')
    assert(name and type(vim.lsp.buf[name]) == 'function', 'Unknown LSP action: ' .. action)
    return vim.lsp.buf[name]
  end
  if action:sub(1, 10) == 'Telescope ' then
    local picker = action:sub(11)
    return function() vim.cmd('Telescope ' .. picker) end
  end
  if action == 'bdelete' then return function() vim.cmd('bdelete') end end
  error('Unknown Vim-first action: ' .. action)
end

function M.setup()
  local spec = read_spec()
  assert(spec.leader == '<Space>')
  for _, b in ipairs(spec.bindings) do
    if b.nvim ~= vim.NIL then
      local action = resolve(b.nvim)
      vim.keymap.set(b.visual and { 'n', 'x' } or 'n', b.keys, action,
        { desc = b.label, silent = true })
    end
  end
  -- Tree-local keyboard return; never consumes these keys in an editor or shell.
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'NvimTree',
    callback = function(ev)
      for _, key in ipairs({ 'q', '<Esc>' }) do
        vim.keymap.set('n', key, M.explorer_toggle_focus,
          { buffer = ev.buf, desc = 'Return to editor', silent = true })
      end
    end,
  })
  vim.keymap.set('t', '<C-A-e>', '<C-\\><C-n><C-w>p',
    { desc = 'Return to editor', silent = true })
end

return M
