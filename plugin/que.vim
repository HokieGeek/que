if exists("g:loaded_que") || v:version < 700
    finish
endif
let g:loaded_que = 1

if !exists("g:que__vcs_section_enabled")
    let g:que__vcs_section_enabled = 1
endif

function! UpdateStatusLine()
    for win_num in filter(range(1, winnr('$')), 'v:val != winnr()')
        " If not modifiable, save the line as a winvar / use a stored line
        if getbufvar(winbufnr(win_num), '&modifiable')
            let l:sl = getwinvar(win_num, "que__notmodifiable_status")
            if strlen(l:sl) <= 0
                let l:sl = que#GetStatusLine(win_num, 0)
                call setwinvar(win_num, 'que__notmodifiable_status', l:sl)
            endif
        else
            let l:sl = que#GetStatusLine(win_num, 0)
        endif
        call setwinvar(win_num, '&statusline', l:sl)
    endfor
    return que#GetStatusLine(winnr(), 1)
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
        " autocmd BufEnter,BufRead * if !exists("b:que__defined_highlights") | call que#DefineHighlights() | endif
        autocmd BufEnter,BufRead,BufWritePost * call que#DefineHighlights()
        autocmd BufEnter,WinEnter,BufWritePost * set statusline=%!UpdateStatusLine()
    augroup END

    call que#DefineHighlights()
    set statusline=%!UpdateStatusLine()
endfunction

if !exists("g:que__disable_on_start")
    call QueEnableStatusLine()
endif

" vim: set foldmethod=marker formatoptions-=tc:
