local has_tree, tree = pcall(require, 'nvim-tree')
if not has_tree then
  return
end

vim.g.nvim_tree_icons = {
  git = {
    unstaged = "",
    staged = "✚",
    unmerged = "",
    renamed = "➜",
    untracked = "★",
    deleted = "✖",
    ignored = "◌",
    modified = '✹',
  },
}
vim.g.nvim_tree_group_empty = 1

tree.setup {
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
}
