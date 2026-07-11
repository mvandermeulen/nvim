--[[
-- LSP Server: jsonls
--
-- Author: Mark van der Meulen
-- Updated: 2026-06-21
--]]


return {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
    },
  },
  setup = {
    commands = {
      Format = {
        function()
          vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
        end,
      },
    },
  },
}

