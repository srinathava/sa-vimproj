" ==============================================================================
" Sandbox commands
" ============================================================================== 
let s:scriptPath = expand('<sfile>:p:h')

" mw#sbtools#DiffWithOther: diffs with file in another sandbox {{{
function! mw#sbtools#DiffWithOther(otherDir)
    let otherDir = mw#utils#NormalizeSandbox(a:otherDir)
	let otherFileName = mw#utils#GetOtherFileName(otherDir)
    call mw#utils#AssertError(otherFileName != '',  'No equivalent file found in other sandbox')

    " make this the only window.
    wincmd o
    call mw#utils#AssertError(winnr('$') == 1, 'Could not close all other open windows')

    call mw#utils#SaveSettings(['diff', 'foldcolumn', 'foldenable', 'scrollbind', 'wrap'])
	exec 'rightb vert diffsplit '.otherFileName
    nmap <buffer> q :q<CR>:call mw#utils#RestoreSettings()<CR>
endfunction " }}}
" mw#sbtools#SplitWithOther: opens equivalent file in other sandbox {{{
function! mw#sbtools#SplitWithOther(otherDir)
    let otherDir = mw#utils#NormalizeSandbox(a:otherDir)
	let otherFileName = mw#utils#GetOtherFileName(otherDir)
    call mw#utils#AssertError(otherFileName != '',  'No equivalent file found in other sandbox')
    exec 'rightb vert split '.otherFileName
endfunction " }}}
" mw#sbtools#DiffWriteable2: diffs all writeable files {{{
" Description: diffs all writeable files in the present sandbox with the
" corresponding files in the other sandbox
function! mw#sbtools#DiffWriteable2(sb1, sb2)
    let g:DirDiffCmd = 'diffwriteable'
    let g:DirDiffCmdOpts = ''

    call PrintDebug('DirDiff '.a:sb1.' '.a:sb2, 'sbtools')
    exec 'DirDiff '.a:sb1.' '.a:sb2
    1 wincmd w
endfunction " }}}
" mw#sbtools#DiffWriteable1: diffs all writeable files {{{
" Description: diffs all writeable files in the present sandbox with the
" corresponding files in the other sandbox
function! mw#sbtools#DiffWriteable1(sb2)
    let sb1 = mw#utils#GetRootDir()
    call mw#utils#AssertError(sb1 != '', 'The present file doesn''t lie in a sandbox.')

    let sb2 = mw#utils#NormalizeSandbox(a:sb2)
    call mw#sbtools#DiffWriteable2(sb1, sb2)
endfunction " }}}
" mw#sbtools#DiffSubmitFile: diffs files in submit file {{{
" Description: 
function! mw#sbtools#DiffSubmitFile(sb1, ...)
    let sb2 = mw#utils#GetRootDir()
    call mw#utils#AssertError(sb2 != '', 'The present file doesn''t lie in a sandbox.')

    let sb1 = mw#utils#NormalizeSandbox(a:sb1)
    if sb1 == ''
        echohl WarningMsg
        echomsg "Cannot find sandbox ".a:sb1
        echohl None
        return
    end

    if a:0 > 0
        let submitFile = a:1
    else
        if !filereadable(sb2.'/submitList')
            call mw#utils#AssertError(0, 'There is no submit file in the root of the current sandbox.')
        endif
        let submitFile = matchstr(readfile(sb2.'/submitList'), '\S\+')
    endif
    if !filereadable(submitFile)
        call mw#utils#AssertError(0, submitFile.' is not readable')
    endif

    let g:DirDiffCmd = 'diffsubmitfile.py'
    let g:DirDiffCmdOpts = '-f '.submitFile

    call PrintDebug('DirDiff '.sb2.' '.sb1, 'sbtools')
    exec 'DirDiff '.sb2.' '.sb1
    1 wincmd w
endfunction " }}}
" mw#sbtools#SaveSession:  {{{
" Description: 

let s:sessionFileName = ''
function! mw#sbtools#SaveSession()
    if s:sessionFileName == ''
        let s:sessionFileName = mw#utils#GetRootDir().'/session.vim'
    endif

    let origSessOpts = &sessionoptions
    let &sessionoptions = 'buffers,globals,winpos,winsize,curdir,resize'
    exec 'mksession! '.s:sessionFileName
    let &sessionoptions = origSessOpts
endfunction " }}}
" mw#sbtools#LoadSession:  {{{
" Description: 
function! mw#sbtools#LoadSession()
    let s:sessionFileName = mw#utils#GetRootDir().'/session.vim'
    exec 'source '.s:sessionFileName
    redraw!

    augroup SaveSessionOnLeave
        au VimLeavePre * call mw#sbtools#SaveSession()
    augroup END
endfunction " }}}

" ==============================================================================
" Findign in project/solution
" ============================================================================== 
" mw#sbtools#FindIn:  {{{
" Description: 
function! mw#sbtools#FindIn(prog)
    let input = input('Enter grep options and pattern: ')
    if input == ''
        return
    endif

    exec 'cd '.expand('%:p:h')
    let orig_grepprg = &grepprg
    let &grepprg = a:prog.' $*'
    exec 'silent! grep! '.input
    let &grepprg = orig_grepprg
    cwindow
endfunction " }}}
" mw#sbtools#FindInProj: finds pattern in project {{{
function! mw#sbtools#FindInProj()
    call mw#sbtools#FindIn('findinproj.py')
endfunction " }}}
" mw#sbtools#FindInSolution: finds pattern in project {{{
function! mw#sbtools#FindInSolution()
    call mw#sbtools#FindIn('findinsoln.py')
endfunction " }}}

" vim: fdm=marker
