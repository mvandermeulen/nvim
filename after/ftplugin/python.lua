vim.wo.spell       = false
vim.bo.shiftwidth  = 2
vim.bo.tabstop     = 2
vim.bo.softtabstop = 2
vim.bo.expandtab   = true
vim.bo.textwidth   = 0
vim.bo.autoindent	 = true
vim.bo.smartindent = true

-- Show line after desired maximum text width
vim.opt_local.colorcolumn = '89'

-- vim.bo.formatprg = "black --quiet -"
-- vim.bo.makeprg = "flake8 %:S"
-- vim.bo.errorformat = "%f:%l:%c: %t%n %m"
-- vim.env.PATH = ".venv/bin:" .. vim.env.PATH



-- set shiftwidth=2 tabstop=2 softtabstop=2 expandtab autoindent smartindent
-- setlocal colorcolumn=80

-- setlocal path=.,**
-- setlocal wildignore=*/venv/*,*/__pycache__/*,*.pyc

-- function! PyInclude(fname)
--     let parts = split(a:fname, ' import ')
--     let l = parts[0]
--     if len(parts) > 1
--         let r = parts[1]
--         let joined = join([l, r], '.')
--         let fp = substitute(joined, '\.', '/', 'g') . '.py'
--         let found = glob(fp, 1)
--         if len(found)
--             return found
--         endif
--     endif
--     return substitute(l, '\.', '/', 'g') . '.py'
-- endfunction
-- setlocal includeexpr=PyInclude(v:fname)

-- setlocal include=^\\s*\\(from\\\|import\\)\\s*\\zs\\(\\S\\+\\s\\{-}\\)*\\ze\\($\\\|\ as\\)
-- setlocal define=^\\s*\\<\\(def\\\|class\\)\\>
