-- dashboard
vim.g.dashboard_default_executive = "telescope"
vim.g.dashboard_custom_header = {
  [[                                 _.-~~.)                                     ]],
  [[           _.--~~~~~---....__  .` . .,`                                      ]],
  [[         ,`. . . . . . . . . .~- ._ (                                        ]],
  [[        ( .. .g. . . . . . . . . . .~-._                                     ]],
  [[     .~__.-~    ~`. . . . . . . . . . . -.                                   ]],
  [[     `----..._      ~-=~~-. . . . . . . . ~-.                                ]],
  [[               ~-._   `-._ ~=_~~--. . . . . .~.                              ]],
  [[                | .~-.._  ~--._-.    ~-. . . . ~-.                           ]],
  [[                 \ .(   ~~--.._~       `. . . . .~-.                 ,       ]],
  [[                  `._\         ~~--.._    `. . . . . ~-.    .- .   ,`/       ]],
  [[  _  . _ . -~\        _ ..  _          ~~--.`_. . . . . ~-_     ,-`,`  .     ]],
  [[               ` ._           ~                ~--. . . . .~=.-,. /. `       ]],
  [[         - . -~            -. _ . - ~ - _   - ~     ~--..__~ _,. /   \  - ~  ]],
  [[                . __ ..                   ~-               ~~_. (  `         ]],
  [[  )`. _ _ τ __       `-     ..  - .   . - ~ ~ . _  Tau  _ \   ~-`` `  `. _ ]],
  [[ ' ' ]]
}

vim.g.dashboard_custom_footer = {
  [[                   e^iπ + 1 = 0]],
  [[                                -- Leonhard Euler]]
}
vim.g.dashboard_custom_section = {
  a_find_history = {
    description = {" File history              <Leader> f h "},
    command = "DashboardFindHistory"
  },
  b_find_file = {
    description = {" File find                 <Leader> f f "},
    command = "DashboardFindFile"
  },
  c_find_word = {
    description = {" Word find                 <Leader> f w "},
    command = "DashboardFindWord"
  },
  d_buffers = {
    description = {"﬘ Recently buffers          <Leader> f b"},
    command = "Telescope buffers"
  },
  e_marks = {
    description = {" Marks                     <Leader> f m "},
    command = "Telescope marks"
  },
  f_config_file = {
    description = {" Config file               <Leader> f v "},
    command = "e ~/.config/nvim/init.lua"
  }
}
