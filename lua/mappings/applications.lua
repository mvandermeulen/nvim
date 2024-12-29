local M = {}

local clipboard_mappings = {
    name = ' Clipboard',
    ["0"] = { '<cmd>:Telescope neoclip 0<cr>', 'Yank to Register 0' },
    ["2"] = { '<cmd>:Telescope neoclip 2<cr>', 'Yank to Register 2' },
    ["4"] = { '<cmd>:Telescope neoclip 4<cr>', 'Yank to Register 4' },
    ["6"] = { '<cmd>:Telescope neoclip 6<cr>', 'Yank to Register 6' },
    ["8"] = { '<cmd>:Telescope neoclip 8<cr>', 'Yank to Register 8' },
    h = { '<cmd>:Telescope neoclip<cr>', 'History' },
    m = { "<cmd>lua require('telescope').extensions.macroscope.default()<cr>", 'Macros'},
    p = { '<cmd>:Telescope neoclip plus<cr>', 'Yank to Plus' },
    P = { '<cmd>lua require("neoclip").pause()<cr>', 'Pause Recording' },
    s = { '<cmd>:Telescope neoclip star<cr>', 'Yank to Star' },
    S = { '<cmd>lua require("neoclip").start()<cr>', 'Start Recording' },
    T = { '<cmd>lua require("neoclip").toggle()<cr>', 'Toggle Recording' },
    u = { '<cmd>:Telescope neoclip unnamed<cr>', 'Yank to Unnamed' },
}

local chatgpt_mappings = {
  name = "GPT",
    c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
    e = { "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction", mode = { "n", "v" } },
    g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
    t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
    k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
    d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
    a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
    o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
    s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
    f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
    x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
    r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
    l = { "<cmd>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", mode = { "n", "v" } },
}


-- local chatgpt_mappings = {
--     name = 'GPT',
--     g = { ':ChatGPT<cr>', 'ChatGPT' },
--     r = { ':ChatGPTRun<cr>', 'Run' },
--     a = { ':ChatGPTActAs<cr>', 'Act As' },
--     c = { ':ChatGPTCompleteCode<cr>', 'Complete Code' },
--     e = { ':ChatGPTEditWithInstructions<cr>', 'Complete Code' },
-- }



-- local clipboard_mappings = {
-- }

local focus_mappings = {
    name = 'Focus',
    z = { '<cmd>:ZenMode<cr>', 'Toggle Zen Mode' },
    t = { '<cmd>:Twilight<cr>', 'Toggle Twilight' },
}


local treesitter_mappings = {
    name = 'Treesitter',
    c = { '<cmd>:TSContextToggle<cr>', 'Context Toggle' },
    h = { '<cmd>TSHighlightCapturesUnderCursor<cr>', 'Highlight' },
    p = { '<cmd>TSPlaygroundToggle<cr>', 'Playground' },
}

local undotree_mappings = {
    name = ' Undotree',
    o = { '<cmd>lua require("undotree").open()<cr>', ' Open' },
    c = { '<cmd>lua require("undotree").close()<cr>', ' Close' },
    t = { '<cmd>lua require("undotree").toggle()<cr>', ' Toggle' },
}



-- M.mappings = {
--     name = '󰣆 Applications',
--     u = undotree_mappings,
--     c = { '<cmd>:Cheatsheet<cr>', ' Cheatsheet' },
--     f = { '<cmd>:FzfLua<cr>', ' Fuzzy Search' },
--     l = { '<cmd>:Llama<cr>', '󰭆 LLaMA' },
--     n = { '<cmd>:Notifications<cr>', '󰵙 Notifications' },
--     t = { "<cmd>Telescope<cr>", " Telescope Extensions" },
-- }

M.mappings = {
    name = 'Applications',
    c = clipboard_mappings,
    C = { '<cmd>:Cheatsheet<cr>', 'Cheatsheet' },
    f = focus_mappings,
    g = chatgpt_mappings,
    l = { '<cmd>:Llama<cr>', '󰭆 LLaMA' },
    n = { '<cmd>:Notifications<cr>', '󰵙 Notifications' },
    s = { '<cmd>:FzfLua<cr>', 'Fuzzy Search' },
    t = treesitter_mappings,
    T = { "<cmd>Telescope<cr>", " Telescope Extensions" },
    u = undotree_mappings,
}

return M
