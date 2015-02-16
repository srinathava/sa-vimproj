" mw#debug#Debug: add a message to the debug log {{{
" Description: 
function! mw#debug#Debug(logName, msg)
    if !exists('s:Debug_'.a:logName)
        let s:Debug_{a:logName} = ''
    endif

    let s:Debug_{a:logName} = s:Debug_{a:logName} . "\n" . a:msg
endfunction " }}}

" mw#debug#Print: prints the message {{{
" Description: 
function! mw#debug#Print(logName)
    echo s:Debug_{a:logName}
endfunction " }}}
