" ==============================================================================
" Sandbox commands
" ============================================================================== 
let s:scriptPath = expand('<sfile>:p:h')

if !exists('*PrintDebug')
function! PrintDebug(...)
endfunction
endif

command! -nargs=1 ReturnWithError 
    \ echohl ErrorMsg |
    \ echomsg <args> |
    \ echohl None |
    \ return

" mw#sbtools#DiffWithOther: diffs with file in another sandbox {{{
function! mw#sbtools#DiffWithOther(otherDir)
    let otherDir = mw#utils#NormalizeSandbox(a:otherDir)
    let otherFileName = mw#utils#GetOtherFileName(otherDir)
    if otherFileName == ''
        ReturnWithError "No equivalent file found in other sandbox"
    endif

    " make this the only window.
    wincmd o
    if winnr('$') != 1
        ReturnWithError 'Could not close all other open windows'
    endif

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
    if sb2 == ''
        ReturnWithError "The present file does not belong to a sandbox"
    endif

    let sb1 = mw#utils#NormalizeSandbox(a:sb1)
    if sb1 == ''
        ReturnWithError "Cannot find sandbox ".a:sb1
    end

    if a:0 > 0
        let submitFile = a:1
    else
        if !filereadable(sb2.'/submitList')
            ReturnWithError "Did not find a file called submitList at the root of the current sandbox ".sb2
        endif
        let submitFile = matchstr(readfile(sb2.'/submitList'), '\S\+')
    endif
    let submitFile = resolve(fnamemodify(submitFile, ':p'))
    if !filereadable(submitFile)
        ReturnWithError "File ".submitFile." is not readable."
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
function! mw#sbtools#FindIn(prog, dir, name)
    let rootDir = mw#utils#GetRootDir()
    if rootDir == ''
        echohl Search
        echomsg "Not in a sandbox directory"
        echohl None
        return
    endif

    let input = input('Enter grep options and pattern ('.a:name.'): ')
    if input == ''
        return
    endif

    let origDir = getcwd()
    let orig_grepprg = &grepprg

    exec 'cd '.a:dir
    let &grepprg = a:prog.' $*'
    exec 'silent! grep! '.input

    let &grepprg = orig_grepprg
    exec 'cd '.origDir

    cwindow
endfunction " }}}
" mw#sbtools#FindInProj: finds pattern in project {{{
function! mw#sbtools#FindInProj()
    call mw#sbtools#FindIn('findInProj.py', expand('%:p:h'), 'grep project')
endfunction " }}}
" mw#sbtools#FindInSolution: finds pattern in project {{{
function! mw#sbtools#FindInSolution()
    call mw#sbtools#FindIn('findInSoln.py', expand('%:p:h'), 'grep solution')
endfunction " }}}
" mw#sbtools#FindUsingSbid: find using sbglobal {{{
" Description: 
function! mw#sbtools#FindUsingSbid()
    call mw#sbtools#FindIn('sbid gid', mw#utils#GetRootDir(), 'sbid')
endfunction " }}}
" mw#sbtools#FindUsingSbglobal: find using sbglobal {{{
" Description: 
function! mw#sbtools#FindUsingSbglobal()
    call mw#sbtools#FindIn('sbglobal -grep-format -x', mw#utils#GetRootDir(), 'sbglobal')
endfunction " }}}
" mw#sbtools#FindUsingSourceCodeSearch: find using source code search {{{
" Description: 
function! mw#sbtools#FindUsingSourceCodeSearch()
    call mw#sbtools#FindIn('findUsingSCSTool.py', mw#utils#GetRootDir(), 'source code search')
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
        call filter(files, 'v:val =~ "\\(cpp\\|hpp\\|\\|c\\|h\\|m\\|cdr\\)$"')
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
    if len(files) == 1
        exec 'drop '.files[0]
        return
    end
    let promptList = ['Multiple files found. Please select one: ']
    for idx in range(len(files))
        call add(promptList, idx.'. '.files[idx])
    endfor
    let choice = inputlist(promptList)
    if choice < 0
        return
    endif
    exec 'drop '.files[choice]
endfun
" }}}

" ==============================================================================
" Compiling projects
" ============================================================================== 
" mw#sbtools#SetCompileLevel:  {{{
" Description: 

if !exists('g:MWCompileLevel')
    let g:MWCompileLevel = 1
endif
function! mw#sbtools#SetCompileLevel()
    let g:MWCompileLevel = inputlist(['Select compiler level:', '1. Mixed compile', '2. Compile in DEBUG at SUPER-STRICT level', '3. Compile in RELEASE at SUPER-STRICT level', '4. Lint in RELEASE mode'])
endfunction " }}}
" s:SetMakePrg: sets the 'makeprg' option for the current buffer {{{

let g:MWDebug = 1
function! s:SetMakePrg()
    let &l:makeprg = 'sbmake -distcc NORUNTESTS=1'
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

    let &l:makeprg = "sbcc"
    if g:MWCompileLevel < 4
        let &l:makeprg .= " -skip 'lint RELEASE noreason'"
    endif
    if g:MWCompileLevel < 3
        let &l:makeprg .= " -skip 'compile RELEASE noreason'"
    end
    if g:MWCompileLevel < 2
        let &l:makeprg .= " -skip 'compile DEBUG noreason'"
    end
    let &l:makeprg .= ' '.expand('%:p')
    make! 
    let &l:makeprg = oldMakePrg
    cwindow
    
    exec 'cd '.olddir
endfunction " }}}
" mw#sbtools#BuildUsingDas:  {{{
function! mw#sbtools#BuildUsingDas()
    let logFile = '/tmp/_DAS_OUTPUT_'.$USER
    exec 'silent! bdelete! '.logFile
    exec 'bot spl '.logFile
    %d_
    set nomodified

    redraw!
    let cmd = input('Enter das command: ', 'das build -t cg_ir -i 0')
    let output = system(cmd)
    0put=output

    if search(': error:') == 0
        q!
        return
    endif

    nmap <buffer> <CR> :call mw#sbtools#TakeMeThere()<CR>

    w
endfunction " }}}
" mw#sbtools#TakeMeThere {{{
function! mw#sbtools#TakeMeThere()
    let matches = matchlist(getline('.'), '\(\f\+\):\(\d\+\).*')
    if len(matches) == 0
        return
    endif
    let fname = matches[1]
    let lnum = matches[2]
    let fullfilename = system('sblocate '.fname)
    exec 'split '.fullfilename
    exec lnum
endfunction
" }}}

" vim: fdm=marker
