if exists('b:loaded_my_matlab')
    finish
end
let b:loaded_my_matlab = 1

if exists('*s:SetLocalSettings')
    call s:SetLocalSettings()
    finish
end

" s:SetLocalSettings: set local settings {{{
" Description: 
function! s:SetLocalSettings()

    setlocal et sts=4 ts=4 sw=4
    setlocal fo-=t
    setlocal makeprg=mylint.py\ %
    let &l:efm='%-P{{%f}}'
        \ . ',%EL %l (C %c-%v): Parse error at%m'
        \ . ',%EL %l (C %c): Parse error at%m'
        \ . ',%WL %l (C %c-%v): %m'
        \ . ',%WL %l (C %c): %m'

    if line('$') < 1000
        call FoldMatlab()
    endif
    setlocal foldtext=MatlabFoldTextFcn(v:foldstart,v:foldlevel)
    nmap <buffer> <F4> :call FoldMatlab()<CR>

    if !exists('s:lintPathSet')
        let s:lintPathSet = 1
        if has('win64')
            let lintPath = '//mathworks/devel/Aslrtw/perfect/matlab/bin/win64'
        elseif has('unix')
            let lintPath = '/devel/Aslrtw/perfect/matlab/bin/glnxa64'
        end
        let $PATH = $PATH . ':' . lintPath
        let s:lintPathSet = 1
    end

endfunction " }}}

" FoldMatlab: folds a MATLAB file {{{
" Description: 
function! FoldMatlab()
    let pos = getpos('.')
    normal! zE
    call FoldMatlabFile()
    silent! 1,$ foldclose!
    call setpos('.', pos)
    normal! zv
endfunction " }}}

" FoldMatlabFile: folds a MATLAB file {{{
" Description: 
function! FoldMatlabFile()
    let foldpat = '^\s*\(function\|classdef\|properties\|methods\)\>'
    let startpat = '^\s*\(function\|classdef\|properties\|methods\|if\|while\|for\|try\|switch\)\>'
    let endpat = '^\s*end\s*$'

    let curline = 1
    while curline <= line('$')
        call cursor(curline, 1)
        if getline(curline) =~ foldpat 
            let nextline = searchpair(startpat, '', endpat, 'n')
            if nextline > curline
                exec curline.','.nextline.' fold'
                exec curline.','.nextline.' foldopen'
            endif
        endif
        let curline = curline + 1
    endwhile
endfunction " }}}

" MatlabFoldTextFcn: {{{
function! MatlabFoldTextFcn(foldstart, foldlevel)
    let foldtxt = repeat(' ', (a:foldlevel-1)*4)

    let line1 = getline(a:foldstart)
    if line1 =~ '^\s*function\>'
        let fcnname = matchstr(line1, '^\s*function\s\+.*=\s*\zs\w\+\ze')
        if fcnname == ''
            let fcnname = matchstr(line1, '^\s*function\s\+\zs\w\+\ze')
        end
        let foldtxt .= fcnname
    else
        let foldtxt .= substitute(line1, '^\s*', '', '')
    end

    let line2 = getline(a:foldstart+1)
    if line2 =~ '^\s*%'
        let comment = ' : '.matchstr(line2, '^\s*%\s*\zs.*')
    else
        let comment = ''
    end
    let foldtxt .= comment
    return foldtxt
endfunction " }}}

" RefreshLintMessages:  {{{
" Description: 
function! RefreshLintMessages()
    if exists('s:lintPathSet')
        silent! make! %
        cwindow
    end
endfunction " }}}

call s:SetLocalSettings()

augroup RefreshLint
    au!
    au BufWritePost   *.m :call RefreshLintMessages()
    au BufWritePost   *.cdr :call RefreshLintMessages()
augroup END

" vim600:fdm=marker
