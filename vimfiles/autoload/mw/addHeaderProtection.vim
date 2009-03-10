" DoIt: adds header re-inclusion directives to the current file {{{
function! mw#addHeaderProtection#DoIt()
    let fname = expand('%:t:r')
    let dir = expand('%:p:h:t')

    let comment = '_'.dir.'_'.fname.'_h_'
    call append(0, ["#ifndef ".comment, "#define ".comment, ""])
    call append(line('$'), ["", "#endif // ".comment, ""])
endfunction " }}}
