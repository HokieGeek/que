if exists("g:loaded_que") || v:version < 700
    finish
endif
let g:loaded_que = 2

if !exists("g:que__vcs_section_enabled")
    let g:que__vcs_section_enabled = 1
endif

function! UpdateStatusLine()
    " echom "UpdateStatusLine(".a:isactive.")"
    call map(filter(range(1, winnr('$')), 'v:val != winnr()'), "setwinvar(v:val, '&statusline', que#GetStatusLine(v:val, 0))")
    return que#GetStatusLine(winnr(), 1)
endfunction

function! QueDisableStatusLine()
    autocmd! Que
    execute "setlocal statusline=".g:que__original_status
endfunction

function! QueEnableStatusLine()
    let l:sl = getwinvar(winnr(), '&statusline')
    let g:que__original_status = l:sl

    augroup Que
        autocmd!
        autocmd VimEnter,ColorScheme * call que#DefineHighlights()
        " autocmd BufEnter,BufRead,BufWritePost * call que#DefineHighlights()
        autocmd WinEnter,BufEnter,BufWritePost * setlocal statusline=%!UpdateStatusLine()
        " autocmd WinLeave * setlocal statusline=%!UpdateStatusLine(0)
    augroup END

    call que#DefineHighlights()
    setlocal statusline=%!UpdateStatusLine()
    " call map(filter(range(1, winnr('$')), 'v:val != winnr()'), "setwinvar(v:val, '&statusline', que#GetStatusLine(v:val, 0))")
endfunction

if !exists("g:que__disable_on_start")
    call QueEnableStatusLine()
endif

" vim: set foldmethod=marker formatoptions-=tc:
