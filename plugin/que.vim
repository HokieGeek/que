if exists("g:loaded_que") || v:version < 700
    finish
endif
let g:loaded_que = 1

if !exists("g:que__vcs_section_enabled")
    let g:que__vcs_section_enabled = 1
endif

function! UpdateStatusLine()
    " echomsg "UpdateStatusLine(): ".winnr()
    " for win_num in filter(range(1, winnr('$')), 'v:val != winnr()')
        " call setwinvar(win_num, '&statusline', que#GetStatusLine(win_num, 0))
    " endfor
    " return que#GetStatusLine(winnr(), 1)
    for win_num in range(1, winnr('$'))
        " echomsg win_num." == ".winnr().": "(win_num == winnr())
        " let l:sl="%{UpdateStatusLine()}".que#GetStatusLine(win_num)
        let l:sl="%!que#GetStatusLine(".win_num.")"
        call setwinvar(win_num, '&statusline', l:sl)
    endfor
    return ""
endfunction

function! QueDisableStatusLine()
    autocmd! Que
    execute "set statusline=".g:que__original_status
endfunction

function! QueEnableStatusLine()
    let l:sl = getwinvar(winnr(), '&statusline')
    let g:que__original_status = l:sl

    augroup Que
        autocmd!
        autocmd VimEnter,ColorScheme * call que#DefineHighlights()
        autocmd BufEnter * if !exists("b:que__defined_highlights") | call que#DefineHighlights() | endif
        autocmd BufEnter,WinEnter,BufWritePost * set statusline=%!UpdateStatusLine()
    augroup END

    call que#DefineHighlights()
    set statusline=%!UpdateStatusLine()
endfunction

if !exists("g:que__disable_on_start")
    call QueEnableStatusLine()
endif

" vim: set foldmethod=marker formatoptions-=tc:
