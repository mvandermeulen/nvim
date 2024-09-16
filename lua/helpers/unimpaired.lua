--[[
-- Unimpaired Helpers
--
-- Author: Mark van der Meulen
-- Updated: 01-06-2022
--]]


-- Taken from: https://github.com/tpope/vim-unimpaired/blob/efdc6475f7ea789346716dabf9900ac04ee8604a/plugin/unimpaired.vim#L230

vim.cmd [[

  function! s:Map(...) abort
    let [mode, head, rhs; rest] = a:000
    let flags = get(rest, 0, '') . (rhs =~# '^<Plug>' ? '' : '<script>')
    let tail = ''
    let keys = get(g:, mode.'remap', {})
    if type(keys) == type({}) && !empty(keys)
      while !empty(head) && len(keys)
        if has_key(keys, head)
          let head = keys[head]
          if empty(head)
            let head = '<skip>'
          endif
          break
        endif
        let tail = matchstr(head, '<[^<>]*>$\|.$') . tail
        let head = substitute(head, '<[^<>]*>$\|.$', '', '')
      endwhile
    endif
    if head !=# '<skip>' && empty(maparg(head.tail, mode))
      return mode.'map ' . flags . ' ' . head.tail . ' ' . rhs
    endif
    return ''
  endfunction

  function! s:BlankUp() abort
    let cmd = 'put!=repeat(nr2char(10), v:count1)|silent '']+'
    if &modifiable
      let cmd .= '|silent! call repeat#set("\<Plug>(unimpaired-blank-up)", v:count1)'
    endif
    return cmd
  endfunction

  function! s:BlankDown() abort
    let cmd = 'put =repeat(nr2char(10), v:count1)|silent ''[-'
    if &modifiable
      let cmd .= '|silent! call repeat#set("\<Plug>(unimpaired-blank-down)", v:count1)'
    endif
    return cmd
  endfunction

  nnoremap <silent> <Plug>(unimpaired-blank-up)   :<C-U>exe <SID>BlankUp()<CR>
  nnoremap <silent> <Plug>(unimpaired-blank-down) :<C-U>exe <SID>BlankDown()<CR>

  nnoremap <silent> <Plug>unimpairedBlankUp   :<C-U>exe <SID>BlankUp()<CR>
  nnoremap <silent> <Plug>unimpairedBlankDown :<C-U>exe <SID>BlankDown()<CR>

  exe s:Map('n', '[<Space>', '<Plug>(unimpaired-blank-up)')
  exe s:Map('n', ']<Space>', '<Plug>(unimpaired-blank-down)')
]]




