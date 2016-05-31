if exists("g:autoloaded_que") || v:version < 700
    finish
endif
let g:autoloaded_que = 1
scriptencoding utf-8

" Highlighting {{{
function! que#AssignHL(name,bg,fg,weight)
    let l:gui = "guibg=".a:bg[0]." guifg=".a:fg[0]
    let l:term = "ctermbg=".a:bg[1]." ctermfg=".a:fg[1]." cterm=".a:weight
    execute "highlight SL_HL_".a:name." ".l:gui." ".l:term
endfunction
function! que#DefineHighlights()
    let l:default_bg = ["#0c0c0c", "233"]
    let l:default_fg = ["#919191", "249"]
    let l:red_dark   = ["#ce0000", "52"] "88
    let l:red_bright = ["#ce0000", "196"]
    let l:green      = ["#0c8f0c", "22"]
    let l:white      = ["#ffffff", "7"]
    let l:black      = ["#000000", "232"]
    let l:dark_grey  = ["#404040", "239"]

    " let l:mode_bg    = ["#5f00d7", "56"] " purple
    let l:mode_bg    = ["#3a3a3a", "237"] " gray

    let l:paste_bg   = ["#af87d7", "140"]

    call que#AssignHL("Default",                  l:default_bg, l:default_fg, "none")
    call que#AssignHL("Mode",                     l:mode_bg,    l:black,      "none")
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

    call que#AssignHL("SchemeName",               l:default_bg, l:black,      "none")

    if exists(":SyntasticCheck")
        call que#AssignHL("SyntasticError",       l:red_dark,   l:white,      "bold")
    endif

    let b:que__defined_highlights=0
endfunction
" }}}

function! que#GetStatusLine(win_num, active) " {{{
    " echom "que#GetStatusLine(".a:win_num." [".bufname(winbufnr(a:win_num))."], ".a:active.")"
    let l:activeIndicator=que#GenerateActiveIndicator(a:active)
    let l:sl=getwinvar(a:win_num, 'que__cached_status')
    if a:active == 1 || len(l:sl) <= 0
        let l:sl=que#GenerateStatusLine(a:win_num)
        call setwinvar(a:win_num, 'que__cached_status', l:sl)
    endif
    return l:activeIndicator.l:sl
endfunction " }}}

function! que#GenerateActiveIndicator(isactive) " {{{
    if a:isactive == 1
        let l:mode="%#SL_HL_mode#\ %{mode()}\ %#SL_HL_Default#"
    else
        let l:mode="%#SL_HL_Default#\ \ \ "
    endif

    return l:mode
endfunction

function! que#GenerateStatusLine(win_num) " {{{
    " echomsg " que#GenerateStatusLine(".a:win_num.")"
    let l:buf_num = winbufnr(a:win_num)

    " Mode and active indicator
    let l:statusline=""
    if getbufvar(l:buf_num, '&paste')
        let l:statusline.="%#SL_HL_PasteWarning# PASTE %#SL_HL_Default#"
    endif

    " File name, type and modified
    let l:filename = bufname(l:buf_num)
    if len(l:filename) > 0 " {{{
        if getbufvar(l:buf_num, '&modifiable')
            if getbufvar(l:buf_num, '&modified')
                if getbufvar(l:buf_num, '&readonly')
                    let l:statusline.="%#SL_HL_ModifiedReadOnly#"
                else
                    let l:statusline.="%#SL_HL_ModifiedNotReadOnly#"
                endif
            else
                if getbufvar(l:buf_num, '&readonly')
                    let l:statusline.="%#SL_HL_NotModifiedReadOnly#"
                else
                    let l:statusline.="%#SL_HL_NotModifiedNotReadOnly#"
                endif
            endif
        else
            if getbufvar(l:buf_num, '&readonly')
                let l:statusline.="%#SL_HL_NotModifiableReadOnly#"
            else
                let l:statusline.="%#SL_HL_NotModifiableNotReadOnly#"
            endif
        endif
        if index(argv(), bufname(l:buf_num)) == -1
            if has("win32unix") || has("win32") || has("win64")
                let l:statusline.="¬"
            else
                let l:statusline.="♮"
            endif
        else
            let l:statusline.="\ "
        endif
        let l:statusline.="%f\ "
    endif " }}}

    let l:ft = getbufvar(l:buf_num, '&filetype')
    if len(l:ft) > 0
        if getbufvar(l:buf_num, '&fileformat') == 'unix'
            let l:statusline.="%#SL_HL_TypeIsUnix#"
        else
            let l:statusline.="%#SL_HL_TypeNotUnix#"
        endif
        let l:statusline.=l:ft."\ "
    endif

    " Display git info
    if g:que__vcs_section_enabled
        if exists("g:que__vcs_info")
            let l:statusline.=g:que__vcs_info
        elseif exists("g:Que__vcs_funcref")
            let l:statusline.=g:Que__vcs_funcref()
        endif
    endif

    " Right-justify the rest
    let l:statusline.="%#SL_HL_Default#%="

    " Syntastic flag
    if exists(":SyntasticCheck")
        let l:statusline.="%#SL_HL_SyntasticError#%{SyntasticStatuslineFlag()}%#SL_HL_Default#"
    endif

    if exists("g:colors_name") > 0
        let l:statusline.="%#SL_HL_SchemeName# ".g:colors_name." %#SL_HL_Default#"
    endif

    let l:statusline.="%#SL_HL_FileInfo#\ %l%#SL_HL_InfoTotalLines#/%L%#SL_HL_FileInfo#"
    let l:statusline.=",%c\ %P"

    let l:statusline.="%*"

    return l:statusline
endfunction " }}}

" vim: set foldmethod=marker formatoptions-=tc:
