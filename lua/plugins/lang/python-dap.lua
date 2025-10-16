--[[
-- UV Integration Plugin
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]


-- Link: 

return {
  {
    "mfussenegger/nvim-dap",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      
      -- Setup DAP UI
      dapui.setup({
        expand_lines = true,
        icons = { expanded = "", collapsed = "", circular = "" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
      })

      -- Setup virtual text
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        filter_references_pattern = '<module',
      })
      
      -- Setup Python debugging
      require("dap-python").setup("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
      
      -- Auto-open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
    keys = {
      { "<leader>d", group = "Debug" },
      { "<F5>", function() require("dap").continue() end, desc = "Debug Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Debug Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Debug REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Debug Run Last" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug UI Toggle" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Debug Eval", mode = {"n", "v"} },
    },
  },
}
