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

    highlight SL_HL_SchemeName ctermbg=118 ctermfg=232 cterm=bold

    highlight SL_HL_FileInfo ctermbg=234 ctermfg=244 cterm=none
    highlight SL_HL_FileInfoTotalLines ctermbg=234 ctermfg=239 cterm=none

    highlight SL_HL_GitBranch ctermbg=25 ctermfg=232 cterm=bold
    highlight SL_HL_GitModified ctermbg=25 ctermfg=88 cterm=bold
    highlight SL_HL_GitStaged ctermbg=25 ctermfg=40 cterm=bold
    highlight SL_HL_GitUntracked ctermbg=25 ctermfg=7 cterm=bold

    highlight SL_HL_SyntasticError ctermbg=88 ctermfg=7 cterm=bold
endfunction " }}}

function! que#GetStatusLine(win_num, active) " {{{
    " echomsg " que#GetStatusLine(".a:win_num.", ".a:active.")"
    let l:buf_num = winbufnr(a:win_num)

    " Mode and active indicator
    if a:active == 1
        let l:mode="%#SL_HL_mode#\ %{mode()}\ %#SL_HL_Default#"
    else
        let l:mode="%#SL_HL_Default#\ \ \ "
    endif
    let l:statusline=l:mode
    if getbufvar(l:buf_num, '&paste')
        let l:statusline.="%#SL_HL_PasteWarning# PASTE %#SL_HL_Default#"
    endif

    " File name, type and modified
    let l:filename = bufname(l:buf_num)
    if len(l:filename) > 0
        " let l:statusline.="\ "
        if getbufvar(l:buf_num, '&modifiable')
            if getbufvar(l:buf_num, '&modified')
                if getbufvar(l:buf_num, '&readonly')
                    let l:statusline.="%#SL_HL_FileModifiedReadOnly#"
                else
                    let l:statusline.="%#SL_HL_FileModifiedNotReadOnly#"
                endif
            else
                if getbufvar(l:buf_num, '&readonly')
                    let l:statusline.="%#SL_HL_FileNotModifiedReadOnly#"
                else
                    let l:statusline.="%#SL_HL_FileNotModifiedNotReadOnly#"
                endif
            endif
        else
            if getbufvar(l:buf_num, '&readonly')
                let l:statusline.="%#SL_HL_FileNotModifiableReadOnly#"
            else
                let l:statusline.="%#SL_HL_FileNotModifiableNotReadOnly#"
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
        " let l:statusline.="\ ".l:ft."\ "
        let l:statusline.=l:ft."\ "
    endif

    " Display git info
    let l:ctime = localtime() - 1
    if exists("w:que_vit_last_status_time") && w:que_vit_last_status_time >= l:ctime
        let l:vit_status=getwinvar(a:win_num, 'que_vit_last_status')
    else
        let l:vit_status=vit#StatusLine(a:win_num)
        call setwinvar(a:win_num, 'que_vit_last_status', l:vit_status)
        call setwinvar(a:win_num, 'que_vit_last_status_time', localtime())
    endif
    let l:statusline.=l:vit_status

    " Right-justify the rest
    let l:statusline.="%#SL_HL_Default#%="

    " Syntastic flag
    let l:statusline.="%#SL_HL_SyntasticError#%{SyntasticStatuslineFlag()}%#SL_HL_Default#"

    " TODO: This gets expensive
    " let l:capsState = system("xset -q | grep \"Caps Lock\" | awk '{ print $2$3$4 }'")
    " if match(l:capsState, "on") > -1
        " let l:statusline.="%#SL_HL_CapsLockWarning# CAPS %#SL_HL_Default#"
    " endif
    if exists("g:colors_name") > 0
        let l:statusline.="%#SL_HL_SchemeName#".g:colors_name." %#SL_HL_Default#"
    endif

    let l:statusline.="%#SL_HL_FileInfo#\ %l%#SL_HL_FileInfoTotalLines#/%L%#SL_HL_FileInfo#"
    let l:statusline.=",%c\ %P"

    let l:statusline.="%*"

    return l:statusline
    " call setwinvar(a:win_num, '&statusline', l:statusline)
endfunction " }}}

" vim: set foldmethod=marker number relativenumber formatoptions-=tc:
