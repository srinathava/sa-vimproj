" ==============================================================================
" A common place for all the utility scripts. The actual body lies in the
" autoload/ directory.
" ============================================================================== 

command! -nargs=1 -complete=dir DWithOther          :call mw#sbtools#DiffWithOther(<f-args>)
command! -nargs=1 -complete=dir SWithOther          :call mw#sbtools#SplitWithOther(<f-args>)
command! -nargs=1 -complete=dir DiffSandbox1        :call mw#sbtools#DiffWriteable1(<f-args>)
command! -nargs=+ -complete=dir DiffSandbox2        :call mw#sbtools#DiffWriteable2(<f-args>)
command! -nargs=* -complete=file DiffSubmitFile     :call mw#sbtools#DiffSubmitFile(<f-args>)
command! -nargs=0 -range AddHeaderProtection        :call mw#addHeaderProtection#DoIt()

"command! -nargs=0 InitCppCompletion                 :call cpp_omni#Init()

com! -nargs=1 -bang -complete=customlist,mw#sbtools#EditFileCompleteFunc
       \ EditFile call mw#sbtools#EditFileUsingLocate(<q-args>)

com! -nargs=0 FastFile call mw#open#OpenFile()

" At Mathworks, its usual practice to track modifications by figuring out
" which files are write-able. Therefore, vim's behavior of retaining the
" readonly-ness of files even after writing content to it hides changes we
" might have made.
augroup ChangeFilePermsBeforeWriting
    au!
    au BufWritePre * 
        \ : if filereadable(expand('<afile>')) && !filewritable(expand('<afile>')) && has('python')
        \ |     exec 'py import os, stat, vim'
        \ |     exec 'py os.chmod(vim.current.buffer.name, 0755)'
        \ | endif
augroup END

augroup AddFilesToPerforce
    au!
    au BufWritePost * call mw#perforce#AddFileToPerforce(expand('<afile>:p'))
augroup END

" Update tags in background after every write for the current project.
augroup MWRefreshProjectTags
    au!
    au BufWritePost * 
        \ : if has('unix') == 1 
        \ |     exec 'silent! !genVimTags.py '.expand('%:p:h').' &> /dev/null &'
        \ |     TlistUpdate
        \ | endif
augroup END

" Include this in your filetype.vim
augroup filetype
        au BufNewFile,BufRead *.tlc                     setf tlc
        au BufNewFile,BufRead *.rtw                     setf rtw
        au BufNewFile,BufRead *.cdr                     setf matlab
augroup END

if !hasmapto('mw#open#OpenFile')
    map <F4> :call mw#open#OpenFile()<CR>
endif

if !has('gui_running')
    finish
endif

amenu &Mathworks.D&iff.With\ &perfect                               :DWithOther archive<CR>
amenu &Mathworks.D&iff.With\ &sandbox                               :DWithOther<space> 
amenu &Mathworks.D&iff.Using\ submit\ &file                         :DiffSubmitFile archive<CR>
amenu &Mathworks.&Add\ current\ file\ to\ submit\ list              :!add.py %:p<CR>

amenu &Mathworks.-sep1- <Nop>
amenu &Mathworks.Add\ &header\ protection       :AddHeaderProtection<CR>

amenu &Mathworks.-sep2- <Nop>
amenu &Mathworks.&Tags.&Initialize\ tags                    :call mw#tag#InitVimTags()<CR>
amenu &Mathworks.&Tags.Search\ through\ &Project\ tags      :call mw#tag#SelectTag(expand('%:p'))<CR>
" amenu &Mathworks.&Tags.Search\ through\ &File\ tags         :call mw#tag#SelectTag(expand('%:p'))<CR>

nmenu &Mathworks.&Find.In\ &Project                 :call mw#sbtools#FindInProj()<CR><C-R>=expand('<cword>')<CR>
nmenu &Mathworks.&Find.In\ &Solution                :call mw#sbtools#FindInSolution()<CR><C-R>=expand('<cword>')<CR>
nmenu &Mathworks.&Find.Using\ sb&id                 :call mw#sbtools#FindUsingSbid()<CR><C-R>=expand('<cword>')<CR>
nmenu &Mathworks.&Find.Using\ sb&global             :call mw#sbtools#FindUsingSbglobal()<CR><C-R>=expand('<cword>')<CR>
nmenu &Mathworks.&Find.Using\ &code\ search\ tool   :call mw#sbtools#FindUsingSourceCodeSearch()<CR><C-R>=expand('<cword>')<CR>
nmenu &Mathworks.O&Pen\ file\ in\ project           :call mw#open#OpenFile()<CR>

amenu &Mathworks.-sep3- <Nop>
amenu &Mathworks.&Compile\ Current\ Project     :call mw#sbtools#CompileProject()<CR>
amenu &Mathworks.C&ompile\ Current\ File        :call mw#sbtools#CompileFile()<CR>
amenu &Mathworks.&Set\ Compile\ Level           :call mw#sbtools#SetCompileLevel()<CR>
amenu &Mathworks.DAS\ B&uild                    :call mw#sbtools#BuildUsingDas()<CR>

amenu &Mathworks.-sep4- <Nop>
amenu &Mathworks.Sa&ve\ Current\ Session        :call mw#sbtools#SaveSession()<CR>
amenu &Mathworks.&Load\ Saved\ Session          :call mw#sbtools#LoadSession()<CR>

" vim: fdm=marker
