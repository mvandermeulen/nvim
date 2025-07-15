--[[
-- Commands: Windows
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-17
--]]


vim.api.nvim_create_user_command("NewTabTiled", function()
  vim.cmd.tabnew()
  vim.cmd.vnew()
  vim.cmd.new()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>h', true, false, true), 'n', false)
  vim.cmd.new()
end, {})


vim.api.nvim_create_user_command("NewTabHSplit", function()
  vim.cmd.tabnew()
  vim.cmd.new()
end, {})


vim.api.nvim_create_user_command("NewTabVSplit", function()
  vim.cmd.tabnew()
  vim.cmd.vnew()
end, {})


vim.api.nvim_create_user_command("NewTabTripleVSplit", function()
  vim.cmd.tabnew()
  vim.cmd.vnew()
  vim.cmd.vnew()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>=', true, false, true), 'n', false)
end, {})


vim.api.nvim_create_user_command("NewTabQuadVSplit", function()
  vim.cmd.tabnew()
  vim.cmd.vnew()
  vim.cmd.vnew()
  vim.cmd.vnew()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>=', true, false, true), 'n', false)
end, {})

-- tab buffer window list
-- https://koturn.hatenablog.com/entry/2018/02/13/000000
vim.api.nvim_create_user_command("TabInfo", function()
  local function create_winid2bufnr_dict()
    local winid2bufnr_dict = {}
    for _, bufid in ipairs(vim.api.nvim_list_bufs()) do
      for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(winid) == bufid then
          winid2bufnr_dict[winid] = bufid
        end
      end
    end
    return winid2bufnr_dict
  end

  print("====== Tab Page Info ======")
  local current_tabid = vim.api.nvim_get_current_tabpage()
  local winid2bufnr_dict = create_winid2bufnr_dict()
  for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
    local current_winnr = vim.api.nvim_tabpage_get_win(tabid)
    local symbol1 = (tabid == current_tabid) and ">" or " "
    print(symbol1 .. "Tab:" .. tabid)
    print("    Buffer number | Window Number | Window ID | Buffer Name")
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabid)) do
      local bufid = winid2bufnr_dict[winid]
      local symbol2 = (winid == current_winnr) and "*" or " "
      local c = string.format("%13d | %13d | %9d | %s", bufid, winid, winid, vim.api.nvim_buf_get_name(bufid))
      print("   " .. symbol2 .. c)
    end
  end
end, { force = true, bar = true })

