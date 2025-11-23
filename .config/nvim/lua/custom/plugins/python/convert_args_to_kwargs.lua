local ts_utils = require 'nvim-treesitter.ts_utils'

local function get_root(buffer)
  local parser = vim.treesitter.get_parser(buffer, 'python')
  local tree = parser:parse()[1]
  return tree:root()
end

local function node_at_cursor_fallback()
  local buffer = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local root = get_root(buffer)
  return root:named_descendant_for_range(row - 1, col, row - 1, col)
end

local function find_parent_call_node(node)
  while node do
    if node:type() == 'call' then
      return node
    end
    node = node:parent()
  end
  return nil
end

local function convert_args_to_kwargs()
  -- Save original cursor
  local original_pos = vim.api.nvim_win_get_cursor(0)

  -- Move to end of line
  local row = original_pos[1]
  local last_col = #vim.api.nvim_get_current_line()
  vim.api.nvim_win_set_cursor(0, { row, last_col })

  local node = node_at_cursor_fallback()
  if not node then
    print 'Cursor not on a Treesitter node.'
    return
  end

  local call_node = find_parent_call_node(node)
  if not call_node then
    print 'No function call node found.'
    return
  end

  local func_node = call_node:field('function')[1]
  local args_node = call_node:field('arguments')[1]
  if not func_node or not args_node then
    print 'Could not extract call structure.'
    return
  end

  local function get_lsp_definition_location()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result)
      if err or not result or vim.tbl_isempty(result) then
        print 'Could not find function definition via LSP'
        return
      end

      local def = result[1]
      local uri = def.uri or def.targetUri
      local range = def.range or def.targetSelectionRange
      local filename = vim.uri_to_fname(uri)

      vim.fn.bufload(filename)
      local bufnr = vim.fn.bufnr(filename)
      local start_line = range.start.line
      local line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1]
      print('Definition line: ', line)
    end)
  end
  print(get_lsp_definition_location())
  local full_func_name = vim.treesitter.get_node_text(func_node, 0)
  -- get the actual function name, in case of object.method calls
  if full_func_name:match '%.%w+$' then
    func_name = full_func_name:match '%.(%w+)$'
  end

  local param_names = {}
  local args = {}
  local skip_indices = {}

  for child in args_node:iter_children() do
    if child:named() then
      local text = vim.treesitter.get_node_text(child, 0)
      if child:type() == 'keyword_argument' then
        local key = text:match '^([%w_]+)%s*='
        skip_indices[key] = true
        table.insert(args, { value = text, is_kwarg = true })
      else
        table.insert(args, { value = text, is_kwarg = false })
      end
    end
  end

  local is_star = function(p)
    p = vim.trim(p)
    return p:match '^%*[^*]' ~= nil
  end

  local is_star_star = function(p)
    p = vim.trim(p)
    return p:match '^%*%*' ~= nil
  end

  local star = false
  local star_star = false
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local params = line:match('def%s+' .. func_name .. '%s*%(([^)]*)%)')
    if params then
      for _, param in ipairs(vim.fn.split(params, ',')) do
        if is_star(param) then
          star = true
        elseif is_star_star(param) then
          star_star = true
        end
      end

      if star and star_star then
        print 'Function uses *args and **kwargs, skipping.'
        return
      elseif star then
        print 'Function uses *args, skipping.'
        return
      end

      -- parse only normal names now
      for _, param in ipairs(vim.fn.split(params, ',')) do
        local name = vim.trim(param:match '([%w_]+)')
        if name and name ~= 'self' and name ~= 'cls' then
          table.insert(param_names, name)
        end
      end

      break
    end
  end

  local new_args = {}
  local param_i = 1

  for _, arg in ipairs(args) do
    if arg.is_kwarg then
      table.insert(new_args, arg.value)
    else
      while skip_indices[param_names[param_i]] do
        param_i = param_i + 1
      end
      if param_names[param_i] then
        table.insert(new_args, string.format('%s=%s', param_names[param_i], arg.value))
        param_i = param_i + 1
      else
        print 'Too many positional args.'
        return
      end
    end
  end

  local start_row, start_col, end_row, end_col = call_node:range()
  local new_call = string.format('%s(%s)', full_func_name, table.concat(new_args, ', '))
  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { new_call })
  -- Restore original cursor
  vim.api.nvim_win_set_cursor(0, original_pos)
end

local function convert_all_calls_to_kwargs()
  local buffer = vim.api.nvim_get_current_buf()
  local root = get_root(buffer)

  local function walk(node)
    if node:type() == 'call' then
      vim.api.nvim_win_set_cursor(0, { node:start() + 1, 0 })
      convert_args_to_kwargs()
    end
    for child in node:iter_children() do
      walk(child)
    end
  end

  walk(root)
end

vim.api.nvim_create_user_command('ConvertArgsToKwargs', convert_args_to_kwargs, {})
vim.keymap.set('n', '<leader>ca', ':ConvertArgsToKwargs<CR>', { noremap = true, silent = true })

vim.api.nvim_create_user_command('ConvertAllArgsToKwargs', convert_all_calls_to_kwargs, {})
vim.keymap.set('n', '<leader>cA', ':ConvertAllArgsToKwargs<CR>', { noremap = true, silent = true })
return {}
