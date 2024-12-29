vim.keymap.set('n', '<leader>ap', function()
  local providers = {
    'claude',
    'groq',
    'cerebras',
  }
  local provider = require('avante.config').provider
  local idx = vim.iter(ipairs(providers)):find(function(_, e) return e == provider end)
  if idx == nil then
    idx = 1
  else
    idx = idx + 1
  end
  if idx > #providers then
    idx = 1
  end
  local new_provider = providers[idx]
  -- silence notifications so we can display our own
  local notify = vim.notify
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.notify = function(msg, opts)
    local level = (type(opts) == 'table' and opts.level)
      or (type(opts) == 'number' and opts)
      or vim.log.levels.INFO
    if level and level > vim.log.levels.INFO then
      notify(msg, opts)
      return
    end
  end
  require('avante.api').switch_provider(new_provider)
  vim.notify = notify
  vim.notify('Switched to ' .. new_provider, { title = 'Avante' })
end, { desc = 'Avante: Switch Provider'})

vim.keymap.set('n','<M-m>', fn.filetype_command({ 'Avante', 'AvanteInput' }, recent_wins.focus_most_recent, function()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'AvanteInput' then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
    require('avante.api').ask { floating = false }
  end), { desc = 'Avante: Toggle Focus'})

vim.keymap.set('n', '<M-S-m>', function()
  local winid = (vim.bo.filetype ~= 'AvanteInput' and vim.bo.filetype ~= 'Avante')
      and vim.api.nvim_get_current_win()
    or nil
  if require('avante').is_sidebar_open() then
    require('avante').close_sidebar()
    return
  end
  require('avante.api').ask { floating = false }
  if winid ~= nil then
    vim.defer_fn(function()
      vim.cmd [[stopinsert]]
      vim.api.nvim_set_current_win(winid)
    end, 0)
  end
end, {desc = 'Avante: Ask' })
