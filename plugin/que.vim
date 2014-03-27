if exists("g:loaded_que") || v:version < 700
    finish
endif
let g:loaded_que = 1

let g:que__vcs_section_enabled = 1

function! UpdateStatusLine()
    " echomsg "UpdateStatusLine(): ".strftime("%d/%m/%Y %H:%M:%S")
    for win_num in filter(range(1, winnr('$')), 'v:val != winnr()')
        " TODO: If not modifiable, save the line as a winvar / use a stored line
        " if getbufvar(winbufnr(win_num), '&modifiable')
        " endif
        call setwinvar(win_num, '&statusline', que#GetStatusLine(win_num, 0))
    endfor
    return que#GetStatusLine(winnr(), 1)
endfunction

" function! QueToggleStatusLine()
    autocmd VimEnter,ColorScheme * call que#DefineHighlights()
    autocmd BufEnter,WinEnter,BufWritePost * set statusline=%!UpdateStatusLine()
" endfunction

" vim: set foldmethod=marker formatoptions-=tc:
