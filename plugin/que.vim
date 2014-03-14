function! UpdateStatusLine()
    call que#DefineHighlights()
    " echomsg "UpdateStatusLine(): ".strftime("%d/%m/%Y %H:%M:%S")
    for win_num in filter(range(1, winnr('$')), 'v:val != winnr()')
        " TODO: If not modifiable, save the line as a winvar / use a stored line
        " FIXME: This really seems to break, huh?
        call setwinvar(win_num, '&statusline', que#GetStatusLine(win_num))
    endfor
    return que#GetStatusLine(winnr())
endfunction

" function! QueToggleStatusLine()
    " setlocal statusline=%!UpdateStatusLine()
    " autocmd BufWinEnter * setlocal statusline=%!UpdateStatusLine(winnr())
autocmd BufWinEnter,BufReadPost * set statusline=%!UpdateStatusLine()
" endfunction

" vim: set foldmethod=marker number relativenumber formatoptions-=tc:
