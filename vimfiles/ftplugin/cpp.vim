if !exists('b:doneAddingSandboxTags')
    let b:doneAddingSandboxTags = 1
    call mw#tag#AddSandboxTags(expand('%:p'))
endif

" nnoremap <buffer> <C-]> :call mw#tag#goto('<C-R><C-W>')<CR>
" nnoremap <buffer> <C-T> :call mw#tag#back()<CR>

" vim: fdm=marker
