" .vimrc
"
" Andrew Maule's vimrc
" 
" 2009 May 20: for `Vim' 7.1
" 
" This vimrc is divided into these sections:
" 
" * Terminal Settings
" * Session Settings
" * User Interface
" * Substitutions
" * Text Formatting -- General
" * Text Formatting -- Specific File Formats
" * Search & Replace
" * Keystrokes -- Moving Around
" * Keystrokes -- Formatting
" * Keystrokes -- Toggles
" * Keystrokes -- Insert Mode
" * Keystrokes -- For HTML Files
" * `SLRN' Behaviour
" * Functions Referred to Above
" * Additions for OMNI CPP
" 
" This file contains no control codes and no `top bit set' characters above the
" normal Ascii range, and all lines contain a maximum of 79 characters.  With a
" bit of luck, this should make it resilient to being uploaded, downloaded,
" e-mailed, posted, encoded, decoded, transmitted by morse code, or whatever.

set nocompatible "Required?  from Vundle
filetype off "Required? from Vundle

" Vundle Setup
" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=~/.vim/bundle/

call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"added nerdtree
Plugin 'scrooloose/nerdtree'

"vim-fugitive -- An awesome git wrapper
Plugin 'tpope/vim-fugitive'

"tmuxify
Plugin 'jebaum/vim-tmuxify'

"tagbar
Plugin 'majutsushi/tagbar'

"YouCompleteMe -- autocompleter
Plugin 'Valloric/YouCompleteMe'

"For markup to display tables better
Plugin 'dhruvasagar/vim-table-mode'

"For better python indentation
Plugin 'nathanaelkane/vim-indent-guides'

"For display git addition/modification/deletions in the gutter for git repo. files
Plugin 'airblade/vim-gitgutter'

"For easy commenting/uncommenting
Plugin 'tomtom/tcomment_vim'

"Nicer display of vim statusline
Plugin 'itchyny/lightline.vim'

"Distraction-free editing for markup files
Plugin 'junegunn/goyo.vim'

"Badwolf colorscheme
Plugin 'sjl/badwolf'

"Color-pencils colorscheme (for markup editing)
Plugin 'reedes/vim-colors-pencil'

"Vim easy-motion
Plugin 'easymotion/vim-easymotion'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


" first clear any existing autocommands:
autocmd!

if has("gui_running")
   au GUIEnter * simalt ~x
   set guifont=Andale_Mono:h8:cANSI
endif

" * Terminal Settings

" `XTerm', `RXVT', `Gnome Terminal', and `Konsole' all claim to be "xterm";
" `KVT' claims to be "xterm-color":
if &term =~ 'xterm'

  " `Gnome Terminal' fortunately sets $COLORTERM; it needs <BkSpc> and <Del>
  " fixing, and it has a bug which causes spurious "c"s to appear, which can be
  " fixed by unsetting t_RV:
  if $COLORTERM == 'gnome-terminal'
    "execute 'set t_kb=' . nr2char(8)
    " [Char 8 is <Ctrl>+H.]
    fixdel
    set t_RV=

  " `XTerm', `Konsole', and `KVT' all also need <BkSpc> and <Del> fixing;
  " there's no easy way of distinguishing these terminals from other things
  " that claim to be "xterm", but `RXVT' sets $COLORTERM to "rxvt" and these
  " don't:
  elseif $COLORTERM == ''
    "execute 'set t_kb=' . nr2char(8)
    fixdel

  " The above won't work if an `XTerm' or `KVT' is started from within a `Gnome
  " Terminal' or an `RXVT': the $COLORTERM setting will propagate; it's always
  " OK with `Konsole' which explicitly sets $COLORTERM to "".

  endif
endif

" * Session Settings
set viminfo='1000,f1,/500,:500,@500,<1000 


" * User Interface

" have syntax highlighting in terminals which can display colours:
if has('syntax') && (&t_Co > 2)
  syntax on
endif

"autocmd VimEnter * NERDTree .

set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set hidden        " Hide buffers when they are abandoned
set number
set tabstop=3
set smarttab
set smartindent
set softtabstop=3
set shiftwidth=3

" have fifty lines of command-line (etc) history:
set history=1000

" have command-line completion <Tab> (for filenames, help topics, option names)
" first list the available options and complete the longest common part, then
" have further <Tab>s cycle through the possibilities:
set wildmode=list:longest,full

" use "[RO]" for "[readonly]" to save space in the message line:
set shortmess+=r

" display the current mode and partially-typed commands in the status line:
set showmode
set showcmd
set statusline=%<%F%h%m%r%h%w%y\ %{&ff}\ %{strftime(\"%d/%m/%Y-%H:%M\")}%=\ col:%c%V\ ascii:%b\ pos:%o\ lin:%l\,%L\ %P

" when using list, keep tabs at their full width and display `arrows':
execute 'set listchars+=tab:' . nr2char(187) . nr2char(183)
" (Character 187 is a right double-chevron, and 183 a mid-dot.)

" have the mouse enabled all the time:
set mouse=a

" don't have files trying to override this .vimrc:
set nomodeline

" * Substitutions
let mapleader = ";"

" Quick access to add all files in working directory to the Tag List.
" nnoremap <Leader>tR   :TlistAddFilesRecursive . <CR>
" nnoremap <Leader>tr   :TlistAddFilesRecursive . mcts*\\|*.sh\\|*.exp\\|*.py\\|*.configure\\|*.set\\|*.functions\\|*.c\\|*.h\\|Makefile\\|*.template<CR>
" nnoremap <Leader>tU   :TlistUpdate <CR>
" nnoremap <Leader>tl   :TlistLock <CR>
" nnoremap <Leader>tu   :TlistUnlock <CR>

" Quit all windows.
nnoremap <Leader>QQ   :qa!<CR>
nnoremap <Leader>qs   :wall<CR>:qa<CR>

" * Text Formatting -- General

" don't make it look like there are line breaks where there aren't:
set nowrap

" use indents of 3 spaces, and have them copied down lines:
set ts=4
set shiftwidth=4
set shiftround
set expandtab
set autoindent

" normally don't automatically format `text' as it is typed, IE only do this
" with comments, at 79 characters:
set formatoptions=""
set textwidth=120

" get rid of the default style of C comments, and define a style with two stars
" at the start of `middle' rows which (looks nicer and) avoids asterisks used
" for bullet lists being treated like C comments; then define a bullet list
" style for single stars (like already is for hyphens):
set comments-=s1:/*,mb:*,ex:*/
set comments+=s:/*,mb:**,ex:*/
set comments+=fb:*

" treat lines starting with a quote mark as comments (for `Vim' files, such as
" this very one!), and colons as well so that reformatting usenet messages from
" `Tin' users works OK:
set comments+=b:\"
set comments+=n::

" Repair carriage returns
command RepairCR %s/\r//ge

" Folding
set foldmethod=indent 
set foldlevel=10

" * Text Formatting -- Specific File Formats

" enable filetype detection:
"filetype on

" recognize anything in my .Postponed directory as a news article, and anything
" at all with a .txt extension as being human-language text [this clobbers the
" `help' filetype, but that doesn't seem to prevent help from working
" properly]:
augroup filetype
  autocmd BufNewFile,BufRead */.Postponed/* set filetype=mail
  autocmd BufNewFile,BufRead *.txt set filetype=human
augroup END

augroup SVNCommand
   au SVNCommand User SVNBufferCreated RepairCR
augroup END

" in human-language files, automatically format everything at 120 chars:
autocmd FileType mail,human set swf formatoptions+=t textwidth=120

" for C-like programming, have automatic indentation:
autocmd FileType c,cpp,slang set cindent
autocmd FileType c,cpp,slang set number
autocmd FileType c,cpp,slang syn match Keyword "VOID"
autocmd FileType c,cpp,slang syn match Keyword "BOOL"

" for actual C (not C++) programming where comments have explicit end
" characters, if starting a new line in the middle of a comment automatically
" insert the comment leader characters:
autocmd FileType c set swf foldmethod=syntax foldlevel=10 smartindent formatoptions="" formatoptions-=tc et ts=4 shiftwidth=4

" for Python programming:
autocmd FileType python set swf foldmethod=manual smartindent formatoptions+=nro formatoptions="" et ts=4 shiftwidth=4

" for Perl programming, have things in braces indenting themselves:
autocmd FileType perl set swf foldmethod=syntax smartindent

" html and css
autocmd FileType html,css set swf foldmethod=manual formatoptions="" et ts=4 sw=4

" in makefiles, don't expand tabs to spaces, since actual tab characters are
" needed, and have indentation at 8 chars to be sure that all indents are tabs
" (despite the mappings later):
autocmd FileType make set swf noexpandtab shiftwidth=8


" * Search & Replace

" make searches case-insensitive, unless they contain upper-case letters:
set ignorecase
set smartcase

if has("win32")
   let Tlist_Ctags_Cmd="C:\\cygwin\\bin\\ctags.exe"
   set shell=C:\windows\system32\cmd.exe
   set grepprg=C:\\cygwin\\bin\\grep.exe\ -Hirn
   set csprg=C:\\cygwin\\usr\\local\\bin\\cscope.exe
   let g:QFFindPath = "C:\\cygwin\\bin\\find.exe"
else
   set shell=/bin/bash
   set grepprg=/usr/bin/grep\ -Hirn
   set csprg=cscope
   let g:QFFindPath  =  "/usr/bin/find"
endif

nnoremap <Leader>gr :grep -Hirn <cword> *

" show the `best match so far' as search strings are typed:
set incsearch

" assume the /g flag on :s substitutions to replace all matches in a line:
"set gdefault

" * Keystrokes -- Moving Around

" have the h and l cursor keys wrap between lines (like <Space> and <BkSpc> do
" by default), and ~ covert case over line breaks; also have the cursor keys
" wrap in insert mode:
set whichwrap=h,l,~,[,]

" page down with <Space> (like in `Lynx', `Mutt', `Pine', `Netscape Navigator',
" `SLRN', `Less', and `More'); page up with - (like in `Lynx', `Mutt', `Pine'),
" or <BkSpc> (like in `Netscape Navigator'):
noremap <Space> <PageDown>
"noremap <BS> <PageUp>
noremap - <PageUp>
" [<Space> by default is like l, <BkSpc> like h, and - like k.]

" scroll the window (but leaving the cursor in the same place) by a couple of
" lines up/down with <Ins>/<Del> (like in `Lynx'):
noremap <Ins> 2<C-Y>
noremap <Del> 2<C-E> " [<Ins> by default is like i, and <Del> like x.]

"Cycle through the windows
nnoremap <Leader>k	<C-W>k
nnoremap <Leader>j	<C-W>j
nnoremap <Leader>l	<C-W>l
nnoremap <Leader>h	<C-W>h
nnoremap <Leader>wt	<C-W>t
nnoremap <Leader>wb	<C-W>b
nnoremap <Leader>wr	<C-W>r
nnoremap <Leader>wh	<C-W>10+
nnoremap <Leader>wv	<C-W>10>

"Keymappings to quickly cycle back and forth through cursor location
"Backwards
nnoremap <Leader>o    <C-o>
"Forwards
nnoremap <Leader>i    <C-i>

"Quickly turn on and off line numbers
nnoremap <Leader>nn <ESC>:set nonumber<CR>
nnoremap <Leader>n <ESC>:set number<CR>

" have % bounce between angled brackets, as well as t'other kinds:
set matchpairs+=<:>

" have <F1> prompt for a help topic, rather than displaying the introduction
" page, and have it do this from any mode:
nnoremap <F1> :help<Space>
vmap <F1> <C-C><F1>
omap <F1> <C-C><F1>
map! <F1> <C-C><F1>


" * Keystrokes -- Formatting

" have Q reformat the current paragraph (or selected text if there is any):
nnoremap Q gqap
vnoremap Q gq

" have the usual indentation keystrokes still work in visual mode:
vnoremap <C-T> >
vnoremap <C-D> <LT>
vmap <Tab> <C-T>
vmap <S-Tab> <C-D>

" have Y behave analogously to D and C rather than to dd and cc (which is
" already done by yy):
noremap Y y$


" * Keystrokes -- Toggles

"Taglist side window view
" nnoremap <Leader>t :TlistToggle<CR>

"NERDTree Toggles and Manuvorings
nnoremap <Leader>N       :NERDTreeToggle<CR>
nnoremap <Leader>nr      :NERDTree /<CR>
nnoremap <Leader>nh      :exe ':NERDTree '.$HOME <CR>

"Sessionman script mappings
" nnoremap <Leader>S       :SessionList<CR>
"Save session
" nnoremap <Leader>ss      :SessionSave<CR>
"Save session
" nnoremap <Leader>ss      :SessionSave<CR>
"Open last session
" nnoremap <Leader>sl      :SessionOpenLast<CR>
"Open last session
" nnoremap <Leader>sc      :SessionClose<CR>

func! FoldIncrement()
   let foldlevel_tmp=&foldlevel+1
   exe 'set foldlevel='.foldlevel_tmp
endf

func! FoldDecrement()
   let foldlevel_tmp=&foldlevel-1
   exe 'set foldlevel='.foldlevel_tmp
endf

nnoremap <silent> ;;i      :silent call FoldIncrement()<CR>
nnoremap <silent> ;;j      :silent call FoldDecrement()<CR>

" * Keystrokes -- Insert Mode

" allow <BkSpc> to delete line breaks, beyond the start of the current
" insertion, and over indentations:
set backspace=eol,start,indent

" have <Tab> (and <Shift>+<Tab> where it works) change the level of
" indentation:
"inoremap <Tab> <C-T>
"inoremap <S-Tab> <C-D>
" [<Ctrl>+V <Tab> still inserts an actual tab character.]

" abbreviations:
" iabbrev hse he/she

"Fun attempt to adjust font size
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

"let R_path = "/usr/local/bin/R"

"Setup settings for vim-tmuxify plugin
let g:tmuxify_custom_command = 'tmux split-window -d -p 20'
let g:tmuxify_run = {
    \'sh': 'bash %',
    \'go': 'go build %',
    \'py': '/opt/local/bin/python %',
    \'r': '/usr/local/bin/R'
\} 

"tagbar mappings and configuration
let g:tagbar_left=1
nnoremap <Leader>tb   :TagbarToggle<CR>

"Goyo mappings and configuration
"
nnoremap <Leader>go   :Goyo<CR>

function! s:goyo_enter()
    colorscheme pencil
endfunction

function! s:goyo_leave()
    colorscheme evening
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

"
"vim-indent-guide configuration
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
let g:indent_guides_enable_on_vim_startup = 1

"
"vim-table-mode configuration (for Markdown table editing)
let g:table_mode_corner="|"

colorscheme evening
