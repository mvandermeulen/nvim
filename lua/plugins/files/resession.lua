--[[
-- Resession Plugin
-- https://github.com/stevearc/resession.nvim
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]

local resession_path = vim.fn.expand(vim.fn.stdpath 'data' .. '/resession')
if vim.fn.isdirectory(resession_path) == 0 then
  vim.fn.mkdir(resession_path, 'p')
end

local status_ok, resession = pcall(require, 'resession')
if not status_ok then
  return
end

resession.setup({
  autosave = {
    enabled = true,
    interval = 150,
    notify = true,
  },
  dir = "resession",
  -- Show more detail about the sessions when selecting one to load.
  -- Disable if it causes lag.
  load_detail = true,
  -- List order ["modification_time", "creation_time", "filename"]
  load_order = "modification_time",
})


-- Automatically save a session when you exit Neovim
-- https://github.com/stevearc/resession.nvim?tab=readme-ov-file#automatically-save-a-session-when-you-exit-neovim
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    -- Always save a special session named "last"
    -- local directory_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    -- local short_date = os.date("%y-%m-%d")
    -- resession.save("AUTO_SESSION_" .. string.upper(directory_name) .. "_" .. short_date)
    resession.save("LAST_SESSION")
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only load the session if nvim was started with no args and without reading from stdin
    if vim.fn.argc(-1) == 0 and not vim.g.using_stdin then
      -- Save these to a different directory, so our manual sessions don't get polluted
      resession.load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true })
    end
  end,
  nested = true,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    resession.save(vim.fn.getcwd(), { dir = "dirsession", notify = false })
  end,
})

vim.api.nvim_create_autocmd('StdinReadPre', {
  callback = function()
    -- Store this for later
    vim.g.using_stdin = true
  end,
})



-- Resession does NOTHING automagically, so we have to set up some keymaps
vim.keymap.set("n", "<leader>Ss", resession.save, { noremap = true, silent = true, desc = 'Resession: Save' })
vim.keymap.set("n", "<leader>St", resession.save_tab, { noremap = true, silent = true, desc = 'Resession: Save Tab' })
vim.keymap.set("n", "<leader>Sl", resession.load, { noremap = true, silent = true, desc = 'Resession: Load' })
vim.keymap.set("n", "<leader>Sd", resession.delete, { noremap = true, silent = true, desc = 'Resession: Delete' })
vim.keymap.set("n", "<leader>SD", resession.detach , { noremap = true, silent = true, desc = 'Resession: Detach' })
-- vim.keymap.set("n", "<leader>S", resession. , { noremap = true, silent = true, desc = 'Resession: ' })


