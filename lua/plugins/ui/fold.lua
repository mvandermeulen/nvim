return {
  {-- kevinhwang91/nvim-ufo
    "kevinhwang91/nvim-ufo",
    lazy = false,
    dependencies = { "kevinhwang91/promise-async" },
    init = function()
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 90 
      vim.o.foldlevelstart = 90
      vim.o.foldenable = true
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
    end,
    opts = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        -- local suffix = (" ... 󰁂 %d "):format(endLnum - lnum)
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end

      return {
        fold_virt_text_handler = handler,
        provider_selector = function(bufnr, filetype, buftype)
          return { "treesitter", "indent" }
        end,
        open_fold_hl_timeout = 0,
        close_fold_kinds_for_ft = { default = { 'imports', 'comment' } },
        preview = {
          win_config = { border = { "", "─", "", "", "", "─", "", "" }, winblend = 0 },
          mappings = {
            scrollU = "<C-b>",
            scrollD = "<C-f>",
            jumpTop = "[",
            jumpBot = "]",
          },
        },
      }
    end,
    keys = {
      {
        "zp",
        function()
          local winid = require("ufo").peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover()
          end
        end,
        desc = "Peek Folded Line",
      },
    },
  },
}
