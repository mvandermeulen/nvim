-- formatter
require("formatter").setup(
  {
    filetype = {
      python = {
        -- pip3 install black
        function()
          return {
            exe = "black",
            args = {"-", "-l", 80},
            stdin = true
          }
        end
      },
      cpp = {
        -- astyle
        function()
          return {
            exe = "astyle",
            args = {
              "--indent=spaces=2",
              "-f",
              "-k1",
              "-W1",
              "-j",
              "-s",
              "-N",
              "--pad-oper",
              "--max-code-length=80",
              "--style=java"
            },
            stdin = true
          }
        end
      },
      lua = {
        -- sudo npm i -g lua-fmt
        function()
          return {
            exe = "luafmt",
            args = {"--indent-count", 2, "--stdin"},
            stdin = true
          }
        end
      },
      tex = {
        function()
          return {
            exe = "latexindent",
            args = {"-"},
            stdin = true
          }
        end
      }
    }
  }
)
vim.api.nvim_set_keymap("n", "<Leader>fo", ":Format<CR>", {noremap = true, silent = true})
