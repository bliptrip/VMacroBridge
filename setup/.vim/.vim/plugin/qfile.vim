" Quick-File - Find a file in a project quickly
"
" Author:  Andrew Maule
" Date:    2003/09/25
" Email:   andrew dot maule at bliptrip dot net
"
" Version: 1.1 - Changed to not use absolute path references.  This
"                 makes is easier when copying over session files.
"     2009/01/19
"
" Version: 1.0 - Original Version
"     2003/09/25
"

if !exists("g:QFFindPath")
   let g:QFFindPath              = "find"
endif

let s:QFBufferDisplayed       = 0
let s:LastAccessedBuffer      = -1
let s:FirstLoad               = 1
let s:QFBufName               = "__QuickFile__"
let s:DefaultSessionFile      = "qfile.sess"
let g:QfileLastIC=&ic

" setup command
com! QFExplore cal QFExploreToggle()

fu! <SID>LoadIC()
   let g:QfileLastIC=&ic
   setl ic
endf

fu! <SID>RestoreIC()
   if g:QfileLastIC
      set ic
   else
      set noic
   endif
endf

fu! <SID>InitOptions()
	let s:single_click_to_edit=0
	let s:show_hidden_files=0
	let s:split_vertical=1
	let s:split_width=16
	let s:split_minwidth=1
	let s:use_colors=1
	let s:close_explorer_after_open=0

   let b:MatchPattern            = '.+\.c,.+\.hp,.+\.h,.+\.d,.+\.mak,.+\.cfg,.*makefile,.+\.cpp,.+\.map,.+\.bin,.+\.int,.+\.gpj,.+\.in,.+\.sh,.+\.txt,.+\.nt'
   let b:FileRootPath            = getcwd()
   let b:MaxFileNameLength       = 0
   let b:FilePathOffset          = 5
endf

fu! <SID>InitCommonOptions()
   setl noma
	setl nowrap
	setl nonu
   "Ignore case when doing searches
   setl buftype=nowrite
   setl bufhidden=hide
   setl nobuflisted
endf

fu! <SID>InitMappings()
	noremap <silent> <buffer> <LeftRelease>   :cal QFOpenFile(getline('.'))<CR>
	noremap <silent> <buffer> <2-LeftMouse>   :cal QFOpenFile(getline('.'))<CR>
	noremap <silent> <buffer> <Space>         :cal QFOpenFile(getline('.'))<CR>
	noremap <silent> <buffer> <CR>            :cal QFOpenFile(getline('.'))<CR>
   noremap <silent> <buffer> u               :cal QFUpdateFilesNoPrompt()<CR>
   noremap <silent> <buffer> U               :cal QFUpdateFilesPrompt()<CR>
   noremap <silent> <buffer> s               :cal QFSaveSession()<CR>
   noremap <silent> <buffer> S               :cal QFSaveSession()<CR>
   noremap <silent> <buffer> r               :cal QFRestoreSession()<CR>
   noremap <silent> <buffer> R               :cal QFRestoreSession()<CR>
   noremap <silent> <buffer> <Leader>s       :cal QFSortFiles()<CR>
   noremap <silent> <buffer> <Leader>S       :cal QFSortFilePaths()<CR>
   noremap <silent> <buffer> p               :cal QFUpdateRootPath()<CR>
   noremap <silent> <buffer> P               :cal QFUpdateRootPath()<CR>
   noremap <silent> <buffer> ?               :cal QFShowHelp()<CR>
   noremap <silent> <buffer> h               :cal QFShowHelp()<CR>
   noremap <silent> <buffer> H               :cal QFShowHelp()<CR>
endf

"Allows us to syntax-highlight the relative directory-paths
fu! <SID>InitColors()
   syn clear
   let b:FilePatternMatchPre    = '"^.\{'.(b:MaxFileNameLength+b:FilePathOffset).'}"'
   let b:FilePatternMatchPost   = '"^.\{'.(b:MaxFileNameLength+b:FilePathOffset).'}.\+"'
   "Much thanks to Tyson for helping me out with this
   exe 'syn match QFPathPre '.b:FilePatternMatchPre
   exe 'syn match QFPath   '.b:FilePatternMatchPost.' contains=QFPathPre'
   hi link QFPath Comment
endf

fu! <SID>InitAll()
   cal s:InitCommonOptions()
   cal s:InitOptions()	
   cal s:InitMappings()
endf

fu! <SID>ViewPath(sCurrentFile)
   let sCurrentFileIdIdx   = strridx(a:sCurrentFile, " ") + 1;

   "Until I know a better way to do this, rewind to the last occurence of a
   "space
   let sCurrentFileNameEnd = sCurrentFileIdIdx - 1
   while( a:sCurrentFile[sCurrentFileIdIdx] == ' ' )
      let sCurrentFileNameEnd = sCurrentFileNameEnd - 1
   endw

   if( -1 != sCurrentFileIdIdx )
      let sCurrentFileId      = strpart(getline('.'),sCurrentFileIdIdx,col('$') - col('.'))
      :exe 'let sCurrentFilePath  = Path_Of_'.sCurrentFileId.'_'.sCurrentFile
      winc l
      echo sCurrentFilePath.'/'.strpart(a:sCurrentFile,0,sCurrentFileNameEnd)
      :exe ':new '.sCurrentFilePath.'/'.strpart(a:sCurrentFile,0,sCurrentFileNameEnd)
   endif
endf

fu! QFOpenFile(Line)
   let LineLength    = strlen(a:Line)
   let FilePathIdx   = b:MaxFileNameLength + b:FilePathOffset
   let FilePath      = strpart(a:Line,FilePathIdx,(LineLength - FilePathIdx) + 1)
   let FileName      = strpart(a:Line,0,FilePathIdx)

   let FQFileName    = b:FileRootPath.'/'.FilePath.'/'.FileName
   echo "FQFileName: '".FQFileName."'"

   let LastWinNr     = winbufnr('$')
   exe   'silent! hide'
   if( -1 != LastWinNr )
      winc  p
   endif

   if( 0 != &mod )
      exe   'new '.FQFileName
   else
      exe   'e '.FQFileName
   endif

   "Don't forget to mark the quick-file buffer as not displayed
   let s:QFBufferDisplayed = 0
endf

fu! QFUpdateFilesNoPrompt()
   cal s:UpdateFiles(b:FileRootPath,b:MatchPattern)

   cal QFSaveSession()
endf

fu! QFUpdateFilesPrompt()
   let SearchPath       = input("Enter the search path: ", b:FileRootPath)
   let SearchPattern    = input("Enter the search patterns, separated by commas: ",b:MatchPattern)

   let b:FileRootPath   = SearchPath
   let b:MatchPattern   = SearchPattern

   call s:UpdateFiles(b:FileRootPath,b:MatchPattern)

   cal QFSaveSession()
endf

fu! <SID>UpdateFiles(SearchPath, FileMatchPattern)
   let FileMatchPattern = a:FileMatchPattern

   let GlobFilePatterns = ''
   let GlobStrLastIndex    = 0
   let GlobStrIndex  = match(FileMatchPattern,',',0)
   while( -1 != GlobStrIndex )
      let GlobFilePatterns = GlobFilePatterns.'\('.strpart(FileMatchPattern,GlobStrLastIndex,GlobStrIndex-GlobStrLastIndex).'\)\|'
      let GlobStrLastIndex = GlobStrIndex + 1
      let GlobStrIndex     = match(FileMatchPattern,',',GlobStrIndex+1)
   endw
   let GlobFilePatterns = GlobFilePatterns.'\('.strpart(FileMatchPattern,GlobStrLastIndex,strlen(FileMatchPattern)-GlobStrLastIndex).'\)'

   let FindCommand = "`".g:QFFindPath." ".a:SearchPath." -iregex \"".GlobFilePatterns."\"`"
   let g:MyDebug  = FindCommand

   echo FindCommand
   let FileList    = glob(FindCommand)

   let b:MaxFileNameLength = 0
   let GlobStrIndex  = 0
   while( -1 != GlobStrIndex )
      let GlobNextStrIndex = match(FileList,"\n",GlobStrIndex)
      if( -1 == GlobNextStrIndex )
         let GlobNextStrIndex = strlen(FileList) + 1
      endif

      let FileName         = fnamemodify(strpart(FileList,GlobStrIndex,GlobNextStrIndex - GlobStrIndex),":p:t")
      let FileNameLength   = strlen(FileName)

      if( FileNameLength > b:MaxFileNameLength )
         let b:MaxFileNameLength = FileNameLength
      endif

      let GlobStrIndex     = matchend(FileList,"\n",GlobStrIndex)
   endw
   
   setl ma
   setl ve=all
   "Wipe the slate clean
   :norm 1GdG
   let GlobStrIndex  = 0
   while( -1 != GlobStrIndex )
      let GlobNextStrIndex = match(FileList,"\n",GlobStrIndex)
      if( -1 == GlobNextStrIndex )
         let GlobNextStrIndex = strlen(FileList) + 1
      endif

      let FileName            = fnamemodify(strpart(FileList,GlobStrIndex,GlobNextStrIndex - GlobStrIndex),":p:t")
      "Only include the part of the filepath that is relative to the search path
      let FnameModifyString   = ":s?".a:SearchPath."??:h" 
      let FilePathPre         = fnamemodify(strpart(FileList,GlobStrIndex,GlobNextStrIndex - GlobStrIndex),FnameModifyString)
      let FilePath            = strpart(FilePathPre,1,strlen(FilePathPre)-1)

      :exe ':norm i'.FileName
      let FilePathOffset = b:MaxFileNameLength + b:FilePathOffset
      :exe ':norm 0'.FilePathOffset.'li'.FilePath
      :norm o

      let GlobStrIndex     = matchend(FileList,"\n",GlobStrIndex)
   endw
   "Remove the last line   
   :norm dd
   "Go back to the first line
   :norm 1G
   "Turn off virtual edit
   setl ve= 
   cal s:InitColors() "Re-initialize colors now that buffer is updated
   "Now the buffer should not be modifiable
   setl noma
endf

fun! <SID>QFInvokeBuf()
   let BufNum                 = bufnr(s:QFBufName)
   if( -1 == BufNum )
      "Set local options to this buffer
      exe   'silent! botright split '.s:QFBufName
   else
      exe 'sb '.s:QFBufName
   endif

   let WinNum = winbufnr(s:QFBufName)
   if( -1 != BufNum )
      exe WinNum.'winc J'
   endif
endf

fun! <SID>QFExplore()
   call s:QFInvokeBuf()

   if( 0 != s:FirstLoad )
      let s:FirstLoad = 0
      cal s:InitAll()
      if( "" == glob( s:DefaultSessionFile ))
         call QFUpdateFilesPrompt()
      else
         call QFRestoreSession(s:DefaultSessionFile)
         exe 'au BufEnter <buffer='.bufnr(s:QFBufName).'>   call s:LoadIC()'
         exe 'au BufLeave BufWinLeave BufHidden BufUnload <buffer='.bufnr(s:QFBufName).'>   call s:RestoreIC()' 
      endif
   endif
endf

fun! QFExploreToggle()
   if( 0 != s:QFBufferDisplayed )
      let s:QFBufferDisplayed = 0
      let WinNr = bufwinnr(s:QFBufName)
      if( -1 != WinNr )
         if winnr() == WinNr
            exe 'silent! close'
         else
            let CurBufNr = bufnr('%')
            exe WinNr.'winc w'
            exe 'silent! close'
            let WinNr = bufwinnr(CurBufNr)
            if( winnr() != WinNr )
               exe WinNr.'winc w'
            endif
         endif
      endif
   else
      let   s:QFBufferDisplayed = 1
      call  s:QFExplore()
   endif
endf

fun! QFSaveSession()
   "Only save a session if we've actually loaded data either QFExplore() or
   "QFRestoreSession
      "If a session file is passed to this function, then don't prompt the
      "user
      if( has('win32') )
         let SessionFile = b:FileRootPath.'\'.s:DefaultSessionFile
      else
         let SessionFile = b:FileRootPath.'/'.s:DefaultSessionFile
      endif
      let SessionFile = input("Save the session file as: ", SessionFile)
      "Save the values of the max filename length and path offset before
      "loading the new buffer, as these variables are specific to this buffer
      let MaxFileNameLength   = b:MaxFileNameLength
      let FilePathOffset      = b:FilePathOffset
      let FileRootPath        = b:FileRootPath
      let MatchPattern        = b:MatchPattern
      "Write this buffer's contents to the session file
      :exe 'silent! :w! '.escape(SessionFile,'\')
      "Open the session file and make the proper modifications to it.
      :exe 'silent! :new '.escape(SessionFile,'\')
      "Use vim-style commenting to comment out the entire file, since we will be
      "treating it as a vim-script on a restore
      :exe 'silent :%s/^/"/g'
      "Goto the top of the file, and save our current settings (path offset + max
      "filename length)
      :norm 1G
      :exe ":norm Olet b:MatchPattern            = '".MatchPattern."'"
      :exe ':norm jOlet b:FileRootPath            = "'.FileRootPath.'"'
      :exe ':norm jOlet b:MaxFileNameLength       = '.MaxFileNameLength
      :exe ':norm jOlet b:FilePathOffset          = '.FilePathOffset
      :exe 'silent! :wq!'
      "Remove the session file from the buffer list
      :exe 'silent! :bdelete '.escape(SessionFile,'\')
endf

fun! QFRestoreSession(...)
   if( 0 != s:FirstLoad )
      let s:FirstLoad = 0
      cal s:InitAll()
   endif
   "Restore Code Here!  Pretty much reverse what was done in the save
   "session
   if( a:0 > 0 )
      let SessionFile = a:1
   else
      if( has('win32') )
         let SessionFile = b:FileRootPath.'\'.s:DefaultSessionFile
      else
         let SessionFile = b:FileRootPath.'/'.s:DefaultSessionFile
      endif
      let SessionFile = escape(SessionFile,'\')
      let SessionFile = input("Enter the full path of the session file to restore: ", SessionFile)
   endif

   setl ma
   :norm 1GdG
   "Since a session file is in effect a vim-script, invoke it to reset any session-specific variables
   :exe ':source '.SessionFile
   "Read the session file into the current qfile buffer
   :exe ':r '.SessionFile 
   "Remove comments at the start of the lines
   :exe 'silent! :%s/^"//g'
   "Go up one to handle exta line inserted at top, and delete it along with
   "any lines that contain variables. 
   :norm 1G5dd
   cal s:InitColors() "Re-initialize colors upon session load
   setl noma
endf

fun! <SID>QFSort(Col)
   if( has('win32') )
      let  FilePathColNumber = b:MaxFileNameLength + b:FilePathOffset
      :exe 'silent! :w! '.bufname('%').'.tmp'
      :exe 'silent! !C:\WINDOWS\system32\SORT.EXE /+'.a:Col.' '.bufname('%').'.tmp /O '.bufname('%').'.tmp'
      setl ma
      :norm 1GdG
      :exe 'silent! :r '.bufname('%').'.tmp'
      "Remove the line that is inserted when a file is read in
      :norm kdd
      setl noma
      :exe 'silent! !DEL '.bufname('%').'.tmp'
   endif
endf

fun! QFSortFiles()
   call s:QFSort(1)
endf

fun! QFSortFilePaths()
   call s:QFSort(b:MaxFileNameLength + b:FilePathOffset)
endf

fun! QFUpdateRootPath()
   let b:FileRootPath = input("Enter a new root path to use", b:FileRootPath)
   "Now save the session file to make sure the new root path propogates to the
   "session file
   cal QFSaveSession()
endf

fun! QFShowHelp()
  echo "Welcome to the QuickFile VimScript Help Screen."
  echo " "
  echo "QuickFile is a simple project navigator plugin that allows a programmer to generate"
  echo "an index of files in the current directory, filtered by a set of regular expressions."
  echo "It essentially provides a flat-mode quick lookup mechanism to source files of interest"
  echo "to the programmer.  Simply use standard vi search to find a file, and select <Enter> or"
  echo "<space> to open the corresponding file."
  echo " "
  echo "When QuickFile is first launched, it will look for a default session file called 'qfile.sess'"
  echo "in the current directory in which vi is being invoked.  If none exists, it will prompt the"
  echo "user for the file search patterns and the directory search path."
  echo " "
  echo "Some standard key mappings local to the QuickFile buffer include:"
  echo " "
  echo "u         - Re-index the files in the directory, using the previously used search path and search patterns."
  echo "U         - Re-index the files in the directory, prompting the user for the search path and search patterns."
  echo "s | S     - Save the current QuickFile state to a session file."
  echo "r | R     - Restore the QuickFile buffer from a previously saved session file."
  echo "<Leader>s - <Leader> is by default a \\.  This allows the user to sort the QuickFile buffer by the filename."
  echo "<Leader>S - <Leader> is by default a \\.  This allows the user to sort the QuickFile buffer by the directory paths."
  echo "             This is the default." 
  echo "p | P     - This allows the user to change the default root path for all files.  This is useful if a user does not want"
  echo "             to regenerate a session file for an identical software tree map structure in a different location.  For instance,"
  echo "             a programmer might checkout a different branch of trunk, and simply copy qfile.sess into the branch.  By using this"
  echo "             keymapping, the programmer could simply change the root path without executing a potentially expensive update operation."
  echo "h | H | ? - Show this help."
endf

