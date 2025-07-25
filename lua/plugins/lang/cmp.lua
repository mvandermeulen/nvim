--[[
-- Completion Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-17
--]]

-- Setup nvim-cmp.
local cmp = require("cmp")
local lspkind = require("lspkind")
local icons = require("helpers.ui.icons")

lspkind.init({
  symbol_map = icons.kind,
})

cmp.setup({
  formatting = {
    format = lspkind.cmp_format({
      with_text = false,
      maxwidth = 50,
      menu = {
        buffer = "BUF",
        rg = "RG",
        nvim_lsp = "LSP",
        path = "PATH",
        luasnip = "SNIP",
        -- vsnip = "SNIP",
        calc = "CALC",
        spell = "SPELL",
        emoji = "EMOJI",
      },
    }),
  },
  experimental = { native_menu = false, ghost_text = false },
  -- snippet = {
  --  expand = function(args)
  --    require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
  --  end,
  -- },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer", keyword_length = 3 },
    { name = "luasnip" },
    { name = "path" },
    { name = "rg", keyword_length = 5 },
  },
})

-- Use buffer source for `/`.
cmp.setup.cmdline("/", { sources = { { name = "buffer" } } })

-- Use cmdline & path source for ':'.
cmp.setup.cmdline(":", {
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})
