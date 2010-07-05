" s:FilterList:  {{{
" Description: 
function! s:FilterList()
    let origPat = @/
    let curpos = getpos('.')

    let pattern = substitute(getline(1), 'Enter pattern: ', '', 'g')
    if stridx(pattern, s:pattern, 0) == -1
        " This is a completely new pattern, so we need to start afresh
        silent! 2,$ d_
        call setline(2, s:allLines)
    end
    let s:pattern = pattern

    let words = split(pattern, ' ')
    for word in words
        exec 'silent! 2,$ v/'.word.'/d_'
    endfor

    if search('^>', 'n') == 0
        call setline(2, substitute(getline(2), '^\s', '>', ''))
    endif

    call setpos('.', curpos)
    let @/ = origPat
    return ''
endfunction " }}}
" s:MoveSelection: {{{
" Description: 
function! s:MoveSelection(offset)
    let n = search('^>', 'n')
    if n == 0
        let n = 2
    else
        call setline(n, substitute(getline(n), '^>', ' ', ''))
    end
    let n = n + a:offset

    let n = min([n, line('$')])
    let n = max([2, n])

    let nline = getline(n)
    let nline = substitute(nline, '^\s', '>', '')
    call setline(n, nline)
endfunction " }}}
" s:OpenSelection:  {{{
" Description: 
function! s:OpenSelection()
    let n = search('^>', 'n')
    if n == 0
        let n = 2
    endif
    let f = substitute(getline(n), '^\(>\)\=\s*', '', '')
    exec 'drop '.f
endfunction " }}}
" s:MapSingleKey:  {{{
" Description: 
function! s:MapSingleKey(key)
    exec 'inoremap <silent> <buffer> '.a:key.' '.a:key.'<C-R>=<SID>FilterList()<CR>'
endfunction " }}}
" s:SafeBackspace:  {{{
" Description: 
function! s:SafeBackspace()
    if col('.') > 16
        return "\<bs>"
    else
        return ""
    endif
endfunction " }}}
" s:MapKeys:  {{{
" Description: 
function! s:MapKeys()
    setlocal hls
    for i in range(26)
        call s:MapSingleKey(nr2char(char2nr('a') + i)) 
        call s:MapSingleKey(nr2char(char2nr('A') + i)) 
    endfor
    for i in range(10)
        call s:MapSingleKey(nr2char(char2nr('0') + i))
    endfor
    call s:MapSingleKey('_')
    call s:MapSingleKey('<space>')
    call s:MapSingleKey('<del>')

    inoremap <buffer> <silent> <bs>     <C-r>=<sid>SafeBackspace()<CR><C-r>=<sid>FilterList()<CR>

    inoremap <buffer> <silent> <C-p>    <C-o>:call <sid>MoveSelection(-1)<CR>
    inoremap <buffer> <silent> <C-k>    <C-o>:call <sid>MoveSelection(-1)<CR>
    inoremap <buffer> <silent> <Up>     <C-o>:call <sid>MoveSelection(-1)<CR>

    inoremap <buffer> <silent> <C-n>    <C-o>:call <sid>MoveSelection(1)<CR>
    inoremap <buffer> <silent> <C-j>    <C-o>:call <sid>MoveSelection(1)<CR>
    inoremap <buffer> <silent> <Down>   <C-o>:call <sid>MoveSelection(1)<CR>

    inoremap <buffer> <silent> <CR>     <esc>:call <sid>OpenSelection()<CR>

    inoremap <buffer> <silent> <esc>    <esc>:e #<cr>
    nnoremap <buffer> <silent> <esc>    :e #<cr>

    " Avoids weird problems in terminal vim
    inoremap <buffer> <silent> A <Nop>
    inoremap <buffer> <silent> B <Nop>
    nnoremap <buffer> <silent> A <Nop>
    nnoremap <buffer> <silent> B <Nop>
endfunction " }}}
" StartFiltering:  {{{
" Description: 
function! mw#open#StartFiltering()
    call matchadd('Search', '^>.*')
    let s:pattern = ''
    let s:allLines = getline(0, '$')
    call s:MapKeys()
    0put='Enter pattern: '
    startinsert!
endfunction " }}}

" mw#open#OpenFile: opens a file in the solution {{{
" Description: 
function! mw#open#OpenFile()
    drop _MW_Files_
    let bufnum = bufnr('%')
    call setbufvar(bufnum, '&swapfile', 0)
    call setbufvar(bufnum, '&buflisted', 0)
    call setbufvar(bufnum, '&buftype', 'nofile')
    call setbufvar(bufnum, '&ts', 8)
    call setbufvar(bufnum, '&ww', '')

    let filelist = system('listFiles.py')
    silent! 0put=filelist
    silent! %s/^/    /g

    call mw#open#StartFiltering()
endfunction " }}}
