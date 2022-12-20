# My neovim config🚀
🔥17~25ms startup time, with 51 plugins.
![demo5](https://user-images.githubusercontent.com/61612323/153551133-747cf4aa-537f-46ea-814b-28edab00f4f3.png)


## Installation🎨
```shell
git clone https://github.com/Laughing-q/nvim.git ~/.config/nvim
cd ~/.config/nvim
./install.sh
```

## Screenshots🖼️
![demo1](https://user-images.githubusercontent.com/61612323/153551187-156189ea-9e52-407c-8888-743439f5bf4c.png)
![demo2](https://user-images.githubusercontent.com/61612323/153551199-e7c6896f-a125-4622-ab19-03277cd32a28.png)
![demo3](https://user-images.githubusercontent.com/61612323/153551200-e6cdfb91-6005-4c97-8566-bc2e356add77.png)
![demo4](https://user-images.githubusercontent.com/61612323/153551201-3bf916d9-f851-4f3e-a3da-6abed51cd3f9.png)


## Lsp and Formatter(arch user)🦁
```shell
# for code formatting and check
yay -S black yapf stylua luacheck shfmt shellcheck 
yay -S clang-format-all-git
pip install cmakelang
sudo npm install --global prettier
yay -S ripgrep
```

## Keymappings💻
I'm not a native `vim` user, I'm used to using direction keys to move instead of `hjkl`(but maybe I'll be there soon), so my keymappings are based on `i(Up`)、`k(Down`)、`l(Right`)、`j(Left)` for now.

If you guys want `hjkl` style, just checkout branch `hjkl`. I actually don't test it all, but it will work.
### Base mappings⌨️
- base
  | shortcut        | action                                                    | Equivalent    | mode        |
  |-----------------|-----------------------------------------------------------|---------------|-------------|
  | `i`             | up                                                        | `k`           | `n` `v`     |
  | `k`             | down                                                      | `j`           | `n` `v`     |
  | `l`             | right                                                     | `l`           | `n` `v`     |
  | `j`             | left                                                      | `h`           | `n` `v`     |
  | `h`             | insert                                                    | `i`           | `n` `v`     |
  | `I`(deprecated) | faster up move                                            | `5i`          | `n` `v`     |
  | `K`(deprecated) | faster down move                                          | `5k`          | `n` `v`     |
  | `L`(deprecated) | faster right move                                         | `5l`          | `n` `v`     |
  | `J`(deprecated) | faster left move                                          | `5j`          | `n` `v`     |
  | `H`             | move cursor to start of line and insert                   | `I`           | `n` `v`     |
  | `alt` `j`       | left                                                      | `<Left>`      | `i`         |
  | `alt` `l`       | right                                                     | `<Right>`     | `i`         |
  | `alt` `i`       | up                                                        | `<Up>`        | `i`         |
  | `alt` `k`       | down                                                      | `<Down>`      | `i`         |
  | `ctrl` `e`      | Move the view port down 5 lines without moving the cursor | `ctrl+e`      | `n` `v`     |
  | `ctrl` `y`      | Move the view port up 5 lines without moving the cursor   | `ctrl+y`      | `n` `v`     |
  | `O`             | Move to next line and keep normal mode                    | `O<ESC>`      | `n`         |
  | `Q`             | Quit                                                      | `:q<CR>`      | `n`         |
  | `S`             | Save                                                      | `:w<CR>`      | `n`         |
  | `ctrl` `l`      | end of line                                               | `$`, `<End>`  | `n` `v` `i` |
  | `ctrl` `j`      | start of line                                             | `0`, `<ESC>I` | `n` `v` `i` |

- move line
  | shortcut  | action                    | mode    |
  |-----------|---------------------------|---------|
  | `alt` `i` | move current line to up   | `n` `v` |
  | `alt` `k` | move current line to down | `n` `v` |

- terminal
  | shortcut | action              | mode |
  |----------|---------------------|------|
  | `tel`    | open terminal right | `n`  |
  | `tek`    | open terminal below | `n`  |
  | `jk`     | escape the terminal | `t`  |

- indent
  | shortcut  | action                    | mode    |
  |-----------|---------------------------|---------|
  | `<`       | `Un-indent`               | `n` `v` |
  | `>`       | `indent`                  | `n` `v` |

- resize arrows
  | shortcut  | action                    | mode    |
  |-----------|---------------------------|---------|
  | `<Up>`    | resize the arrows         | `n`     |
  | `<Down>`  | resize the arrows         | `n`     |
  | `<Left>`  | resize the arrows         | `n`     |
  | `<Right>` | resize the arrows         | `n`     |

- window move
  | shortcut       | action                  | mode |
  |----------------|-------------------------|------|
  | `<leader>` `w` | move to previous window | `n`  |
  | `<leader>` `l` | move to right window    | `n`  |
  | `<leader>` `j` | move to left window     | `n`  |
  | `<leader>` `k` | move to bottom window   | `n`  |
  | `<leader>` `i` | move to top window      | `n`  |


- others
  | shortcut           | action                   | mode |
  |--------------------|--------------------------|------|
  | `<ESC>`            | set nohighlight          | `n`  |
  | `\p`               | current file path        | `n`  |
  | `\w`               | current work path        | `n`  |
  | `<leader>` `s` `s` | set spell                | `n`  |
  | `<leader>` `s` `w` | set wrap                 | `n`  |
  | `<leader>` `r`     | compile code(python ...) | `n`  |
  | `<leader>` `o`     | fold code                | `n`  |


### Plugin mappings⌨️

| shortcut       | action                            | mode    | plugins                                                  |
|----------------|-----------------------------------|---------|----------------------------------------------------------|
| `R`            | open rnvimr                       | `n`     | [rnvimr](https://github.com/kevinhwang91/rnvimr)         |
| `gy`           | goyo                              | `n`     | [goyo](https://github.com/junegunn/goyo.vim)             |
| `gw`           | swith `false` and `true`          | `n`     | [antovim](https://github.com/Laughing-q/antovim)         |
| `U`            | Undo tree                         | `n`     | [undotree](https://github.com/Laughing-q/undotree)       |
| `<leader>` `c` | comment                           | `n` `v` | [Comment.nvim](https://github.com/numToStr/Comment.nvim) |
| `<leader>` `v` | toggle function and variable list | `n`     | [vista.vim](https://github.com/liuchengxu/vista.vim)     |

- buffers
  * [barbar.nvim](https://github.com/romgrk/barbar.nvim)

  | shortcut           | action                          | mode |
  |--------------------|---------------------------------|------|
  | `<leader>` `b` `g` | pick a buffer                   | `n`  |
  | `<leader>` `b` `b` | previous buffer                 | `n`  |
  | `<leader>` `b` `w` | wipeout current buffer          | `n`  |
  | `<leader>` `b` `c` | close all buffers but current   | `n`  |
  | `<leader>` `b` `p` | close all buffers but pinned    | `n`  |
  | `<leader>` `b` `j` | close all left buffers          | `n`  |
  | `<leader>` `b` `l` | close all right buffers         | `n`  |
  | `<leader>` `b` `d` | sort buffers by dir             | `n`  |
  | `<leader>` `b` `L` | sort buffers by language        | `n`  |
  | `alt` `l`          | next buffer                     | `n`  |
  | `alt` `j`          | previous buffer                 | `n`  |
  | `alt` `;`          | move current buffer to next     | `n`  |
  | `alt` `h`          | move current buffer to previous | `n`  |
  | `alt` `1`          | first buffer                    | `n`  |
  | `alt` `2`          | second buffer                   | `n`  |

- Packer
  * [Packer.nvim](https://github.com/wbthomason/packer.nvim)

  | shortcut           | action         | mode |
  |--------------------|----------------|------|
  | `<leader>` `p` `c` | packer compile | `n`  |
  | `<leader>` `p` `i` | packer install | `n`  |
  | `<leader>` `p` `s` | packer sync    | `n`  |
  | `<leader>` `p` `S` | packer status  | `n`  |
  | `<leader>` `p` `u` | packer update  | `n`  |

- Git
  * [gitsigns](https://github.com/lewis6991/gitsigns.nvim)
  * [telescope](https://github.com/nvim-telescope/telescope.nvim)

  | shortcut           | action                            | mode |
  |--------------------|-----------------------------------|------|
  | `<leader>` `g` `k` | next hunk                         | `n`  |
  | `<leader>` `g` `i` | previous hunk                     | `n`  |
  | `<leader>` `g` `l` | blame                             | `n`  |
  | `<leader>` `g` `p` | preview hunk                      | `n`  |
  | `<leader>` `g` `r` | reset hunk                        | `n`  |
  | `<leader>` `g` `R` | reset buffer                      | `n`  |
  | `<leader>` `g` `s` | stage hunk                        | `n`  |
  | `<leader>` `g` `u` | undo stage hunk                   | `n`  |
  | `<leader>` `g` `o` | open change file                  | `n`  |
  | `<leader>` `g` `b` | checkout branch                   | `n`  |
  | `<leader>` `g` `c` | checkout commit                   | `n`  |
  | `<leader>` `g` `C` | checkout commit(for current file) | `n`  |
  | `<leader>` `g` `d` | git diff                          | `n`  |

- LSP
  * [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
  * [nvim-lsp-installer](https://github.com/williamboman/nvim-lsp-installer)
  * [telescope](https://github.com/nvim-telescope/telescope.nvim)

  | shortcut              | action                | mode |
  |-----------------------|-----------------------|------|
  | `<leader>` `L` `L`    | open LSP              | `n`  |
  | `<leader>` `L` `l`    | close LSP             | `n`  |
  | `<leader>` `L` `a`    | code action           | `n`  |
  | `<leader>` `L` `d`    | document diagnostics  | `n`  |
  | `<leader>` `L` `w`    | workspace diagnostics | `n`  |
  | `<leader>` `L` `f`    | format                | `n`  |
  | `<leader>` `L` `h`    | LspInfo               | `n`  |
  | `<leader>` `L` `k`    | next diagnostic       | `n`  |
  | `<leader>` `L` `i`    | previous diagnostic   | `n`  |
  | `<leader>` `L` `q`    | quickfix              | `n`  |
  | `<leader>` `L` `r`    | rename                | `n`  |
  | `<leader>` `L` `s`    | document symbols      | `n`  |
  | `<leader>` `L` `S`    | workspace symbols     | `n`  |
  
- Telescope(finder)
  * [telescope](https://github.com/nvim-telescope/telescope.nvim)

  | shortcut           | action                      | mode |
  |--------------------|-----------------------------|------|
  | `<leader>` `f` `f` | find file                   | `n`  |
  | `<leader>` `f` `o` | find old file               | `n`  |
  | `<leader>` `f` `a` | find hidden file            | `n`  |
  | `<leader>` `f` `w` | find word                   | `n`  |
  | `<leader>` `f` `s` | find spell                  | `n`  |
  | `<leader>` `f` `n` | find work in current buffer | `n`  |
  | `<leader>` `f` `j` | find word under the cursor  | `n`  |
  | `<leader>` `f` `b` | find buffers                | `n`  |
  | `<leader>` `f` `C` | find colorscheme            | `n`  |
  | `<leader>` `f` `M` | find man page               | `n`  |
  | `<leader>` `f` `h` | find help                   | `n`  |
  | `<leader>` `f` `r` | find register               | `n`  |
  | `<leader>` `f` `k` | find keymappings            | `n`  |
  | `<leader>` `f` `c` | find commands               | `n`  |
  | `<leader>` `f` `p` | find projects               | `n`  |
  | `<leader>` `f` `y` | find clipboard              | `n`  |

- faster jump
  * [lightspeed](https://github.com/ggandor/lightspeed.nvim)

  | shortcut | action                        | mode |
  |----------|-------------------------------|------|
  | `K`      | search char and jump          | `n`  |
  | `I`      | search char and jump(reverse) | `n`  |

- nvimtree
  * [nvimtree](https://github.com/kyazdani42/nvim-tree.lua)

  | shortcut       | action               | mode |
  |----------------|----------------------|------|
  | `<leader>` `e` | open nvimtree(focus) | `n`  |
  | `ctrl` `n`     | nvimtree             | `n`  |

- markdown
  | shortcut           | action                             | mode |
  |--------------------|------------------------------------|------|
  | `<leader>` `m` `m` | toggle table mode in markdown file | `n`  |
  | `<leader>` `m` `g` | generate catalog for markdown file | `n`  |


- `<leader>` = `<space>`
- More details see [mappings.lua](./lua/keymappings.lua) and [which-key.lua](./lua/plugins/configs/which-key.lua)

## Reference🍔
- [https://github.com/NvChad/NvChad](https://github.com/NvChad/NvChad)
- [https://github.com/LunarVim/LunarVim](https://github.com/LunarVim/LunarVim)
- [https://github.com/theniceboy/nvim](https://github.com/theniceboy/nvim)
