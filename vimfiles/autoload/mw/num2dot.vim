function! mw#num2dot#DoIt() range
    exe a:firstline.','.a:lastline.' s/\(\d\+\)\s\+\(\d\+\)/node_\1 -> node_\2/'
    call append(a:lastline, '}')
    call append(a:firstline-1, 'digraph S{')
endfunction
