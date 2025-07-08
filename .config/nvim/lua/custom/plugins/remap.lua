vim.g.mapleader = ' '
-- vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
-- vim.opt_local.spell = true
-- vim.opt_local.spelllang = { 'en_us' }
vim.keymap.set('n', '<leader>di', function()
  vim.diagnostic.open_float(nil, { source = true })
end, { desc = 'Check the Diagnostics' })
vim.keymap.set('n', '<leader>cw', function()
  local word = vim.fn.expand '<cword>'
  local dict_path = vim.fn.expand '~/.config/cspell/custom-words.txt'

  -- Append word
  local file = io.open(dict_path, 'a')
  if file then
    file:write(word .. '\n')
    file:close()
    print('✅ Added to CSpell dictionary: ' .. word)
  else
    print('❌ Failed to open dictionary at ' .. dict_path)
    return
  end

  -- Sort and deduplicate
  os.execute(string.format('sort -u %s -o %s', dict_path, dict_path))

  -- Refresh diagnostics
  local bufnr = vim.api.nvim_get_current_buf()
  vim.diagnostic.reset(nil, bufnr) -- clear existing
  vim.lsp.buf.clear_references() -- optional, may help with LSP states
  vim.lsp.buf_request(bufnr, 'textDocument/publishDiagnostics', {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
  }, function() end)

  -- Trigger re-diagnostics manually
  vim.lsp.buf.document_highlight() -- soft re-trigger
  vim.cmd 'edit' -- hard refresh (reloads buffer)
end, { desc = 'Add word to cspell dictionary and reload diagnostics' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
vim.keymap.set('x', '<leader>pk', '"_dp', { desc = '[P]aste and [K]eep' })

vim.keymap.set('n', '<leader>r', function()
  vim.cmd 'write'
  local file = vim.fn.expand '%:p'
  vim.fn.system {
    'tmux',
    'split-window',
    '-v',
    string.format("bash -c \"python3 '%s'; echo ''; echo '[ press enter to exit ]'; read\"", file),
  }
end, {
  noremap = true,
  silent = true,
  desc = 'Run current Python file in new tmux pane (pause after exit)',
})
vim.keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })
vim.keymap.set('n', 'n', 'nzzzv', { noremap = true, silent = true })
vim.keymap.set('n', '<C-]>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-[>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { noremap = true, silent = true })
vim.keymap.set('n', 'G', 'Gzz', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>w', ':wa<CR>', { desc = 'Write all buffers' })

local function setup_python_folds()
  vim.opt_local.foldmethod = 'indent'
  vim.opt_local.foldlevel = 99
  vim.opt_local.foldenable = true
end

-- Trigger when a Python file is opened normally
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    setup_python_folds()
  end,
})

-- Trigger if you launch nvim without a file, then open one later with :e
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.py',
  callback = function()
    if vim.bo.filetype == 'python' then
      setup_python_folds()
    end
  end,
})
return {}
