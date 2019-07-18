" Partial Diff Script - Allows one to diff the contents of two registers in
" order to allow a programmer to do partial diffs of code blocks.  Comes in
" handy when one does not want to do a full file difference, but instead just
" a partial difference.
"
"
" Author:  Andrew Maule
" Date:    2009/05/21
" Email:   andrew dot maule at bliptrip dot net
"
" Version: 1.0 - Original Version
"     2003/05/21
"
"

let s:DiffBuf1               = "__diff_1__"
let s:DiffBuf2               = "__diff_2__"

" setup command
com! -nargs=* Diffp cal s:DiffP(<f-args>)
com! DiffpClose cal s:DiffPClose()

"Default to simply diffing the contents of register a and register b
nnoremap <silent> ;dp     :silent Diffp a b<CR>
nnoremap <silent> ;dx     :silent DiffpClose<CR>

"Allows us to syntax-highlight the relative directory-paths
fu! <SID>DiffPClose()
   if bufnr(s:DiffBuf1) != -1
      exec 'bw '.s:DiffBuf1
   endif
   if bufnr(s:DiffBuf2) != -1
      exec 'bw '.s:DiffBuf2
   endif
endf

"Allows us to syntax-highlight the relative directory-paths
fu! <SID>DiffP(reg1, reg2)
   "First close any previously opened diff buffers
   call s:DiffPClose() 
   let s:filetype = &ft
   exec 'silent! botright 20split '.s:DiffBuf1
   setl buftype=nofile
   setl noswapfile
   setl filetype=s:filetype
   setl bufhidden=delete
   exec '0put =@'.split(a:reg1)[0]
   diffthis
   exec 'silent! rightb vsplit '.s:DiffBuf2 
   setl buftype=nofile
   setl noswapfile
   setl filetype=s:filetype
   setl bufhidden=delete
   exec '0put =@'.split(a:reg2)[0]
   diffthis
endf
