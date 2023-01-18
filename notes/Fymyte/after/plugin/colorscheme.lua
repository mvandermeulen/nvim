local ok, kanagawa = pcall(require, 'kanagawa')
if not ok then
  return
end

local colors = {
  sumiInk1 = "#212121",
  sumiInk0 = "#2A2A2A",
  sumiInk2 = "#353535",
  sumiInk3 = "#414141",
  sumiInk4 = "#5F5F5F",

  waveBlue1 = "#2F2F2F",
  waveBlue2 = "#393939",
}


kanagawa.setup({
    undercurl = true,           -- enable undercurls
    commentStyle = "italic",
    functionStyle = "NONE",
    keywordStyle = "italic",
    statementStyle = "bold",
    typeStyle = "NONE",
    variablebuiltinStyle = "italic",
    specialReturn = true,       -- special highlight for the return keyword
    specialException = true,    -- special highlight for exception handling keywords
    transparent = false,        -- use background colors defined above
    colors = colors,
    overrides = {
      TSVariable = { link = "Identifier" }
    },
})

kanagawa.load()
