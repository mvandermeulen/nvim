return {
    "ggandor/flit.nvim",
    enabled = false,
    config = function()
        require("flit").setup({
            keys = { f = 'f', F = 'F' },
            -- A string like "nv", "nvo", "o", etc.
            labeled_modes = "nvo",
            clever_repeat = true,
            multiline = true,
            opts = {},
        })
    end,
}

