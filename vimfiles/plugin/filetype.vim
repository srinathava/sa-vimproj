" Include this in your filetype.vim
augroup filetype
        au BufNewFile,BufRead *.tlc                     setf tlc
        au BufNewFile,BufRead *.rtw                     setf rtw
        au BufNewFile,BufRead *.cdr                     setf matlab
augroup END
