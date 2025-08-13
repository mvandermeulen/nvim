return {
    "ggandor/leap.nvim",
    enabled = false,
    opts = {
        case_sensitive = true,
        -- equivalence_classes = { " \t\r\n" },
        max_phase_one_targets = nil,
        highlight_unlabeled_phase_one_targets = false,
        max_highlighted_traversal_targets = 10,
        -- substitute_chars = {},
        safe_labels = "sfnut/SFNLHMUGTZ?",
        -- safe_labels = "",
        labels = "sfnjklhodweimbuyvrgtaqpcxz/SFNJKLHODWEIMBUYVRGTAQPCXZ?",
        -- special_keys = {
            -- next_target = ";",
            -- prev_target = ",",
            -- next_group = "<space>",
            -- prev_group = "<tab>",
        -- },
    },
    config = function(_, opts)
        local leap = require("leap")
        for k, v in pairs(opts) do
            leap.opts[k] = v
        end
        require('leap').set_default_mappings()
        -- vim.keymap.set({ "n" }, "s", "<Plug>(leap)")
        -- -- vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
        -- vim.keymap.set({ "x", "o" }, "s", "<Plug>(leap-forward)")
        -- vim.keymap.set({ "x", "o" }, "S", "<Plug>(leap-backward)")
    end,
}

