local M = {}
local ui = { buffer = nil, window = nil }

local function lines_from_spec()
  local path = vim.fn.stdpath('config') .. '/vim-first-keymap.json'
  local spec = vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))
  local lines = {
    'VIM FIRST  ·  Neovim + Cursor',
    'Space = Which Key (120 ms)  ·  Space ch = this sheet  ·  Esc / q = close',
    '',
    'NATIVE VIM',
    '  hjkl / wbe / 0^$ / fFtT / % / motions and text objects',
    '  / ? * # n N · v V Ctrl-v · . · macros · marks',
    '  Ctrl-o/i · Neovim native Ctrl-w · gt/gT',
    '  Caps tap = Esc · Caps hold = Ctrl',
    '  Normal / tree: Ctrl+h/j/k/l moves focus; Insert / shell keeps its keys',
    '',
  }
  local groups = { 'LSP', 'Diagnostics', 'Code', 'Rename', 'Files', 'Explorer', 'Buffers', 'Windows', 'Terminal', 'Help', 'AI' }
  for _, group in ipairs(groups) do
    local added = false
    for _, b in ipairs(spec.bindings) do
      if b.group == group then
        if not added then table.insert(lines, group:upper()); added = true end
        local note = b.nvim ~= vim.NIL and '' or '  [Cursor only]'
        table.insert(lines, string.format('  %-14s %s%s', b.keys:gsub('<leader>', 'Space '), b.label, note))
      end
    end
    if added then table.insert(lines, '') end
  end
  table.insert(lines, 'Explorer: Space e focuses tree; inside tree Space e / q / Esc returns.')
  table.insert(lines, 'Terminal: Space t toggles; Ctrl+Alt+E returns to editor.')
  table.insert(lines, 'AI context: Space ac applies only to a Visual selection in Cursor.')
  table.insert(lines, 'AI: Cursor only. Space as remains unbound.')
  return lines
end

function M.close()
  if ui.window and vim.api.nvim_win_is_valid(ui.window) then vim.api.nvim_win_close(ui.window, true) end
  if ui.buffer and vim.api.nvim_buf_is_valid(ui.buffer) then vim.api.nvim_buf_delete(ui.buffer, { force = true }) end
  ui.window, ui.buffer = nil, nil
end

function M.open()
  if ui.window and vim.api.nvim_win_is_valid(ui.window) then M.close(); return end
  local lines = lines_from_spec()
  local width = math.min(83, math.max(40, vim.o.columns - 4))
  local height = math.min(#lines, math.max(8, vim.o.lines - 4))
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor', style = 'minimal', border = 'rounded',
    width = width, height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
  })
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  for _, key in ipairs({ 'q', '<Esc>' }) do
    vim.keymap.set('n', key, M.close, { buffer = buf, silent = true })
  end
  ui.buffer, ui.window = buf, win
end

return M
