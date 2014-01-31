if !has('python')
    finish
endif

" MW_AttachToMatlab:  {{{
" Description: 

let s:scriptDir = expand('<sfile>:p:h')
python import sys, vim
exec "python sys.path += [r'".s:scriptDir."']"
python from startMatlab import startMatlab

function! MW_AttachToMatlab(pid, mode)
    call gdb#gdb#Init()

    let rootDir = mw#utils#GetRootDir()
    if rootDir != ""
        call gdb#gdb#RunCommand('source '.rootDir.'/.sbtools/.source-path-gdbinit')
    endif

    if a:mode == '-nojvm'
        call gdb#gdb#RunCommand('handle SIGSEGV stop print')
    else
        call gdb#gdb#RunCommand('handle SIGSEGV nostop noprint')
    endif

    call gdb#gdb#Attach(a:pid)

    " set a bunch of standard breakpoints
    call gdb#gdb#SetQueryAnswer('y')
    call gdb#gdb#RunCommand('bex')
    call gdb#gdb#SetQueryAnswer('')

    call gdb#gdb#Continue()
endfunction " }}}

" MW_StartMatlab:  {{{
" Description: 
function! MW_StartMatlab(attach, mode)
    exec 'python pid = startMatlab("'.a:mode.'")'
    python vim.command('let pid = %d' % pid)

    if pid == 0
        echohl Search
        echomsg 'Cannot find MATLAB process for some reason...'
        echohl None
        return
    endif

    if a:attach != 0
        call MW_AttachToMatlab(pid, a:mode)
    endif
endfunction " }}}

" MW_DebugUnitTests:  {{{
" Description: run the C++ unit tests for the current modules
function! MW_DebugUnitTests(what)
    let projDir = mw#sbtools#GetCurrentProjDir()
    if projDir == ''
        echohl Error
        echomsg "Could not find a project directory for current file"
        echohl None
        return
    end

    if a:what == 'current'
        let fileDirRelPathToProj = strpart(expand('%:p:h'), len(projDir) + 1)
        let testName = substitute(fileDirRelPathToProj, '/', '_', 'g')
    elseif a:what == 'unit'
        let testName = 'unittest'
    elseif a:what == 'pkg'
        let testName = 'pkgtest'
    endif

    let sbrootDir = mw#utils#GetRootDir()

    " This is the directory where 'battree' is found
    let mlroot = sbrootDir.'/matlab'

    let projRelPathToMlRoot = strpart(projDir, len(mlroot) + 1)

    let testBinDir = mlroot.'/derived/glnxa64/testbin/'.projRelPathToMlRoot
    let testPath = testBinDir.'/*'.testName

    let testFiles = split(glob(testPath))
    if len(testFiles) > 1
        let choices = ['Multiple '.a:what.' tests found. Please select one: ']
        for idx in range(len(testFiles))
            call add(choices, idx.'. '.fnamemodify(testFiles[idx], ':t'))
        endfor
        let choice = inputlist(choices)
        if choice <= 0
            return
        endif
        let testPath = testFiles[choice]
    elseif len(testFiles) == 1
        let testPath = testFiles[0]
    else
        let testPath = ''
    end

    if !executable(testPath)
        echohl Error
        echomsg "Current file is not a unit/pkg test or the unit/pkg tests have not been built"
        echohl None
        return
    end

    call gdb#gdb#Init()

    " This ensures that the debugger breaks in our local sandbox files and
    " not in /devel/Aslrtw/build etc.
    call gdb#gdb#RunCommand('source '.sbrootDir.'/.sbtools/.source-path-gdbinit')
    
    call gdb#gdb#RunCommand("file ".testPath)

    " :cd to the project directory in GDB so that we can resolve relative
    " paths in the unit test executable.
    call gdb#gdb#RunCommand("cd ".projDir)

    " Read in all the breakpoints which have already been set.
    call gdb#gdb#RedoAllBreakpoints()
endfunction " }}}

command! MWDebug :call MW_StartMatlab(1, <f-args>)

amenu &Mathworks.&Debug.&1\ MATLAB\ -nojvm          :call MW_StartMatlab(1, '-nojvm')<CR>
amenu &Mathworks.&Debug.&2\ MATLAB\ -nodesktop      :call MW_StartMatlab(1, '-nodesktop -nosplash')<CR>
amenu &Mathworks.&Debug.&3\ MATLAB\ desktop         :call MW_StartMatlab(1, '-desktop')<CR>
amenu &Mathworks.&Debug.&Attach\ to\ MATLAB         :call MW_AttachToMatlab('MATLAB', '-nojvm')<CR>
amenu &Mathworks.&Debug.&4\ current\ unit/pkgtest   :call MW_DebugUnitTests('current')<CR>
amenu &Mathworks.&Debug.&5\ unittest                :call MW_DebugUnitTests('unit')<CR>
amenu &Mathworks.&Debug.&6\ pkgtest                 :call MW_DebugUnitTests('pkg')<CR>

amenu &Mathworks.&Run.&1\ MATLAB\ -nojvm        :call MW_StartMatlab(0, '-nojvm')<CR>
amenu &Mathworks.&Run.&2\ MATLAB\ -nodesktop    :call MW_StartMatlab(0, '-nodesktop -nosplash')<CR>
amenu &Mathworks.&Run.&3\ MATLAB\ desktop       :call MW_StartMatlab(0, '-desktop')<CR>
amenu &Mathworks.&Run.&4\ MATLAB\ -check_malloc :call MW_StartMatlab(0, '-check_malloc')<CR>

" vim: fdm=marker
