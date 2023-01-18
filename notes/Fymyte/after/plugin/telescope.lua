local ok, telescope = pcall(require, 'telescope')
if not ok then
  return
end

local utils = require('fymyte.utils')

telescope.setup{
  defaults = {
    theme = {
      border = true,
      borderchars = {
        prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
        results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
        preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
    },
  },
  extensions = {
    file_browser = {
      theme = 'ivy',
    },
    project = {
      base_dirs = {
        '~/.config/nvim',
      },
      display_type = 'full',
    },
  }
}

telescope.load_extension('notify')
telescope.load_extension('fzf')
telescope.load_extension('file_browser')
telescope.load_extension('dict')
telescope.load_extension('project')
telescope.load_extension('lsp_handlers')

utils.map({'n', '<leader>ff', [[<cmd>lua require('telescope.builtin').find_files()<CR>]]})
utils.map({'n', '<leader>fl', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]]})
utils.map({'n', '<leader>fh', [[<cmd>lua require('telescope.builtin').help_tags()<CR>]]})
utils.map({'n', '<leader>fc', [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown())<CR>]]})
utils.map({'n', '<leader>fb', [[<cmd>lua require('telescope').extensions.file_browser.file_browser()<CR>]]})
utils.map({'n', '<leader>fs', [[<cmd>lua require('telescope').extensions.dict.synonyms()<CR>]]})
utils.map({'n', '<leader>fp', [[<cmd>lua require('telescope').extensions.project.project{display_type='full'}<CR>]]})
