" SetMatlabCommandFcn: {{{
let s:MatlabCommand = ''
function! SetMatlabCommandFcn(name)
    let s:MatlabCommand = a:name
    amenu &Mathworks.Start\ MATLAB :call StartMatlab()<CR>
endfunction " }}}
" GetMatlabCommandFcn: {{{
function! GetMatlabCommandFcn()
    return s:MatlabCommand
endfunction " }}}
" StartMatlab: starts MATLAB if possible {{{
" Description: only works if this vim session was started using the
" command-line:
"       vim -g -c "SetMatlabCommand $*" &
"
function! StartMatlab()
    call gdb#gdb#Init()
    call gdb#gdb#RunCommand('handle SIGSEGV nostop noprint')
    call gdb#gdb#RunCommand('file '.GetMatlabCommandFcn())
    call gdb#gdb#Run()
endfunction " }}}

python <<FOOBAR
import os, commands, re, vim, time
def startMatlab(useXterm, *extraArgs):
    if useXterm:
        pid = os.spawnlp(os.P_NOWAIT, 'xterm', 'xterm', '-e', 'matlab', *extraArgs)
        # wait for the correct MATLAB process to be loaded.
        while 1:
            pst = commands.getoutput('pstree -p %d' % pid)
            m = re.search(r'MATLAB\((\d+)\)', pst)
            if m:
                pid = m.group(1)
                break
            time.sleep(0.5)
    else:
        pid = os.spawnlp(os.P_NOWAIT, 'matlab', *extraArgs)

    vim.command('let pid = %s' % pid)
FOOBAR

" StartMatlabNoJvm:  {{{
" Description: 
function! StartMatlabNoJvm()
    python startMatlab(1, '-nojvm', '-nosplash')

    call gdb#gdb#Init()
    call gdb#gdb#RunCommand('handle SIGSEGV stop print')
    call gdb#gdb#Attach(pid)
    call gdb#gdb#RedoAllBreakpoints()
    call gdb#gdb#Continue()
endfunction " }}}
" StartMatlabNoDesktop:  {{{
" Description: 
function! StartMatlabNoDesktop()
    python startMatlab(1, '-nodesktop', '-nosplash')

    call gdb#gdb#Init()
    call gdb#gdb#RunCommand('handle SIGSEGV nostop noprint')
    call gdb#gdb#Attach(pid)
    call gdb#gdb#RedoAllBreakpoints()
    call gdb#gdb#Continue()
endfunction " }}}
" StartMatlabDesktop:  {{{
" Description: 
function! StartMatlabDesktop()
    python startMatlab(0)

    call gdb#gdb#Init()
    call gdb#gdb#RunCommand('handle SIGSEGV nostop noprint')
    call gdb#gdb#Attach(pid)
    call gdb#gdb#RedoAllBreakpoints()
    call gdb#gdb#Continue()
endfunction " }}}
amenu &Mathworks.Debug\ MATLAB\ -nojvm      :call StartMatlabNoJvm()<CR>
amenu &Mathworks.Debug\ MATLAB\ -nodesktop  :call StartMatlabNoDesktop()<CR>
amenu &Mathworks.Debug\ MATLAB\ desktop     :call StartMatlabDesktop()<CR>

com! -nargs=1 SetMatlabCommand call SetMatlabCommandFcn(<q-args>)

" vim: fdm=marker
