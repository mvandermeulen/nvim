--[[
-- Key Analyzer Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-21
--]]


local status_ok, keyanalyzer = pcall(require, 'key-analyzer')
if not status_ok then
  return
end

keyanalyzer.setup({
    command_name = "KeyAnalyzer",
    highlights = {
        bracket_used = "KeyAnalyzerBracketUsed",
        letter_used = "KeyAnalyzerLetterUsed", 
        bracket_unused = "KeyAnalyzerBracketUnused",
        letter_unused = "KeyAnalyzerLetterUnused",
        promo_highlight = "KeyAnalyzerPromo",
        -- Set to false if you want to define highlights manually
        define_default_highlights = true,
    },
})
