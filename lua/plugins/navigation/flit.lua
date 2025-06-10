return {
    "ggandor/flit.nvim",
    enabled = true,
    config = function()
        require("flit").setup({
            keys = { f = "f", F = "F", t = "t", T = "T" },
            -- A string like "nv", "nvo", "o", etc.
            labeled_modes = "nvo",
            clever_repeat = true,
            multiline = true,
            -- Like `leap`s similar argument (call-specific overrides).
            -- E.g.: opts = { equivalence_classes = {} }
            opts = {},
        })
    end,
}

