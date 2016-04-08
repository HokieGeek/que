if exists("g:autoloaded_que") || v:version < 700
    finish
endif
let g:autoloaded_que = 1
scriptencoding utf-8

" Highlighting {{{
function! que#AssignHL(name,bg,fg,weight)
    let l:gui = "guibg=".a:bg[0]." guifg=".a:fg[0]
    " echomsg "[".a:name."] ".a:bg[1]
    let l:term = "ctermbg=".a:bg[1]." ctermfg=".a:fg[1]." cterm=".a:weight
    " let l:hl = "highlight SL_HL_".a:name." ".l:gui." ".l:term
    " echomsg "  ".l:hl
    " execute l:hl
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

    let l:git_bg     = ["#f4d224", "178"]
    " let l:hg_bg    = ["#3b97bf", "25"]

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

    call que#AssignHL("GitBranch",                l:git_bg,     l:black,      "none")
    call que#AssignHL("GitModified",              l:git_bg,     l:red_bright, "bold")
    call que#AssignHL("GitStaged",                l:git_bg,     l:green,      "bold")
    call que#AssignHL("GitUntracked",             l:git_bg,     l:white,      "bold")

    call que#AssignHL("SchemeName",               l:default_bg, l:black,      "none")

    if exists(":SyntasticCheck")
        call que#AssignHL("SyntasticError",       l:red_dark,   l:white,      "bold")
    endif

    let b:que__defined_highlights=0
endfunction
" }}}

function! que#GetVitStatusLine(win_num) " {{{
    " let l:current_index_mod = getftime(expand(b:GitDir."/index"))
    " let l:last_index_mod = getbufvar(a:file, "vit_last_index_modification")

    " if l:current_index_mod != l:last_index_mod
        " let l:status = system("git status --porcelain | grep '\<".a:file."\>$'")
        " call setbufvar(a:file, "vit_last_index_modification", l:current_index_mod)
        " call setbufvar(a:file, "vit_file_status", l:status_val)
    " else
        " echomsg "GitFileStatus(".a:file."): NO CHANGE: ".l:current_index_mod." ?= ".l:last_index_mod
    " endif
    " return getbufvar(a:file, "vit_file_status")

    " let l:ctime = localtime() - 1
    " if exists("w:que_vit_last_status_time") && w:que_vit_last_status_time >= l:ctime
    "     let l:status=getwinvar(a:win_num, 'que_vit_last_status')
    " else
        " let l:status=vit#StatusLine(a:win_num)
        let l:branch=vit#GetGitBranch()
        " echomsg "HERE: ".l:branch
        " let l:branch=b:GitBranch
        let l:status=""
        if len(l:branch) > 0
            let l:filename = bufname(winbufnr(a:win_num))
            let l:status=vit#GitFileStatus(l:filename)
            " echomsg "Updating: ".localtime()." [".l:status."]"

            if l:status == 3 " Modified
                let l:hl="%#SL_HL_GitModified#"
            elseif l:status == 4 " Staged and not modified
                let l:hl="%#SL_HL_GitStaged#"
            elseif l:status == 2 " Untracked
                let l:hl="%#SL_HL_GitUntracked#"
            else
                let l:hl="%#SL_HL_GitBranch#"
            endif

            let l:status=l:hl."\ ".l:branch."\ "
            " call setwinvar(a:win_num, 'que_vit_last_status', l:status)
            " call setwinvar(a:win_num, 'que_vit_last_status_time', localtime())
        endif
    " endif
    return l:status
endfunction "}}}

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
    endif

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
        let l:statusline.=que#GetVitStatusLine(a:win_num)
    endif

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

    let l:statusline.="%#SL_HL_FileInfo#\ %l%#SL_HL_InfoTotalLines#/%L%#SL_HL_FileInfo#"
    let l:statusline.=",%c\ %P"

    let l:statusline.="%*"

    return l:statusline
endfunction " }}}

" vim: set foldmethod=marker formatoptions-=tc:
