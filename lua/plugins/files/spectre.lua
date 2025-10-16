--[[
-- Spectre Plugin
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]


-- Link: https://github.com/nvim-pack/nvim-spectre

return {
  'nvim-pack/nvim-spectre',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    -- { '<localleader>S', '<cmd>lua require("spectre").toggle()<CR>', desc = 'Toggle Spectre' },
    { '<leader>erw', '<esc><cmd>lua require("spectre").open_visual({select_word=true})<CR>', desc = 'Search current word' },
    { '<leader>erW', '<esc><cmd>lua require("spectre").open_file_search({select_word=true})<CR>', desc = 'Search word in current file' },
    { '<leader>erS', '<esc><cmd>lua require("spectre").open_visual()<CR>', mode = 'v', desc = 'Search selection' },
  },
  config = function()
    require('spectre').setup({
      color_devicons = true,
      open_cmd = 'vnew',
      live_update = true,
      line_sep_start = '┌-----------------------------------------',
      result_padding = '¦  ',
      line_sep = '└-----------------------------------------',
      highlight = {
        ui = 'String',
        search = 'DiffChange',
        replace = 'DiffDelete'
      },
      mapping = {
        ['toggle_line'] = {
          map = 'dd',
          cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
          desc = 'toggle item'
        },
        ['enter_file'] = {
          map = '<cr>',
          cmd = "<cmd>lua require('spectre').enter_file()<CR>",
          desc = 'open file'
        },
        ['send_to_qf'] = {
          map = '<localleader>q',
          cmd = "<cmd>lua require('spectre').send_to_qf()<CR>",
          desc = 'send all items to quickfix'
        },
        ['replace_cmd'] = {
          map = '<localleader>c',
          cmd = "<cmd>lua require('spectre').replace_cmd()<CR>",
          desc = 'input replace command'
        },
        ['show_option_menu'] = {
          map = '<localleader>o',
          cmd = "<cmd>lua require('spectre').show_options()<CR>",
          desc = 'show options'
        },
        ['run_current_replace'] = {
          map = '<localleader>rc',
          cmd = "<cmd>lua require('spectre').run_current_replace()<CR>",
          desc = 'replace current line'
        },
        ['run_replace'] = {
          map = '<localleader>R',
          cmd = "<cmd>lua require('spectre').run_replace()<CR>",
          desc = 'replace all'
        },
        ['change_view_mode'] = {
          map = '<localleader>v',
          cmd = "<cmd>lua require('spectre').change_view()<CR>",
          desc = 'change result view mode'
        },
        ['change_replace_sed'] = {
          map = 'trs',
          cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
          desc = 'use sed to replace'
        },
        ['change_replace_oxi'] = {
          map = 'tro',
          cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
          desc = 'use oxi to replace'
        },
        ['toggle_live_update'] = {
          map = 'tu',
          cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
          desc = 'update when vim writes to file'
        },
        ['toggle_ignore_case'] = {
          map = 'ti',
          cmd = "<cmd>lua require('spectre').toggle_ignore_case()<CR>",
          desc = 'toggle ignore case'
        },
        ['toggle_ignore_hidden'] = {
          map = 'th',
          cmd = "<cmd>lua require('spectre').toggle_ignore_hidden()<CR>",
          desc = 'toggle search hidden'
        },
        ['resume_last_search'] = {
          map = '<localleader>l',
          cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
          desc = 'repeat last search'
        },
      },
      find_engine = {
        ['rg'] = {
          cmd = 'rg',
          args = {
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
          },
          options = {
            ['ignore-case'] = {
              value = '--ignore-case',
              icon = '[I]',
              desc = 'ignore case'
            },
            ['hidden'] = {
              value = '--hidden',
              desc = 'hidden file',
              icon = '[H]'
            },
          }
        },
      },
      replace_engine = {
        ['sed'] = {
          cmd = 'sed',
          args = nil,
          options = {
            ['ignore-case'] = {
              value = '--ignore-case',
              icon = '[I]',
              desc = 'ignore case'
            },
          }
        },
      },
      default = {
        find = {
          cmd = 'rg',
          options = { 'ignore-case' }
        },
        replace = {
          cmd = 'sed'
        }
      },
    })
  end,
}
