return {
  {-- kevinhwang91/nvim-ufo
    "kevinhwang91/nvim-ufo",
    lazy = false,
    dependencies = { "kevinhwang91/promise-async" },
    init = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    end,
    opts = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" ... 󰁂 %d "):format(endLnum - lnum)
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
        open_fold_hl_timeout = 150,
        close_fold_kinds_for_ft = { default = { 'imports', 'comment' } },
        preview = {
          win_config = { border = { "", "─", "", "", "", "─", "", "" }, winhighlight = 'Normal:Folded', winblend = 50 },
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
  {-- chrisgrieser/nvim-origami
    "chrisgrieser/nvim-origami",
    lazy = false,
    enabled = false,
    opts = {
      keepFoldsAcrossSessions = package.loaded["ufo"],
      useLspFoldsWithTreesitterFallback = not package.loaded["ufo"],
      pauseFoldsOnSearch = true,
      autoFold = {
        enabled = true,
        kinds = { "comment", "imports" },
      },
      foldKeymaps = {
        setup = false, -- modifies `h` and `l`
        hOnlyOpensOnFirstColumn = false,
      },
    },
    config = function()
      local status_ok, origami = pcall(require, 'origami')
      if not status_ok then
        return
      end
      origami.setup({
        -- keepFoldsAcrossSessions = true,
        keepFoldsAcrossSessions = package.loaded["ufo"],
        useLspFoldsWithTreesitterFallback = not package.loaded["ufo"],
        pauseFoldsOnSearch = true,
        autoFold = {
          enabled = true,
          kinds = { "comment", "imports" },
        },
        -- `h` key opens on first column, not at first non-blank character or before
        foldKeymaps = {
          setup = false, -- modifies `h` and `l`
          hOnlyOpensOnFirstColumn = false,
        },
      })
    end,
  },
}
