setlocal cinoptions=:0,g2,h2,(0,:2,=2,l1,W4

" We first remove the double slash and add it after the triple slash,
" otherwise things seem to not work.
setlocal comments-=://
setlocal comments+=:///
setlocal comments+=://

setlocal completeopt=menu,preview,longest
setlocal pumheight=10

let b:tag_if = "if (<++>) {\<CR><++>\<CR>}"
let b:tag_for = "for (<++>; <++>; <++>) {\<CR><++>\<CR>}"
let b:tag_else = "else {\<CR><++>\<CR>}"
imap <silent> <buffer> <C-e> <C-r>=C_CompleteWord()<CR>

if exists('b:did_mw_c_ftplugin')
    finish
endif
let b:did_mw_c_ftplugin = 1

call mw#tag#AddSandboxTags(expand('%:p'))

if exists('*ToggleSrcHeader')
    finish
endif

" ToggleSrcHeader: toggles between a .h and .c file  {{{
" (as long as they are in the same directory)
fun! ToggleSrcHeader()
    let fname = expand('%:p:r')
    let ext = expand('%:e')
    if ext =~ '[cC]'
        let other = glob(fname.'.h*')
    else
        let other = glob(fname.'.c*')
    endif
    let other = split(other, '\n\|\r')[0]
    if strlen(other) > 0
        exec 'drop '.other
    endif
endfunction " }}}
command! -nargs=0 EH :call ToggleSrcHeader()

" CompleteTag: makes a tag from last word {{{
function! C_CompleteWord()
    let line = strpart(getline('.'), 0, col('.')-1)

    let word = matchstr(line, '\w\+$')
    if word != '' && exists('b:tag_'.word)
        let back = substitute(word, '.', "\<BS>", 'g')
        return IMAP_PutTextWithMovement(back.b:tag_{word})
    else
        return ''
    endif
endfunction " }}}

