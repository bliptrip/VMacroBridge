set nocompatible
source $VIMRUNTIME/vimrc_example.vim
if has("win32")
   source $VIMRUNTIME/mswin.vim
endif

set nobackup " Do not keep a backup, as it gets annoying at times

au BufNewFile,BufRead *.c     setl comments=sl:/*,mb:**,elx:*/,://
au BufNewFile,BufRead *.h     setl comments=sl:/*,mb:**,elx:*/,://
au BufNewFile,BufRead *.hp    call RcConfigureHP()

set cindent

set softtabstop=0

set et
set ts=3
set sw=3

set ar 
if has("win32")
   behave mswin
endif

set number
set nowrap

"setup non-standard keywords
syn match Keyword "VOID"
syn match Keyword "BOOL"


if has("gui_running")
   au GUIEnter * simalt ~x
   set guifont=Andale_Mono:h8:cANSI
endif   

if has("win32")
   let Tlist_Ctags_Cmd="C:\\cygwin\\bin\\ctags.exe"
else
   let Tlist_Ctags_Cmd="~/bin/ctags/ctags"
endif

nnoremap \f <Esc>:call QFExploreToggle()<cr>
nnoremap \w <Esc>:WMToggle<cr>
nnoremap \e <Esc>:call ToggleShowExplorer()<cr>
nnoremap \t <Esc>:Tlist<cr>
nnoremap ;h <Esc><c-w>h
nnoremap ;l <Esc><c-w>l
nnoremap ;k <Esc><c-w>k
nnoremap ;j <Esc><c-w>j
nnoremap \/ <Esc>:exe ":h " expand("<cword>")<CR>
nnoremap ;v <Esc><c-w>15>
nnoremap ;a <Esc><c-w>5+
nnoremap ;gr <Esc>:exe ":grep ".expand("<cword>")." *"<CR>

if has("win32")
   set shell=C:\windows\system32\cmd.exe
   set grepprg=C:\\cygwin\\bin\\grep.exe\ -Hirn
   set csprg=C:\\cygwin\\usr\\local\\bin\\cscope.exe
   let g:QFFindPath = "C:\\cygwin\\bin\\find.exe"
else
   set shell=/bin/bash
   set grepprg=/bin/grep\ -Hirn
   set csprg=cscope
   let g:QFFindPath  =  "/usr/bin/find"
endif

"Winmanager Settings
let g:winManagerWindowLayout='Opsplorer,OpsplorerCB'

fu! RcConfigureHP()
   setl ft=c
   setl comments=sl:/*,mb:**,elx:*/,://
endf

if has("win32") && has("gui_running")
function! AdjustFontSize(amount)
   let pattern = '^\([^0-9]*\)\([1-9][0-9]*\)$'
   let minfontsize = 6
   let maxfontsize = 16
     let tokens = split(&guifont, ':') 
     let prefixsize=substitute(tokens[1], pattern, '\1', '')
     let cursize=substitute(tokens[1], pattern, '\2', '')
     let newsize = cursize + a:amount
     if (newsize >= minfontsize) && (newsize <= maxfontsize)
       let newfont = join([prefixsize,newsize],'')
       let &guifont = join([tokens[0],newfont], ':')
     endif
endfunction

function! LargerFont()
  call AdjustFontSize(1)
endfunction
command! LargerFont call LargerFont()

function! SmallerFont()
  call AdjustFontSize(-1)
endfunction
command! SmallerFont call SmallerFont()

autocmd BufEnter * call AdjustFontSize(2)
autocmd BufLeave * call AdjustFontSize(-2)
endif
