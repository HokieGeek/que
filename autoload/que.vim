" Highlighting {{{
function! que#AssignHL(name,bg,fg,weight)
    let l:gui = "guibg=".a:bg[0]." guifg=".a:fg[0]
    let l:term = "ctermbg=".a:bg[1]." ctermfg=".a:fg[1]." cterm=".a:weight
    execute "highlight SL_HL_".a:name." ".l:gui." ".l:term
endfunction
function! que#DefineHighlights()
    let l:default_bg = ["#0C0C0c", "233"]
    let l:default_fg = ["#919191", "249"]
    let l:red_dark   = ["#CE0000", "52"] "88
    let l:red_bright = ["#CE0000", "196"]
    let l:green      = ["#0C8F0C", "22"]
    let l:white      = ["#FFFFFF", "7"]
    let l:black      = ["#000000", "232"]
    let l:dark_grey  = ["#404040", "239"]

    let l:mode_bg    = ["#AE24E5", "93"]
    let l:paste_bg   = ["#AF87D7", "140"]

    let l:git_bg     = ["#F4D224", "178"]
    " let l:hg_bg    = ["#3B97BF", "25"]

    call que#AssignHL("Default",                  l:default_bg, l:default_fg, "none")
    call que#AssignHL("Mode",                     l:mode_bg,    l:white,      "bold")
    call que#AssignHL("PasteWarning",             l:paste_bg,   l:black,      "bold")

    call que#AssignHL("NotModifiedNotReadOnly",   l:default_bg, l:default_fg, "none")
    call que#AssignHL("NotModifiedReadOnly",      l:default_bg, l:red_dark,   "bold")
    call que#AssignHL("ModifiedNotReadOnly",      l:green,      l:white,      "none")
    call que#AssignHL("ModifiedReadOnly",         l:green,      l:red_bright, "bold")

    call que#AssignHL("NotModifiableNotReadOnly", l:red_dark,   l:black,      "bold")
    call que#AssignHL("NotModifiableReadOnly",    l:red_dark,   l:red_bright, "bold")

    call que#AssignHL("TypeIsUnix",               l:default_bg, l:dark_grey,  "none")
    call que#AssignHL("TypeNotUnix",              l:red_dark,   l:default_bg, "none")

    call que#AssignHL("FileInfo",                 l:default_bg, l:default_fg, "none")
    call que#AssignHL("InfoTotalLines",           l:default_bg, l:dark_grey,  "none")

    call que#AssignHL("GitBranch",                l:git_bg,     l:black,      "none")
    call que#AssignHL("GitModified",              l:git_bg,     l:red_bright, "bold")
    call que#AssignHL("GitStaged",                l:git_bg,     l:green,      "bold")
    call que#AssignHL("GitUntracked",             l:git_bg,     l:white,      "bold")

    call que#AssignHL("SchemeName",               l:default_bg, l:default_bg, "none")

    if exists(":SyntasticCheck")
        call que#AssignHL("SyntasticError",       l:red_dark,   l:white,      "bold")
    endif
endfunction
" }}}

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
    if exists(":SyntasticCheck")
        let l:statusline.="%#SL_HL_SyntasticError#%{SyntasticStatuslineFlag()}%#SL_HL_Default#"
    endif

    " TODO: This gets expensive
    " let l:capsState = system("xset -q | grep \"Caps Lock\" | awk '{ print $2$3$4 }'")
    " if match(l:capsState, "on") > -1
        " let l:statusline.="%#SL_HL_CapsLockWarning# CAPS %#SL_HL_Default#"
    " endif
    if exists("g:colors_name") > 0
        let l:statusline.="%#SL_HL_SchemeName# ".g:colors_name." %#SL_HL_Default#"
    endif

    let l:statusline.="%#SL_HL_FileInfo#\ %l%#SL_HL_FileInfoTotalLines#/%L%#SL_HL_FileInfo#"
    let l:statusline.=",%c\ %P"

    let l:statusline.="%*"

    return l:statusline
endfunction " }}}

" vim: set foldmethod=marker number relativenumber formatoptions-=tc:
