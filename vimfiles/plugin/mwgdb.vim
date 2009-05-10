" Helper Python functions {{{
python <<FOOBAR
import os, commands, re, vim, time
def warnVim(msg):
    vim.command("echohl Search")
    vim.command("echomsg '%s'" % msg)
    vim.command("echohl None")

def startMatlabLocal(useXterm, *extraArgs):
    rootDir = vim.eval('mw#utils#GetRootDir()')
    if not rootDir:
        warnVim('Not in a sandbox. Cannot start MATLAB')
        return 0

    if useXterm:
        pid = os.spawnlp(os.P_NOWAIT, 'xterm', 'xterm', '-e', 'sb', *extraArgs)
    else:
        pid = os.spawnlp(os.P_NOWAIT, 'sb', 'sb', *extraArgs)

    # wait for the correct MATLAB process to be loaded.
    n = 0
    while 1:
        pst = commands.getoutput('pstree -p %d' % pid)
        m = re.search(r'MATLAB\((\d+)\)', pst)
        if m:
            return int(m.group(1))

        time.sleep(0.5)
        n += 1
        if n == 10:
            warnVim('Cannot attach to MATLAB')
            return 0

def startMatlab(useXterm, *extraArgs):
    pid = startMatlabLocal(useXterm, *extraArgs)
    vim.command('let pid = %d' % pid)
FOOBAR
" }}}

" StartMatlabNoJvm:  {{{
" Description: 
function! StartMatlabNoJvm()
    python startMatlab(1, '-nojvm', '-nosplash')
    if pid == 0
        return
    end
    echomsg "Getting PID = ".pid

    call gdb#gdb#Init()
    call gdb#gdb#RunCommand('handle SIGSEGV stop print')
    call gdb#gdb#Attach(pid)
    call gdb#gdb#Continue()
endfunction " }}}
" StartMatlabNoDesktop:  {{{
" Description: 
function! StartMatlabNoDesktop()
    python startMatlab(1, '-nodesktop', '-nosplash')
    if pid == 0
        return
    end

    call gdb#gdb#Init()
    call gdb#gdb#RunCommand('handle SIGSEGV nostop noprint')
    call gdb#gdb#Attach(pid)
    call gdb#gdb#Continue()
endfunction " }}}
" StartMatlabDesktop:  {{{
" Description: 
function! StartMatlabDesktop()
    python startMatlab(0)
    if pid == 0
        return
    end

    call gdb#gdb#Init()
    call gdb#gdb#RunCommand('handle SIGSEGV nostop noprint')
    call gdb#gdb#Attach(pid)
    call gdb#gdb#Continue()
endfunction " }}}
amenu &Mathworks.&Debug.&1\ MATLAB\ -nojvm      :call StartMatlabNoJvm()<CR>
amenu &Mathworks.&Debug.&2\ MATLAB\ -nodesktop  :call StartMatlabNoDesktop()<CR>
amenu &Mathworks.&Debug.&3\ MATLAB\ desktop     :call StartMatlabDesktop()<CR>

amenu &Mathworks.&Run.&1\ MATLAB\ -nojvm      :python startMatlab(1, '-nojvm', '-nosplash')<CR>
amenu &Mathworks.&Run.&2\ MATLAB\ -nodesktop  :python startMatlab(1, '-nodesktop', '-nosplash')<CR>
amenu &Mathworks.&Run.&3\ MATLAB\ desktop     :python startMatlab(0)<CR>

com! -nargs=1 SetMatlabCommand call SetMatlabCommandFcn(<q-args>)

" vim: fdm=marker
