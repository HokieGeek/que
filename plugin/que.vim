function! UpdateStatusLine()
    call que#DefineHighlights()
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
    autocmd BufEnter,WinEnter,BufWritePost * set statusline=%!UpdateStatusLine()
" endfunction

" vim: set foldmethod=marker number relativenumber formatoptions-=tc:
