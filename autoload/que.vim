function! que#DefineHighlights() "{{{
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
endfunction " }}}

function! que#GetStatusLine(win_num) " {{{
    " echomsg "Updating: ".a:win_num
    let l:buf_num = winbufnr(a:win_num)

    " TODO: change the bg of the mode indicator
    let l:mode = ((a:win_num == winnr()) ? mode() : " ")
    let l:statusline="%#SL_HL_mode#\ ".l:mode."\ %#SL_HL_Default#"
    " let l:statusline="%#SL_HL_mode#\ %{mode()}\ %#SL_HL_Default#"
    if getbufvar(l:buf_num, '&paste') == 1
    " if &paste == 1
        " TODO: Paste ▶
        let l:statusline.="%#SL_HL_PasteWarning# PASTE %#SL_HL_Default#"
    endif
    " nnoremap <silent> cow :setlocal wrap!<cr>
    " nnoremap <silent> cos :setlocal spell!<cr>

    " File name, type and modified
    let l:filename = bufname(l:buf_num)
    if len(l:filename) > 0
        let l:statusline.="\ "
        if getbufvar(l:buf_num, '&modifiable') == 1
            if getbufvar(l:buf_num, '&modified') == 1
                if getbufvar(l:buf_num, '&readonly') == 0
                    let l:statusline.="%#SL_HL_FileModifiedNotReadOnly#"
                else
                    let l:statusline.="%#SL_HL_FileModifiedReadOnly#"
                endif
            else
                if getbufvar(l:buf_num, '&readonly') == 0
                    let l:statusline.="%#SL_HL_FileNotModifiedNotReadOnly#"
                else
                    let l:statusline.="%#SL_HL_FileNotModifiedReadOnly#"
                endif
            endif
        else
            if getbufvar(l:buf_num, '&readonly') == 0
                let l:statusline.="%#SL_HL_FileNotModifiableNotReadOnly#"
            else
                let l:statusline.="%#SL_HL_FileNotModifiableReadOnly#"
            endif
        endif
        let l:statusline.="\ ".l:filename."\ "
    endif

    let l:ft = getbufvar(l:buf_num, '&filetype')
    if len(l:ft) > 0
        if getbufvar(l:buf_num, '&fileformat') == 'unix'
            let l:statusline.="%#SL_HL_FileTypeIsUnix#"
        else
            let l:statusline.="%#SL_HL_FileTypeNotUnix#"
        endif
        let l:statusline.="\ ".l:ft."\ "
    endif

    " Display git info
    " let l:tmp=vit#StatusLine(a:win_num)
    " echomsg "TMP: ".l:tmp
    " let l:statusline.=l:tmp
    let l:statusline.=vit#StatusLine(a:win_num)
    " let l:statusline.=vit#StatusLine()

    " Right-justify the rest
    let l:statusline.="%#SL_HL_Default#"
    let l:statusline.="%="

    " Syntastic flag
    let l:statusline.="%#warningmsg#"
    let l:statusline.="%{SyntasticStatuslineFlag()}"
    let l:statusline.="%#SL_HL_Default#"

    " TODO: This gets expensive
    " let l:capsState = system("xset -q | grep \"Caps Lock\" | awk '{ print $2$3$4 }'")
    " if match(l:capsState, "on") > -1
        " let l:statusline.="%#SL_HL_CapsLockWarning# CAPS %#SL_HL_Default#"
    " endif

    let l:statusline.="%#SL_HL_FileInfo#\ %l%#SL_HL_FileInfoTotalLines#/%L%#SL_HL_FileInfo#"
    let l:statusline.=",%c\ %P"

    let l:statusline.="%*"

    return l:statusline
    " call setwinvar(a:win_num, '&statusline', l:statusline)
endfunction " }}}

" vim: set foldmethod=marker number relativenumber formatoptions-=tc:
