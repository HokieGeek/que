"" Highlights {{{
highlight SL_HL_Default ctermbg=233 ctermfg=249 cterm=none
highlight SL_HL_Mode ctermbg=55 ctermfg=7 cterm=bold
highlight SL_HL_PasteWarning ctermbg=140 ctermfg=232 cterm=bold

highlight SL_HL_FileNotModifiedNotReadOnly ctermbg=233 ctermfg=249 cterm=none
highlight SL_HL_FileNotModifiedReadOnly ctermbg=233 ctermfg=88 cterm=bold
highlight SL_HL_FileModifiedNotReadOnly ctermbg=22 ctermfg=7 cterm=none
highlight SL_HL_FileModifiedReadOnly ctermbg=22 ctermfg=196 cterm=bold

highlight SL_HL_FileNotModifiableNotReadOnly ctermbg=88 ctermfg=232 cterm=bold
highlight SL_HL_FileNotModifiableReadOnly ctermbg=88 ctermfg=9 cterm=bold

highlight SL_HL_FileTypeIsUnix ctermbg=233 ctermfg=239 cterm=none
highlight SL_HL_FileTypeNotUnix ctermbg=52 ctermfg=233 cterm=none

highlight SL_HL_CapsLockWarning ctermbg=118 ctermfg=232 cterm=bold

highlight SL_HL_FileInfo ctermbg=234 ctermfg=244 cterm=none
highlight SL_HL_FileInfoTotalLines ctermbg=234 ctermfg=239 cterm=none
" }}}

function! UpdateStatusLine()
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
