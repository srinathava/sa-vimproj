" ==============================================================================
" Perforce commands
" ============================================================================== 

let s:scriptPath = expand('<sfile>:p:h')

" mw#perforce#IsInPerforceSandbox: Is this file in a perforce sandbox {{{
function! mw#perforce#IsInPerforceSandbox(fileName)
    let bufferDir = fnamemodify(a:fileName, ':p:h')
    let battreePath = findfile('.perforce', bufferDir . ';')
    return battreePath != ""
endfunction
" }}}
" mw#perforce#AddFileToPerforce: adds a file to perforce {{{
" Description: 
function! mw#perforce#AddFileToPerforce(fileName)
    if exists('b:alreadyAddedToPerforce')
        return
    endif

    let b:alreadyAddedToPerforce = 1

    if !mw#perforce#IsInPerforceSandbox(a:fileName)
        return
    endif

    let cmd = s:scriptPath.'/addToPerforce.py '.a:fileName.' &'
    call system(cmd)
endfunction " }}}
