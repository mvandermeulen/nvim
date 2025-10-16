--[[
-- Debugger Plugin
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]


-- Link: 

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'mfussenegger/nvim-dap-python',
      'theHamsta/nvim-dap-virtual-text', -- Show variable values as virtual text
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      -- Enable virtual text
      require('nvim-dap-virtual-text').setup {
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        virt_text_pos = 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil,
      }

      -- DAP UI setup
      dapui.setup {
        controls = {
          element = 'repl',
          enabled = true,
          -- icons = {
          --   disconnect = '',
          --   pause = '',
          --   play = '',
          --   run_last = '',
          --   step_back = '',
          --   step_into = '',
          --   step_out = '',
          --   step_over = '',
          --   terminate = '',
          -- },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = 'single',
          mappings = {
            close = { 'q', '<Esc>' },
          },
        },
      }

      -- Dap firing events
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      -- Python setup
      require('dap-python').setup 'python'

      -- Signs setup
      vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '⭕️', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = '📝', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '⭐️', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '❌', texthl = '', linehl = '', numhl = '' })

      -- Key mappings
      local keymap = vim.keymap.set

      -- Basic debugging
      keymap('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      keymap('n', '<leader>dB', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Conditional Breakpoint' })
      keymap('n', '<leader>dl', function()
        dap.set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
      end, { desc = 'Debug: Set Log Point' })
      keymap('n', '<leader>dc', dap.continue, { desc = 'Debug: Continue' })
      keymap('n', '<leader>di', dap.step_into, { desc = 'Debug: Step Into' })
      keymap('n', '<leader>do', dap.step_over, { desc = 'Debug: Step Over' })
      keymap('n', '<leader>dO', dap.step_out, { desc = 'Debug: Step Out' })
      keymap('n', '<leader>ds', dap.terminate, { desc = 'Debug: Stop' })

      -- REPL
      keymap('n', '<leader>dr', dap.repl.open, { desc = 'Debug: Open REPL' })

      -- UI
      keymap('n', '<leader>dh', function()
        require('dap.ui.widgets').hover()
      end, { desc = 'Debug: Hover Variables' })
      keymap('n', '<leader>dp', function()
        require('dap.ui.widgets').preview()
      end, { desc = 'Debug: Preview' })
      keymap('n', '<leader>df', function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.frames)
      end, { desc = 'Debug: Show Frames' })
      keymap('n', '<leader>dS', function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.scopes)
      end, { desc = 'Debug: Show Scopes' })

      -- Python specific
      keymap('n', '<leader>dtm', require('dap-python').test_method, { desc = 'Debug: Test Method' })
      keymap('n', '<leader>dtc', require('dap-python').test_class, { desc = 'Debug: Test Class' })
      keymap('n', '<leader>dts', require('dap-python').debug_selection, { desc = 'Debug: Selection' })
    end,
  },
}
