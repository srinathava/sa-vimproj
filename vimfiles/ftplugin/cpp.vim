let s:path = expand('<sfile>:p:h')

runtime compiler/cpp.vim
exec 'source '.s:path.'/c.vim'

" vim: fdm=marker
