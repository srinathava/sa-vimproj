if !has('python')
    finish
endif
" MW_StartMatlab:  {{{
" Description: 

let s:scriptDir = expand('<sfile>:p:h')
python import sys, vim
exec "python sys.path += [r'".s:scriptDir."']"
python from startMatlab import startMatlab

function! MW_StartMatlab(attach, mode)
    exec 'python pid = startMatlab("'.a:mode.'")'
    python vim.command('let pid = %d' % pid)

    if pid == 0
        echohl Search
        echomsg 'Cannot find MATLAB process for some reason...'
        echohl None
        return
    endif

    if a:attach == 0
        return
    endif

    call gdb#gdb#Init()

    if a:mode == '-nojvm'
        call gdb#gdb#RunCommand('handle SIGSEGV stop print')
    else
        call gdb#gdb#RunCommand('handle SIGSEGV nostop noprint')
    endif

    call gdb#gdb#Attach(pid)

    " set a bunch of standard breakpoints
    call gdb#gdb#SetQueryAnswer('y')
    call gdb#gdb#RunCommand('bex')
    call gdb#gdb#SetQueryAnswer('')

    call gdb#gdb#Continue()
endfunction " }}}


" MW_StartMatlab:  {{{
" Description: run the C++ unit tests for the current modules
function! MW_DebugUnitTests(whichTest)
    call gdb#gdb#Init()

    let projDir = mw#sbtools#GetCurrentProjDir()
    if projDir == ''
        echohl Error
        echomsg "Could not find a project directory for current file"
        echohl None
        return
    end

    " This is the directory where 'battree' is found
    let mlroot = mw#utils#GetRootDir().'/matlab'

    let relPath = strpart(projDir, len(mlroot))

    let testBinDir = mlroot.'/derived/glnxa64/testbin/'.relPath
    let testPath = testBinDir.'/'.a:whichTest
    call gdb#gdb#RunCommand("file ".testPath)
endfunction " }}}

command! MWDebug :call MW_StartMatlab(1, <f-args>)

amenu &Mathworks.&Debug.&1\ MATLAB\ -nojvm      :call MW_StartMatlab(1, '-nojvm')<CR>
amenu &Mathworks.&Debug.&2\ MATLAB\ -nodesktop  :call MW_StartMatlab(1, '-nodesktop')<CR>
amenu &Mathworks.&Debug.&3\ MATLAB\ desktop     :call MW_StartMatlab(1, '-desktop')<CR>
amenu &Mathworks.&Debug.4\ &unittest            :call MW_DebugUnitTests('unittest')<CR>
amenu &Mathworks.&Debug.5\ &pkgtest             :call MW_DebugUnitTests('pkgtest')<CR>

amenu &Mathworks.&Run.&1\ MATLAB\ -nojvm        :call MW_StartMatlab(0, '-nojvm')<CR>
amenu &Mathworks.&Run.&2\ MATLAB\ -nodesktop    :call MW_StartMatlab(0, '-nodesktop')<CR>
amenu &Mathworks.&Run.&3\ MATLAB\ desktop       :call MW_StartMatlab(0, '-desktop')<CR>
amenu &Mathworks.&Run.&4\ MATLAB\ -check_malloc :call MW_StartMatlab(0, '-check_malloc')<CR>

" vim: fdm=marker
