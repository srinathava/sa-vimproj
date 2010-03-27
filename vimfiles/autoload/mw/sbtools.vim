" ==============================================================================
" Sandbox commands
" ============================================================================== 
let s:scriptPath = expand('<sfile>:p:h')

if !exists('*PrintDebug')
function! PrintDebug(...)
endfunction
endif

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
" Finding in project/solution
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
    call mw#sbtools#FindIn('findInProj.py')
endfunction " }}}
" mw#sbtools#FindInSolution: finds pattern in project {{{
function! mw#sbtools#FindInSolution()
    call mw#sbtools#FindIn('findInSoln.py')
endfunction " }}}

" ==============================================================================
" Editing files fast
" ============================================================================== 
let g:EditFileComplete_Debug = ''
let s:lastArg = ''
" mw#sbtools#EditFileCompleteFunc {{{
function! mw#sbtools#EditFileCompleteFunc(A,L,P)
    " let g:EditFileComplete_Debug .= "called with '".a:A."', lastArg = '".s:lastArg."'\n"

    let alreadyFiltered = 0
    if s:lastArg != '' && a:A =~ '^'.s:lastArg
        let files = s:lastFiles
        let alreadyFiltered = 1
    else
        let g:EditFileComplete_Debug .= "doing sblocate\n"
        let files = split(system('sblocate '.a:A), "\n")
    end
    " let g:EditFileComplete_Debug .= "files = ".join(files, "\n")."\n"

    if alreadyFiltered == 0
        call filter(files, 'v:val !~ "CVS"')
        call filter(files, 'v:val =~ "\\(cpp\\|hpp\\|m\\)$"')
        " call filter(files, 'v:val =~ "matlab/\\(src/\\(cg_ir\\|rtwcg\\|simulink\\)\\|toolbox/stateflow\\|test/tools/sfeml\\)"')
        call filter(files, 'v:val =~ "/'.a:A.'[^/]*$"')
        call map(files, 'matchstr(v:val, "'.a:A.'[^/]*$")') 
    else
        call filter(files, 'v:val =~ "^'.a:A.'"')
    endif

    let s:lastArg = a:A
    let s:lastFiles = files
    return files
endfun
" }}}
" mw#sbtools#EditFileUsingLocate {{{
function! mw#sbtools#EditFileUsingLocate(file)
    let files = split(system('sblocate '.a:file), "\n")
    for f in files
        if filereadable(f) && f =~ a:file.'$'
            exec 'drop '.f
            return
        endif
    endfor
endfun
" }}}

" ==============================================================================
" Compiling projects
" ============================================================================== 
" s:SetMakePrg: sets the 'makeprg' option for the current buffer {{{

let g:MWDebug = 1
function! s:SetMakePrg()
    let &l:makeprg = 'vim_make NORUNTESTS=1'
    if g:MWDebug == 1
        let &l:makeprg .= ' DEBUG=1'
    endif
endfunction " }}}
" mw#sbtools#CompileProject: compiles the present flag {{{
function! mw#sbtools#CompileProject()
    let olddir = getcwd()
    let filePath = expand('%:p:h')

    let modDepFilePath = findfile('MODULE_DEPENDENCIES', filePath.';')
    if modDepFilePath != ''
        exec 'cd '.fnamemodify(modDepFilePath, ':p:h')
    elseif filePath =~ 'matlab/toolbox/stateflow/src'
        exec 'cd '.matchstr(filePath, '^.*toolbox/stateflow/src')
    elseif filePath =~ 'matlab/src'
        exec 'cd '.matchstr(filePath, '^.*matlab/src/\w\+')
    else
        echohl ErrorMsg
        echomsg "Do not know how to handle current file"
        echohl None
        return
    end
    let oldMakePrg = &l:makeprg
    call s:SetMakePrg()
    make!
    let &l:makeprg = oldMakePrg
    cwindow

    if expand('%:p') != ''
        exec 'silent! !genVimTags.py '.expand('%:p').' &'
    endif

    exec 'cd '.olddir
endfunction " }}}
" mw#sbtools#CompileFile: compiles present file {{{
" Description: 
function! mw#sbtools#CompileFile()
    let olddir = getcwd()

    exec 'cd '.expand('%:p:h')
    let oldMakePrg = &l:makeprg
    let &l:makeprg = "sbcc -skip 'lint RELEASE something' ".expand('%:p')
    make! 
    let &l:makeprg = oldMakePrg
    cwindow
    
    exec 'cd '.olddir
endfunction " }}}

" vim: fdm=marker
