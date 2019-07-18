" vim:set foldmethod=marker :
"
" $Id: svncommand.vim 27 2006-08-11 04:19:36Z troycurtisjr $
"
" Vim plugin to assist in working with SVN-controlled files.
"
" Last Change:   $Date: 2006-08-10 23:19:36 -0500 (Thu, 10 Aug 2006) $ 
" Version:       $Revision: 27 $
" Maintainer:    Troy S. Curtis Jr <troycurtisjr@gmail.com> 
" License:       This file is placed in the public domain.
" Credits: {{{1
"                Bob Hiestand who is the maintainer of the cvscommand VIM
"                script which this script is a blatent rip-off of. 
"
"                Also thanks to Adam Lazur who was the first to rip-off the 
"                cvscommand script for use with Subversion. What a great idea!
"                I am just getting it up to date with the new cvscommand
"
"  Below is all the Credits found in version 1.76 of cvscommand.  I think all 
"  these guys deserve credit for the svncommand, even if they never knew it
"  existed.
"                Mathieu Clabaut for many suggestions and improvements.
"
"                Suresh Govindachar and Jeeva Chelladhurai for finding waaaay
"                too many bugs.
"
"                Suresh Govindachar (again!) for finding the
"                fully-folded-last-line-delete bug.
"
"                Albrecht Gass for the Delete-on-Hide behavior suggestion.
"
"                Joe MacDonald for finding the CVS log message header bug and
"                pointing out that buffer refreshes are needed after CVS
"                \%(un\)\?edit.
"
"                Srinath Avadhanula for the suggestion and original patch for
"                the CVSCommitOnWrite option and mapping hot key.
"
"                John Sivak for helping to debug Windows issues and suggesting
"                the CVSEditors and CVSWatchers commands.
"
"                Igor Levko for the patch to recognize numerical sticky tags.
"
"                Domink Strasser for the patch to correct the status line for
"                CVSAdd'd files.
"
"                Weerapong Sirikanya for finding a bug with CVSCommit and
"                autochdir.
"
"                David Gotz for finding a bug with CVSVimDiff buffer splitting
"                and original buffer restoration.
"
"                CJ van den Berg for the patch to not change working directory
"                when editing a non-CVS file.
"
"                Luca Gerli for noticing bad behavior for keywords in files
"                after commit if split windows are used.

" Section: Documentation {{{1
"
" Provides functions to invoke various SVN commands on the current file
" (either the current buffer, or, in the case of an directory buffer, the file
" on the current line).  The output of the commands is captured in a new
" scratch window.  For convenience, if the functions are invoked on a SVN
" output window, the original file is used for the svn operation instead after
" the window is split.  This is primarily useful when running SVNCommit and
" you need to see the changes made, so that SVNDiff is usable and shows up in
" another window.
"
" You can find the lastest version in my subversion repository:
" http://troyjr.hopto.org/projects/vim-scripts/svncommand/trunk
"
" Command documentation {{{2
"
" SVNAdd           Performs "svn add" on the current file.
"
" SVNAnnotate      Performs "svn annotate" on the current file.  If an
"                  argument is given, the argument is used as a revision
"                  number to display.  If not given an argument, it uses the
"                  most recent version of the file on the current branch.
"                  Additionally, if the current buffer is a SVNAnnotate buffer
"                  already, the version number on the current line is used.
"
"                  If the 'SVNCommandAnnotateParent' variable is set to a
"                  non-zero value, the version previous to the one on the
"                  current line is used instead.  This allows one to navigate
"                  back to examine the previous version of a line.
"
" SVNCommit[!]     If called with arguments, this performs "svn commit" using
"                  the arguments as the log message.
"
"                  If '!' is used, an empty log message is committed.
"
"                  If called with no arguments, this is a two-step command.
"                  The first step opens a buffer to accept a log message.
"                  When that buffer is written, it is automatically closed and
"                  the file is committed using the information from that log
"                  message.  The commit can be abandoned if the log message
"                  buffer is deleted or wiped before being written.
"
" SVNDiff          With no arguments, this performs "svn diff" on the current
"                  file.  With one argument, "svn diff" is performed on the
"                  current file against the specified revision.  With two
"                  arguments, svn diff is performed between the specified
"                  revisions of the current file.  This command uses the
"                  'SVNCommandDiffOpt' variable to specify diff options.  If
"                  that variable does not exist, then 'wbBc' is assumed.  If
"                  you wish to have no options, then set it to the empty
"                  string.
"
" SVNGotoOriginal  Returns the current window to the source buffer if the
"                  current buffer is a SVN output buffer.
"
" SVNLog           Performs "svn log" on the current file.
"
" SVNRevert        Replaces the modified version of the current file with the
"                  most recent version from the repository.
"
" SVNReview        Retrieves a particular version of the current file.  If no
"                  argument is given, the most recent version of the file on
"                  the current branch is retrieved.  The specified revision is
"                  retrieved into a new buffer.
"
" SVNStatus        Performs "svn status" on the current file.
" 
" SVNInfo          Performs "svn info" on the current file.
"
" SVNUpdate        Performs "svn update" on the current file.
"
" SVNResolved      Performs "svn resolved" on the current file.
"
" SVNVimDiff       With no arguments, this prompts the user for a revision and
"                  then uses vimdiff to display the differences between the
"                  current file and the specified revision.  If no revision is
"                  specified, the most recent version of the file on the
"                  current branch is used.  With one argument, that argument
"                  is used as the revision as above.  With two arguments, the
"                  differences between the two revisions is displayed using
"                  vimdiff.
"
"                  With either zero or one argument, the original buffer is used
"                  to perform the vimdiff.  When the other buffer is closed, the
"                  original buffer will be returned to normal mode.
"
"                  Once vimdiff mode is started using the above methods,
"                  additional vimdiff buffers may be added by passing a single
"                  version argument to the command.  There may be up to 4
"                  vimdiff buffers total.
"
"                  Using the 2-argument form of the command resets the vimdiff
"                  to only those 2 versions.  Additionally, invoking the
"                  command on a different file will close the previous vimdiff
"                  buffers.
"
" SVNPropedit      When no arguments are given, a list of the currently
"                  defined properties is given (using the "svn proplist" command).
"
"                  With one argument, the argument is taken to mean the property to edit, 
"                  and the user is presented with a buffer containing any existing values for 
"                  that property. The interface is similar to the Commit operation.  
"                  
"                  Once the user writes the file (or executes the :SVNPropedit key mapping) 
"                  the property is set with the given changes.
" SVNCommitDiff
"                  Will parse the commit buffer (that should be autogenerated by
"                  svn), and split the window with a corresponding diff. It is
"                  highly convenient to review a diff when writing the log
"                  message.
"
"                  You may want to set the SVNAutoCommitDiff option so that
"                  this function is called automatically when given a
"                  svn-commit.* file.
"
"
"
"
"
" Mapping documentation: {{{2
"
" By default, a mapping is defined for each command.  User-provided mappings
" can be used instead by mapping to <Plug>CommandName, for instance:
"
" nnoremap ,ca <Plug>SVNAdd
"
" The default mappings are as follow:
"
"   <Leader>sa SVNAdd
"   <Leader>sn SVNAnnotate
"   <Leader>sc SVNCommit
"   <Leader>sd SVNDiff
"   <Leader>sg SVNGotoOriginal
"   <Leader>sG SVNGotoOriginal!
"   <Leader>sl SVNLog
"   <Leader>sw SVNReview
"   <Leader>ss SVNStatus
"   <Leader>si SVNInfo
"   <Leader>sr SVNResolved
"   <Leader>su SVNUpdate
"   <Leader>sv SVNVimDiff
"   <Leader>sp SVNPropedit
"
" Options documentation: {{{2
"
" Several variables are checked by the script to determine behavior as follow:
"
" SVNCommandAnnotateParent
"   This variable, if set to a non-zero value, causes the zero-argument form
"   of SVNAnnotate when invoked on a SVNAnnotate buffer to go to the version
"   previous to that displayed on the current line.  If not set, it defaults
"   to 0.
"
" SVNCommandCommitOnWrite
"   This variable, if set to a non-zero value, causes the pending svn commit
"   to take place immediately as soon as the log message buffer is written.
"   If set to zero, only the SVNCommit mapping will cause the pending commit
"   to occur.  If not set, it defaults to 1.
"
" SVNCommandPropsetOnWrite
"   This variable, if set to a non-zero value, causes the pending svn propedit
"   to take place immediately.
"   If set to zero, only the SVNPropedit mapping will cause the pending commit
"   to occur.  If not set, it defaults to 1.
"
" SVNCommandDeleteOnHide
"   This variable, if set to a non-zero value, causes the temporary SVN result
"   buffers to automatically delete themselves when hidden.
"
" SVNCommandDiffOpt
"   This variable, if set, determines the options passed to the diff command
"   of SVN.  If not set, it defaults to 'wbBc'.
"
" SVNCommandDiffSplit
"   This variable overrides the SVNCommandSplit variable, but only for buffers
"   created with SVNVimDiff.
"
" SVNCommandEdit
"   This variable controls whether the original buffer is replaced ('edit') or
"   split ('split').  If not set, it defaults to 'edit'.
"
" SVNCommandEnableBufferSetup
"   This variable, if set to a non-zero value, activates SVN buffer management
"   mode.  This mode means that 'SVNRevision' is set if the file is SVN-controlled.  
"   This is useful for displaying version information in the status bar.
"
" SVNCommandInteractive
"   This variable, if set to a non-zero value, causes appropriate functions (for
"   the moment, only SVNReview) to query the user for a revision to use
"   instead of the current revision if none is specified.
"
" SVNCommandNameMarker
"   This variable, if set, configures the special attention-getting characters
"   that appear on either side of the svn buffer type in the buffer name.
"   This has no effect unless 'SVNCommandNameResultBuffers' is set to a true
"   value.  If not set, it defaults to '_'.  
"
" SVNCommandNameResultBuffers
"   This variable, if set to a true value, causes the svn result buffers to be
"   named in the old way ('<source file name> _<svn command>_').  If not set
"   or set to a false value, the result buffer is nameless.
"
" SVNCommandSplit
"   This variable controls the orientation of the various window splits that
"   may occur (such as with SVNVimDiff, when using a SVN command on a SVN
"   command buffer, or when the 'SVNCommandEdit' variable is set to 'split'.
"   If set to 'horizontal', the resulting windows will be on stacked on top of
"   one another.  If set to 'vertical', the resulting windows will be
"   side-by-side.  If not set, it defaults to 'horizontal' for all but
"   SVNVimDiff windows.
"
" SVNAutoCommitDiff
"   This variable determines whether to enable automatic execution of the
"   SVNCommitDiff() function whenever the file being loaded is an Subversion
"   commit log (svn-commit.*).  The diff output is put into a new window who's
"   orientation is determined by the SVNCommandSplit option. Note that this function 
"   checks that you are at least in a svn working copy before trying to execute.  
"   This keeps things like  cp and mv commands acting directly on the repository from
"   generating errors. Defaults to 0 (disabled).
"
" Event documentation {{{2
"   For additional customization, svncommand.vim uses User event autocommand
"   hooks.  Each event is in the SVNCommand group, and different patterns
"   match the various hooks.
"
"   For instance, the following could be added to the vimrc to provide a 'q'
"   mapping to quit a SVN buffer:
"
"   augroup SVNCommand
"     au SVNCommand User SVNBufferCreated silent! nmap <unique> <buffer> q :bwipeout<cr> 
"   augroup END
"
"   The following hooks are available:
"
"   SVNBufferCreated           This event is fired just after a svn command
"                              result buffer is created and filled with the
"                              result of a svn command.  It is executed within
"                              the context of the new buffer.
"
"   SVNBufferSetup             This event is fired just after SVN buffer setup
"                              occurs, if enabled.
"
"   SVNPluginInit              This event is fired when the SVNCommand plugin
"                              first loads.
"
"   SVNPluginFinish            This event is fired just after the SVNCommand
"                              plugin loads.
"
"   SVNVimDiffFinish           This event is fired just after the SVNVimDiff
"                              command executes to allow customization of,
"                              for instance, window placement and focus.
"
" Section: SVN Default configuration {{{1
" In the same vein has the original script author I will disable these options
" by default, though I highly recommend uncommenting them!  It makes the whole
" experience 100 times better!
 "let SVNCommandSplit='vertical'
 "let SVNCommandDiffSplit='vertical'
 "let SVNCommandEnableBufferSetup='1'
 "let SVNCommandEdit='split'
 "let SVNCommandNameResultBuffers='1'
 "let SVNAutoCommitDiff='1'
  
" Section: SVN command functions {{{1
" Section: Plugin header {{{1

" loaded_svncommand is set to 1 when the initialization begins, and 2 when it
" completes.  This allows various actions to only be taken by functions after
" system initialization.

if exists("loaded_svncommand")
   finish
endif
let loaded_svncommand = 1

if v:version < 602
  echohl WarningMsg|echomsg "SVNCommand 1.69 or later requires VIM 6.2 or later"|echohl None
  finish
endif

" Section: Event group setup {{{1

augroup SVNCommand
augroup END

" Section: Plugin initialization {{{1
silent do SVNCommand User SVNPluginInit

" Section: Script variable initialization {{{1

let s:SVNCommandEditFileRunning = 0
unlet! s:vimDiffRestoreCmd
unlet! s:vimDiffSourceBuffer
unlet! s:vimDiffBufferCount
unlet! s:vimDiffScratchList

" Section: Utility functions {{{1

" Function: s:SVNResolveLink() {{{2
" Fully resolve the given file name to remove shortcuts or symbolic links.

function! s:SVNResolveLink(fileName)
  let resolved = resolve(a:fileName)
  if resolved != a:fileName
    let resolved = s:SVNResolveLink(resolved)
  endif
  return resolved
endfunction

" Function: s:SVNChangeToCurrentFileDir() {{{2
" Go to the directory in which the current SVN-controlled file is located.
" If this is a SVN command buffer, first switch to the original file.

function! s:SVNChangeToCurrentFileDir(fileName)
  let oldCwd=getcwd()
  let fileName=s:SVNResolveLink(a:fileName)
  let newCwd=fnamemodify(fileName, ':h')
  if strlen(newCwd) > 0
    execute 'cd' escape(newCwd, ' ')
  endif
  return oldCwd
endfunction

" Function: s:SVNGetOption(name, default) {{{2
" Grab a user-specified option to override the default provided.  Options are
" searched in the window, buffer, then global spaces.

function! s:SVNGetOption(name, default)
  if exists("s:" . a:name . "Override")
    execute "return s:".a:name."Override"
  elseif exists("w:" . a:name)
    execute "return w:".a:name
  elseif exists("b:" . a:name)
    execute "return b:".a:name
  elseif exists("g:" . a:name)
    execute "return g:".a:name
  else
    return a:default
  endif
endfunction

" Function: s:SVNEditFile(name, origBuffNR) {{{2
" Wrapper around the 'edit' command to provide some helpful error text if the
" current buffer can't be abandoned.  If name is provided, it is used;
" otherwise, a nameless scratch buffer is used.
" Returns: 0 if successful, -1 if an error occurs.

function! s:SVNEditFile(name, origBuffNR)
  "Name parameter will be pasted into expression.
  let name = escape(a:name, ' *?\')

  let editCommand = s:SVNGetOption('SVNCommandEdit', 'edit')
  if editCommand != 'edit'
    if s:SVNGetOption('SVNCommandSplit', 'horizontal') == 'horizontal'
      if name == ""
        let editCommand = 'rightbelow new'
      else
        let editCommand = 'rightbelow split ' . name
      endif
    else
      if name == ""
        let editCommand = 'vert rightbelow new'
      else
        let editCommand = 'vert rightbelow split ' . name
      endif
    endif
  else
    if name == ""
      let editCommand = 'enew'
    else
      let editCommand = 'edit ' . name
    endif
  endif

  " Protect against useless buffer set-up
  let s:SVNCommandEditFileRunning = s:SVNCommandEditFileRunning + 1
  try
    execute editCommand
  finally
    let s:SVNCommandEditFileRunning = s:SVNCommandEditFileRunning - 1
  endtry

  let b:SVNOrigBuffNR=a:origBuffNR
  let b:SVNCommandEdit='split'
endfunction

" Function: s:SVNCreateCommandBuffer(cmd, cmdName, statusText, filename) {{{2
" Creates a new scratch buffer and captures the output from execution of the
" given command.  The name of the scratch buffer is returned.

function! s:SVNCreateCommandBuffer(cmd, cmdName, statusText, origBuffNR)
  let fileName=bufname(a:origBuffNR)

  let resultBufferName=''

  if s:SVNGetOption("SVNCommandNameResultBuffers", 0)
    let nameMarker = s:SVNGetOption("SVNCommandNameMarker", '_')
    if strlen(a:statusText) > 0
      let bufName=a:cmdName . ' -- ' . a:statusText
    else
      let bufName=a:cmdName
    endif
    let bufName=fileName . ' ' . nameMarker . bufName . nameMarker
    let counter=0
    let resultBufferName = bufName
    while buflisted(resultBufferName)
      let counter=counter + 1
      let resultBufferName=bufName . ' (' . counter . ')'
    endwhile
  endif

  let svnCommand = s:SVNGetOption("SVNCommandSVNExec", "svn") . " " . a:cmd
  let svnOut = system(svnCommand)
  " HACK:  diff command does not return proper error codes
  if v:shell_error && a:cmdName != 'svndiff'
    if strlen(svnOut) == 0
      echoerr "SVN command failed"
    else
      echoerr "SVN command failed:  " . svnOut
    endif
    return -1
  endif
  if strlen(svnOut) == 0
    " Handle case of no output.  In this case, it is important to check the
    " file status, especially since svn edit/unedit may change the attributes
    " of the file with no visible output.

    echomsg "No output from SVN command"
    checktime
    return -1
  endif

  if s:SVNEditFile(resultBufferName, a:origBuffNR) == -1
    return -1
  endif

  set buftype=nofile
  set noswapfile
  set filetype=

  if s:SVNGetOption("SVNCommandDeleteOnHide", 0)
    set bufhidden=delete
  endif

  silent 0put=svnOut

  " The last command left a blank line at the end of the buffer.  If the
  " last line is folded (a side effect of the 'put') then the attempt to
  " remove the blank line will kill the last fold.
  "
  " This could be fixed by explicitly detecting whether the last line is
  " within a fold, but I prefer to simply unfold the result buffer altogether.

  if has('folding')
    normal zR
  endif

  $d
  1

  " Define the environment and execute user-defined hooks.

  let b:SVNSourceFile=fileName
  let b:SVNCommand=a:cmdName
  if a:statusText != ""
    let b:SVNStatusText=a:statusText
  endif

  silent do SVNCommand User SVNBufferCreated
  return bufnr("%")
endfunction

" Function: s:SVNBufferCheck(svnBuffer) {{{2
" Attempts to locate the original file to which SVN operations were applied
" for a given buffer.

function! s:SVNBufferCheck(svnBuffer)
  let origBuffer = getbufvar(a:svnBuffer, "SVNOrigBuffNR")
  if origBuffer
    if bufexists(origBuffer)
      return origBuffer
    else
      " Original buffer no longer exists.
      return -1 
    endif
  else
    " No original buffer
    return a:svnBuffer
  endif
endfunction

" Function: s:SVNCurrentBufferCheck() {{{2
" Attempts to locate the original file to which SVN operations were applied
" for the current buffer.

function! s:SVNCurrentBufferCheck()
  return s:SVNBufferCheck(bufnr("%"))
endfunction

" Function: s:SVNToggleDeleteOnHide() {{{2
" Toggles on and off the delete-on-hide behavior of SVN buffers

function! s:SVNToggleDeleteOnHide()
  if exists("g:SVNCommandDeleteOnHide")
    unlet g:SVNCommandDeleteOnHide
  else
    let g:SVNCommandDeleteOnHide=1
  endif
endfunction

" Function: s:SVNDoCommand(svncmd, cmdName, statusText) {{{2
" General skeleton for SVN function execution.
" Returns: name of the new command buffer containing the command results

function! s:SVNDoCommand(cmd, cmdName, statusText)
  let svnBufferCheck=s:SVNCurrentBufferCheck()
  if svnBufferCheck == -1 
    echo "Original buffer no longer exists, aborting."
    return -1
  endif

  let fileName=bufname(svnBufferCheck)
  if isdirectory(fileName)
    let fileName=fileName . "/" . getline(".")
  endif
  let realFileName = fnamemodify(s:SVNResolveLink(fileName), ':t')
  let oldCwd=s:SVNChangeToCurrentFileDir(fileName)
  try
    if !filereadable('.svn/entries')
      throw fileName . ' is not a SVN-controlled file.'
    endif
    let fullCmd = a:cmd . ' "' . realFileName . '"'
    let resultBuffer=s:SVNCreateCommandBuffer(fullCmd, a:cmdName, a:statusText, svnBufferCheck)
    return resultBuffer
  catch
    echoerr v:exception
    return -1
  finally
    execute 'cd' escape(oldCwd, ' ')
  endtry
endfunction


" Function: s:SVNGetStatusVars(revision, branch, repository) {{{2
"
" Obtains a SVN revision number and branch name.  The 'revisionVar',
" and 'repositoryVar' arguments, if non-empty, contain the names of variables to hold
" the corresponding results.
"
" Returns: string to be exec'd that sets the multiple return values.

function! s:SVNGetStatusVars(revisionVar, repositoryVar)
  let svnBufferCheck=s:SVNCurrentBufferCheck()
  if svnBufferCheck == -1 
    return ""
  endif
  let fileName=bufname(svnBufferCheck)
  let realFileName = fnamemodify(s:SVNResolveLink(fileName), ':t')
  let oldCwd=s:SVNChangeToCurrentFileDir(fileName)
  try
    if !filereadable('.svn/entries')
      return ""
    endif
    let svnCommand = s:SVNGetOption("SVNCommandSVNExec", "svn") . " info " . escape(realFileName, ' *?\')
    let infotext=system(svnCommand)
    if(v:shell_error)
      return ""
    endif
    let revision=substitute(infotext, '^\_.*Revision:\s*\(\d*\)\_.*', '\1', "")

    " We can still be in a SVN-controlled directory without this being a SVN
    " file
    if match(revision, '//') >= 0 
      let revision="NEW"
    elseif match(revision, '^\d*$') >=0
      let dummy = "" 
    else
      return ""
    endif

    let returnExpression = "let " . a:revisionVar . "='" . revision . "'"

    if a:repositoryVar != ""
      let repository=substitute(infotext, '^\_.*URL:\s*\([a-zA-Z0-9_:\-/]\+\)\_.*$', '\1', "")
      let repository=substitute(repository, '^newfile:.*$', 'NEW', "")
      let returnExpression=returnExpression . " | let " . a:repositoryVar . "='" . repository . "'"
    endif

    return returnExpression
  finally
    execute 'cd' escape(oldCwd, ' ')
  endtry
endfunction

" Function: s:SVNSetupBuffer() {{{2
" Attempts to set the b:SVNRevision and b:SVNRepository variables.

function! s:SVNSetupBuffer()
  if (exists("b:SVNBufferSetup") && b:SVNBufferSetup)
    " This buffer is already set up.
    return
  endif

  if !s:SVNGetOption("SVNCommandEnableBufferSetup", 0)
        \ || @% == ""
        \ || s:SVNCommandEditFileRunning > 0
        \ || exists("b:SVNOrigBuffNR")
    unlet! b:SVNRevision
    unlet! b:SVNRepository
    return
  endif

  if !filereadable(expand("%"))
    return -1
  endif

  let revision=""
  let branch=""
  let repository=""

  exec s:SVNGetStatusVars('revision', 'repository')
  if revision != ""
    let b:SVNRevision=revision
  else
    unlet! b:SVNRevision
  endif
  if repository != ""
     let b:SVNRepository=repository
  else
     unlet! b:SVNRepository
  endif
  silent do SVNCommand User SVNBufferSetup
  let b:SVNBufferSetup=1
endfunction

" Function: s:SVNMarkOrigBufferForSetup(svnbuffer) {{{2
" Resets the buffer setup state of the original buffer for a given SVN buffer.
" Returns:  The SVN buffer number in a passthrough mode.

function! s:SVNMarkOrigBufferForSetup(svnBuffer)
  checktime
  if a:svnBuffer != -1
    let origBuffer = s:SVNBufferCheck(a:svnBuffer)
    "This should never not work, but I'm paranoid
    if origBuffer != a:svnBuffer
      call setbufvar(origBuffer, "SVNBufferSetup", 0)
    endif
  endif
  return a:svnBuffer
endfunction

" Function: s:SVNOverrideOption(option, [value]) {{{2
" Provides a temporary override for the given SVN option.  If no value is
" passed, the override is disabled.

function! s:SVNOverrideOption(option, ...)
  if a:0 == 0
    unlet! s:{a:option}Override
  else
    let s:{a:option}Override = a:1
  endif
endfunction

" Function: s:SVNWipeoutCommandBuffers() {{{2
" Clears all current SVN buffers of the specified type for a given source.

function! s:SVNWipeoutCommandBuffers(originalBuffer, svnCommand)
  let buffer = 1
  while buffer <= bufnr('$')
    if getbufvar(buffer, 'SVNOrigBuffNR') == a:originalBuffer
      if getbufvar(buffer, 'SVNCommand') == a:svnCommand
        execute 'bw' buffer
      endif
    endif
    let buffer = buffer + 1
  endwhile
endfunction

" Section: Public functions {{{1

" Function: SVNGetRevision() {{{2
" Global function for retrieving the current buffer's SVN revision number.
" Returns: Revision number or an empty string if an error occurs.

function! SVNGetRevision()
  let revision=""
  exec s:SVNGetStatusVars('revision', '')
  return revision
endfunction



" Function: SVNEnableBufferSetup() {{{2
" Global function for activating the buffer autovariables.

function! SVNEnableBufferSetup()
  let g:SVNCommandEnableBufferSetup=1
  augroup SVNCommandPlugin
    au!
    au BufEnter * call s:SVNSetupBuffer()
  augroup END

  " Only auto-load if the plugin is fully loaded.  This gives other plugins a
  " chance to run.
  if g:loaded_svncommand == 2
    call s:SVNSetupBuffer()
  endif
endfunction

" Function: SVNGetStatusLine() {{{2
" Default (sample) status line entry for SVN files.  This is only useful if
" SVN-managed buffer mode is on (see the SVNCommandEnableBufferSetup variable
" for how to do this).

function! SVNGetStatusLine()
  if exists('b:SVNSourceFile')
    " This is a result buffer
    let value='[' . b:SVNCommand . ' ' . b:SVNSourceFile
    if exists('b:SVNStatusText')
      let value=value . ' ' . b:SVNStatusText
    endif
    let value = value . ']'
    return value
  endif

  if exists('b:SVNRevision')
        \ && b:SVNRevision != ''
        \ && exists('b:SVNRepository')
        \ && b:SVNRepository != ''
        \ && exists('g:SVNCommandEnableBufferSetup')
        \ && g:SVNCommandEnableBufferSetup
    if b:SVNRevision == b:SVNRepository
      return '[SVN ' . b:SVNRevision . ']'
    else
      return '[SVN ' . b:SVNRevision . '/' . b:SVNRepository . ']'
    endif
  else
    return ''
  endif
endfunction


" Function: s:SVNAdd() {{{2
function! s:SVNAdd()
  return s:SVNMarkOrigBufferForSetup(s:SVNDoCommand('add', 'svnadd', ''))
endfunction

" Function: s:SVNAnnotate(...) {{{2
function! s:SVNAnnotate(...)
  if a:0 == 0
    if &filetype == "SVNAnnotate"
      " This is a SVNAnnotate buffer.  Perform annotation of the version
      " indicated by the current line.
      let revision = substitute(getline("."),'\(^[ \t]*[0-9]*\).*','\1','')
      if s:SVNGetOption('SVNCommandAnnotateParent', 0) != 0
        let revision = revision - 1
      endif
    else
      let revision=SVNGetRevision()
      if revision == ""
        echoerr "Unable to obtain SVN version information."
        return -1
      endif
    endif
  else
    let revision=a:1
  endif

  if revision == "NEW"
    echo "No annotatation available for new file."
    return -1
  endif

  let resultBuffer=s:SVNDoCommand('annotate -r ' . revision, 'svnannotate', revision) 
  if resultBuffer !=  -1
    set filetype=SVNAnnotate
  endif

  return resultBuffer
endfunction

" Function: s:SVNCommit() {{{2
function! s:SVNCommit(...)
  " Handle the commit message being specified.  If a message is supplied, it
  " is used; if bang is supplied, an empty message is used; otherwise, the
  " user is provided a buffer from which to edit the commit message.
  if a:2 != "" || a:1 == "!"
    return s:SVNMarkOrigBufferForSetup(s:SVNDoCommand('commit -m "' . a:2 . '"', 'svncommit', ''))
  endif

  let svnBufferCheck=s:SVNCurrentBufferCheck()
  if svnBufferCheck ==  -1
    echo "Original buffer no longer exists, aborting."
    return -1
  endif

  " Protect against windows' backslashes in paths.  They confuse exec'd
  " commands.

  let shellSlashBak = &shellslash
  try
    set shellslash

    let messageFileName = tempname()

    let fileName=bufname(svnBufferCheck)
    let realFilePath=s:SVNResolveLink(fileName)
    let newCwd=fnamemodify(realFilePath, ':h')
    if strlen(newCwd) == 0
      " Account for autochdir being in effect, which will make this blank, but
      " we know we'll be in the current directory for the original file.
      let newCwd = getcwd()
    endif

    let realFileName=fnamemodify(realFilePath, ':t')

    if s:SVNEditFile(messageFileName, svnBufferCheck) == -1
      return
    endif

    " Protect against case and backslash issues in Windows.
    let autoPattern = '\c' . messageFileName

    " Ensure existance of group
    augroup SVNCommit
    augroup END

    execute 'au SVNCommit BufDelete' autoPattern 'call delete("' . messageFileName . '")'
    execute 'au SVNCommit BufDelete' autoPattern 'au! SVNCommit * ' autoPattern

    " Create a commit mapping.  The mapping must clear all autocommands in case
    " it is invoked when SVNCommandCommitOnWrite is active, as well as to not
    " invoke the buffer deletion autocommand.

    execute 'nnoremap <silent> <buffer> <Plug>SVNCommit '.
          \ ':au! SVNCommit * ' . autoPattern . '<CR>'.
          \ ':g/^SVN:/d<CR>'.
          \ ':update<CR>'.
          \ ':call <SID>SVNFinishCommit("' . messageFileName . '",' .
          \                             '"' . newCwd . '",' .
          \                             '"' . realFileName . '",' .
          \                             svnBufferCheck . ')<CR>'

    silent 0put ='SVN: ----------------------------------------------------------------------'
    silent put =\"SVN: Enter Log.  Lines beginning with `SVN:' are removed automatically\"
    silent put ='SVN: Type <leader>sc (or your own <Plug>SVNCommit mapping)'

    if s:SVNGetOption('SVNCommandCommitOnWrite', 1) == 1
      execute 'au SVNCommit BufWritePre' autoPattern 'g/^SVN:/d'
      execute 'au SVNCommit BufWritePost' autoPattern 'call s:SVNFinishCommit("' . messageFileName . '", "' . newCwd . '", "' . realFileName . '", ' . svnBufferCheck . ') | au! * ' autoPattern
      silent put ='SVN: or write this buffer'
    endif

    silent put ='SVN: to finish this commit operation'
    silent put ='SVN: ----------------------------------------------------------------------'
    $
    let b:SVNSourceFile=fileName
    let b:SVNCommand='SVNCommit'
    set filetype=svn

    syn match  svnComment /^SVN:.*$/ 

    if !exists("did_svnComment_syn_init")
      let did_svnComment_syn_init = 1
      hi link svnComment Comment
    endif

  finally
    let &shellslash = shellSlashBak
  endtry

endfunction

" Function: s:SVNDiff(...) {{{2
function! s:SVNDiff(...)
  if a:0 == 1
    let revOptions = '-r' . a:1
    let caption = a:1 . ' -> current'
  elseif a:0 == 2
    let revOptions = '-r' . a:1 . ' -r' . a:2
    let caption = a:1 . ' -> ' . a:2
  else
    let revOptions = ''
    let caption = ''
  endif

  let svndiffopt=s:SVNGetOption('SVNCommandDiffOpt', '')

  if svndiffopt == ""
    let diffoptionstring=""
  else
    let diffoptionstring=" -" . svndiffopt . " "
  endif

  let resultBuffer = s:SVNDoCommand('diff ' . diffoptionstring . revOptions , 'svndiff', caption)
  if resultBuffer != -1 
    set filetype=diff
  endif
  return resultBuffer
endfunction


" Function: s:SVNGotoOriginal(["!]) {{{2
function! s:SVNGotoOriginal(...)
  let origBuffNR = s:SVNCurrentBufferCheck()
  if origBuffNR > 0
    let origWinNR = bufwinnr(origBuffNR)
    if origWinNR == -1
      execute 'buffer' origBuffNR
    else
      execute origWinNR . 'wincmd w'
    endif
    if a:0 == 1
      if a:1 == "!"
        let buffnr = 1
        let buffmaxnr = bufnr("$")
        while buffnr <= buffmaxnr
          if getbufvar(buffnr, "SVNOrigBuffNR") == origBuffNR
            execute "bw" buffnr
          endif
          let buffnr = buffnr + 1
        endwhile
      endif
    endif
  endif
endfunction

" Function: s:SVNFinishCommit(messageFile, targetDir, targetFile) {{{2
function! s:SVNFinishCommit(messageFile, targetDir, targetFile, origBuffNR)
  if filereadable(a:messageFile)
    let oldCwd=getcwd()
    if strlen(a:targetDir) > 0
      execute 'cd' escape(a:targetDir, ' ')
    endif
    let resultBuffer=s:SVNCreateCommandBuffer('commit -F "' . a:messageFile . '" "'. a:targetFile . '"', 'svncommit', '', a:origBuffNR)
    execute 'cd' escape(oldCwd, ' ')
    execute 'bw' escape(a:messageFile, ' *?\')
    silent execute 'call delete("' . a:messageFile . '")'
    return s:SVNMarkOrigBufferForSetup(resultBuffer)
  else
    echoerr "Can't read message file; no commit is possible."
    return -1
  endif
endfunction

" Function: s:SVNLog() {{{2
function! s:SVNLog(...)
  if a:0 == 0
    let versionOption = ""
    let caption = ''
  else
    let versionOption=" -r" . a:1
    let caption = a:1
  endif

  let resultBuffer=s:SVNDoCommand('log' . versionOption, 'svnlog', caption)
  if resultBuffer != ""
    set filetype=rcslog
  endif
  return resultBuffer
endfunction

" Function: s:SVNRevert() {{{2
function! s:SVNRevert()
  return s:SVNMarkOrigBufferForSetup(s:SVNDoCommand('revert ', 'svnrevert', ''))
endfunction

" Function: s:SVNReview(...) {{{2
function! s:SVNReview(...)
  if a:0 == 0
    let versiontag=""
    if s:SVNGetOption('SVNCommandInteractive', 0)
      let versiontag=input('Revision:  ')
    endif
    if versiontag == ""
      let versiontag="(current)"
      let versionOption=""
    else
      let versionOption=" -r " . versiontag . " "
    endif
  else
    let versiontag=a:1
    let versionOption=" -r " . versiontag . " "
  endif

  let resultBuffer = s:SVNDoCommand('cat' . versionOption, 'svnreview', versiontag)
  if resultBuffer > 0
    let &filetype=getbufvar(b:SVNOrigBuffNR, '&filetype')
  endif

  return resultBuffer
endfunction

" Function: s:SVNStatus() {{{2
function! s:SVNStatus()
  return s:SVNDoCommand('status', 'svnstatus', '')
endfunction

" Function: s:SVNInfo() {{{2
function! s:SVNInfo()
  return s:SVNDoCommand('info', 'svninfo', '')
endfunction

" Function: s:SVNPropedit() {{{2
function! s:SVNPropedit(...)
  if(a:1 == "")
     return s:SVNDoCommand('proplist ', 'svnproplist', '')
  endif

  " Copied from the commit stuff
  let svnBufferCheck=s:SVNCurrentBufferCheck()
  if svnBufferCheck ==  -1
    echo "Original buffer no longer exists, aborting."
    return -1
  endif

  " Protect against windows' backslashes in paths.  They confuse exec'd
  " commands.

  let shellSlashBak = &shellslash
  try
    set shellslash

    let messageFileName = tempname()

    let fileName=bufname(svnBufferCheck)
    let realFilePath=s:SVNResolveLink(fileName)
    let newCwd=fnamemodify(realFilePath, ':h')
    if strlen(newCwd) == 0
      " Account for autochdir being in effect, which will make this blank, but
      " we know we'll be in the current directory for the original file.
      let newCwd = getcwd()
    endif

    let realFileName=fnamemodify(realFilePath, ':t')

    if s:SVNEditFile(messageFileName, svnBufferCheck) == -1
      return
    endif

    " Protect against case and backslash issues in Windows.
    let autoPattern = '\c' . messageFileName

    " Ensure existance of group
    augroup SVNPropedit
    augroup END

    execute 'au SVNPropedit BufDelete' autoPattern 'call delete("' . messageFileName . '")'
    execute 'au SVNPropedit BufDelete' autoPattern 'au! SVNPropedit * ' autoPattern

    " Create a property edit mapping.  The mapping must clear all autocommands in case
    " it is invoked when SVNCommandPropsetOnWrite is active, as well as to not
    " invoke the buffer deletion autocommand.

    execute 'nnoremap <silent> <buffer> <Plug>SVNPropedit ' .
          \ ':au! SVNPropedit * ' . autoPattern . '<CR>'.
          \ ':g/^SVN:/d<CR>'.
          \ ':update<CR>'.
          \ ':call <SID>SVNFinishPropedit("' . messageFileName . '",' .
          \                             '"' . newCwd . '",' .
          \                             '"' . realFileName . '",' .
          \                             '"' . svnBufferCheck . '", ' .
          \                             '"' . a:1 . '")<CR>'

    silent 0put ='SVN: ----------------------------------------------------------------------'
    silent put =\"SVN: Enter Log.  Lines beginning with `SVN:' are removed automatically\"
    silent put ='SVN: Type <leader>sp (or your own <Plug>SVNPropedit mapping)'

    if s:SVNGetOption('SVNCommandPropsetOnWrite', 1) == 1
      execute 'au SVNPropedit BufWritePre' autoPattern 'g/^SVN:/d'
      execute 'au SVNPropedit BufWritePost' autoPattern 'call s:SVNFinishPropedit("' . messageFileName . '", "' . newCwd . '", "' . realFileName . '", "' . svnBufferCheck . '", "' . a:1 . '") | au! * ' autoPattern
      silent put ='SVN: or write this buffer'
    endif

    silent put ='SVN: to finish this Property Edit operation'
    silent put ='SVN: ----------------------------------------------------------------------'

    let svnCommand = s:SVNGetOption("SVNCommandSVNExec", "svn") . " propget " . a:1 . " " . realFileName 
    silent put = system(svnCommand)
    $
    let b:SVNSourceFile=fileName
    let b:SVNCommand='SVNPropedit'
    set filetype=svn

    syn match  svnComment /^SVN:.*$/ 

    if !exists("did_svnComment_syn_init")
      let did_svnComment_syn_init = 1
      hi link svnComment Comment
    endif

  finally
    let &shellslash = shellSlashBak
  endtry
endfunction

" Function: s:SVNFinishPropedit(messageFile, targetDir, targetFile) {{{2
function! s:SVNFinishPropedit(messageFile, targetDir, targetFile, origBuffNR, propertyName)
  if filereadable(a:messageFile)
    let oldCwd=getcwd()
    if strlen(a:targetDir) > 0
      execute 'cd' escape(a:targetDir, ' ')
    endif
    let resultBuffer=s:SVNCreateCommandBuffer('propset -F "' . a:messageFile . '" "'. a:propertyName . '" "' . a:targetFile . '"', 'svnpropedit', '', a:origBuffNR)
    execute 'cd' escape(oldCwd, ' ')
    execute 'bw' escape(a:messageFile, ' *?\')
    silent execute 'call delete("' . a:messageFile . '")'
    return s:SVNMarkOrigBufferForSetup(resultBuffer)
  else
    echoerr "Can't read message file; no propset is possible."
    return -1
  endif
endfunction

" Function: s:SVNResolved() {{{2
function! s:SVNResolved()
  return s:SVNDoCommand('resolved', 'svnresolved', '')
endfunction

" Function: s:SVNUpdate() {{{2
function! s:SVNUpdate()
  return s:SVNMarkOrigBufferForSetup(s:SVNDoCommand('update', 'update', ''))
endfunction

" Function: s:SVNVimDiff(...) {{{2
function! s:SVNVimDiff(...)
  let originalBuffer = s:SVNCurrentBufferCheck()
  let s:SVNCommandEditFileRunning = s:SVNCommandEditFileRunning + 1
  try
    " If there's already a VimDiff'ed window, restore it.
    " There may only be one SVNVimDiff original window at a time.

    if exists("s:vimDiffSourceBuffer") && s:vimDiffSourceBuffer != originalBuffer
      " Clear the existing vimdiff setup by removing the result buffers.
      call s:SVNWipeoutCommandBuffers(s:vimDiffSourceBuffer, 'vimdiff')
    endif

    " Split and diff
    if(a:0 == 2)
      " Reset the vimdiff system, as 2 explicit versions were provided.
      if exists('s:vimDiffSourceBuffer')
        call s:SVNWipeoutCommandBuffers(s:vimDiffSourceBuffer, 'vimdiff')
      endif
      let resultBuffer = s:SVNReview(a:1)
      if resultBuffer < 0
        echomsg "Can't open SVN revision " . a:1
        return resultBuffer
      endif
      let b:SVNCommand = 'vimdiff'
      diffthis
      let s:vimDiffBufferCount = 1
      let s:vimDiffScratchList = '{'. resultBuffer . '}'
      " If no split method is defined, cheat, and set it to vertical.
      try
        call s:SVNOverrideOption('SVNCommandSplit', s:SVNGetOption('SVNCommandDiffSplit', s:SVNGetOption('SVNCommandSplit', 'vertical')))
        let resultBuffer=s:SVNReview(a:2)
      finally
        call s:SVNOverrideOption('SVNCommandSplit')
      endtry
      if resultBuffer < 0
        echomsg "Can't open SVN revision " . a:1
        return resultBuffer
      endif
      let b:SVNCommand = 'vimdiff'
      diffthis
      let s:vimDiffBufferCount = 2
      let s:vimDiffScratchList = s:vimDiffScratchList . '{'. resultBuffer . '}'
    else
      " Add new buffer
      try
        " Force splitting behavior, otherwise why use vimdiff?
        call s:SVNOverrideOption("SVNCommandEdit", "split")
        call s:SVNOverrideOption("SVNCommandSplit", s:SVNGetOption('SVNCommandDiffSplit', s:SVNGetOption('SVNCommandSplit', 'vertical')))
        if(a:0 == 0)
          let resultBuffer=s:SVNReview()
        else
          let resultBuffer=s:SVNReview(a:1)
        endif
      finally
        call s:SVNOverrideOption("SVNCommandEdit")
        call s:SVNOverrideOption("SVNCommandSplit")
      endtry
      if resultBuffer < 0
        echomsg "Can't open current SVN revision"
        return resultBuffer
      endif
      let b:SVNCommand = 'vimdiff'
      diffthis

      if !exists('s:vimDiffBufferCount')
        " New instance of vimdiff.
        let s:vimDiffBufferCount = 2
        let s:vimDiffScratchList = '{' . resultBuffer . '}'

        " This could have been invoked on a SVN result buffer, not the
        " original buffer.
        wincmd W
        execute 'buffer' originalBuffer
        " Store info for later original buffer restore
        let s:vimDiffRestoreCmd = 
              \    "call setbufvar(".originalBuffer.", \"&diff\", ".getbufvar(originalBuffer, '&diff').")"
              \ . "|call setbufvar(".originalBuffer.", \"&foldcolumn\", ".getbufvar(originalBuffer, '&foldcolumn').")"
              \ . "|call setbufvar(".originalBuffer.", \"&foldenable\", ".getbufvar(originalBuffer, '&foldenable').")"
              \ . "|call setbufvar(".originalBuffer.", \"&foldmethod\", '".getbufvar(originalBuffer, '&foldmethod')."')"
              \ . "|call setbufvar(".originalBuffer.", \"&scrollbind\", ".getbufvar(originalBuffer, '&scrollbind').")"
              \ . "|call setbufvar(".originalBuffer.", \"&wrap\", ".getbufvar(originalBuffer, '&wrap').")"
              \ . "|if &foldmethod=='manual'|execute 'normal zE'|endif"
        diffthis
        wincmd w
      else
        " Adding a window to an existing vimdiff
        let s:vimDiffBufferCount = s:vimDiffBufferCount + 1
        let s:vimDiffScratchList = s:vimDiffScratchList . '{' . resultBuffer . '}'
      endif
    endif

    let s:vimDiffSourceBuffer = originalBuffer

    " Avoid executing the modeline in the current buffer after the autocommand.

    let currentBuffer = bufnr('%')
    let saveModeline = getbufvar(currentBuffer, '&modeline')
    try
      call setbufvar(currentBuffer, '&modeline', 0)
      silent do SVNCommand User SVNVimDiffFinish
    finally
      call setbufvar(currentBuffer, '&modeline', saveModeline)
    endtry
    return resultBuffer
  finally
    let s:SVNCommandEditFileRunning = s:SVNCommandEditFileRunning - 1
  endtry
endfunction

" Function: s:SVNCommitDiff() {{{2
function! s:SVNCommitDiff()
  let i = line('$')       " last line #
  let cmdline = ""

  " Check if this is even a working copy, it could be a copy, move, or other
  " direct repository manipulation
  if !isdirectory(".svn")
     return
  endif

  let myline = getline(i)
  while i >= 0 && myline =~ "[DMA_][M ]   .*"
    " rip off the filename and prepend to cmdline
    let cmdline = strpart(myline, 5) . " " . cmdline

    " prepare for the next iteration
    let i = i - 1
    let myline = getline(i)
  endwhile

  if cmdline == ''
    echoerr "No well formed lines found"
    return
  endif

  let resultBuffer = s:SVNDoCommand('diff ' . cmdline, 'svndiff', '')
  if resultBuffer != -1
    set filetype=diff
  endif
  return resultBuffer

endfunction
" Section: Command definitions {{{1
" Section: Primary commands {{{2
com! SVNAdd call s:SVNAdd()
com! -nargs=? SVNAnnotate call s:SVNAnnotate(<f-args>)
com! -bang -nargs=? SVNCommit call s:SVNCommit(<q-bang>, <q-args>)
com! -nargs=? SVNPropedit call s:SVNPropedit(<q-args>)
com! -nargs=* SVNDiff call s:SVNDiff(<f-args>)
com! -bang SVNGotoOriginal call s:SVNGotoOriginal(<q-bang>)
com! -nargs=? SVNLog call s:SVNLog(<f-args>)
com! SVNRevert call s:SVNRevert()
com! -nargs=? SVNReview call s:SVNReview(<f-args>)
com! SVNStatus call s:SVNStatus()
com! SVNInfo call s:SVNInfo()
com! SVNResolved call s:SVNResolved()
com! SVNUpdate call s:SVNUpdate()
com! -nargs=* SVNVimDiff call s:SVNVimDiff(<f-args>)
com! SVNCommitDiff call s:SVNCommitDiff()

" Section: SVN buffer management commands {{{2
com! SVNDisableBufferSetup call SVNDisableBufferSetup()
com! SVNEnableBufferSetup call SVNEnableBufferSetup()

" Allow reloading svncommand.vim
com! SVNReload unlet! loaded_svncommand | runtime plugin/svncommand.vim

" Section: Plugin command mappings {{{1
nnoremap <silent> <Plug>SVNAdd :SVNAdd<CR>
nnoremap <silent> <Plug>SVNAnnotate :SVNAnnotate<CR>
nnoremap <silent> <Plug>SVNCommit :SVNCommit<CR>
nnoremap <silent> <Plug>SVNDiff :SVNDiff<CR>
nnoremap <silent> <Plug>SVNGotoOriginal :SVNGotoOriginal<CR>
nnoremap <silent> <Plug>SVNClearAndGotoOriginal :SVNGotoOriginal!<CR>
nnoremap <silent> <Plug>SVNLog :SVNLog<CR>
nnoremap <silent> <Plug>SVNRevert :SVNRevert<CR>
nnoremap <silent> <Plug>SVNReview :SVNReview<CR>
nnoremap <silent> <Plug>SVNStatus :SVNStatus<CR>
nnoremap <silent> <Plug>SVNInfo :SVNInfo<CR>
nnoremap <silent> <Plug>SVNPropedit :SVNPropedit<CR>
nnoremap <silent> <Plug>SVNResolved :SVNResolved<CR>
nnoremap <silent> <Plug>SVNUpdate :SVNUpdate<CR>
nnoremap <silent> <Plug>SVNVimDiff :SVNVimDiff<CR>
nnoremap <silent> <Plug>SVNCommitDiff :SVNCommitDiff<CR>

" Section: Default mappings {{{1
if !hasmapto('<Plug>SVNAdd')
  nmap <unique> <Leader>sa <Plug>SVNAdd
endif
if !hasmapto('<Plug>SVNAnnotate')
  nmap <unique> <Leader>sn <Plug>SVNAnnotate
endif
if !hasmapto('<Plug>SVNClearAndGotoOriginal')
  nmap <unique> <Leader>sG <Plug>SVNClearAndGotoOriginal
endif
if !hasmapto('<Plug>SVNCommit')
  nmap <unique> <Leader>sc <Plug>SVNCommit
endif
if !hasmapto('<Plug>SVNDiff')
  nmap <unique> <Leader>sd <Plug>SVNDiff
endif
if !hasmapto('<Plug>SVNGotoOriginal')
  nmap <unique> <Leader>sg <Plug>SVNGotoOriginal
endif
if !hasmapto('<Plug>SVNLog')
  nmap <unique> <Leader>sl <Plug>SVNLog
endif
if !hasmapto('<Plug>SVNRevert')
  nmap <unique> <Leader>sq <Plug>SVNRevert
endif
if !hasmapto('<Plug>SVNReview')
  nmap <unique> <Leader>sw <Plug>SVNReview
endif
if !hasmapto('<Plug>SVNStatus')
  nmap <unique> <Leader>ss <Plug>SVNStatus
endif
if !hasmapto('<Plug>SVNInfo')
  nmap <unique> <Leader>si <Plug>SVNInfo
endif
if !hasmapto('<Plug>SVNPropedit')
  nmap <unique> <Leader>sp <Plug>SVNPropedit
endif
if !hasmapto('<Plug>SVNResolved')
  nmap <unique> <Leader>sr <Plug>SVNResolved
endif
if !hasmapto('<Plug>SVNUpdate')
  nmap <unique> <Leader>su <Plug>SVNUpdate
endif
if !hasmapto('<Plug>SVNVimDiff')
  nmap <unique> <Leader>sv <Plug>SVNVimDiff
endif

" Section: Menu items {{{1
silent! aunmenu Plugin.SVN
amenu <silent> &Plugin.SVN.&Add        <Plug>SVNAdd
amenu <silent> &Plugin.SVN.A&nnotate   <Plug>SVNAnnotate
amenu <silent> &Plugin.SVN.&Commit     <Plug>SVNCommit
amenu <silent> &Plugin.SVN.&Diff       <Plug>SVNDiff
amenu <silent> &Plugin.SVN.&Log        <Plug>SVNLog
amenu <silent> &Plugin.SVN.Revert      <Plug>SVNRevert
amenu <silent> &Plugin.SVN.&Review     <Plug>SVNReview
amenu <silent> &Plugin.SVN.&Status     <Plug>SVNStatus
amenu <silent> &Plugin.SVN.&Info       <Plug>SVNInfo
amenu <silent> &Plugin.SVN.&Propedit   <Plug>SVNPropedit
amenu <silent> &Plugin.SVN.&Resolved   <Plug>SVNResolved
amenu <silent> &Plugin.SVN.&Update     <Plug>SVNUpdate
amenu <silent> &Plugin.SVN.&VimDiff    <Plug>SVNVimDiff

" Section: Autocommands to restore vimdiff state {{{1
function! s:SVNVimDiffRestore(vimDiffBuff)
  let s:SVNCommandEditFileRunning = s:SVNCommandEditFileRunning + 1
  try
    if exists("s:vimDiffSourceBuffer")
      if a:vimDiffBuff == s:vimDiffSourceBuffer
        " Original file is being removed.
        unlet! s:vimDiffSourceBuffer
        unlet! s:vimDiffBufferCount
        unlet! s:vimDiffRestoreCmd
        unlet! s:vimDiffScratchList
      elseif match(s:vimDiffScratchList, '{' . a:vimDiffBuff . '}') >= 0
        let s:vimDiffScratchList = substitute(s:vimDiffScratchList, '{' . a:vimDiffBuff . '}', '', '')
        let s:vimDiffBufferCount = s:vimDiffBufferCount - 1
        if s:vimDiffBufferCount == 1 && exists('s:vimDiffRestoreCmd')
          " All scratch buffers are gone, reset the original.
          " Only restore if the source buffer is still in Diff mode

          let sourceWinNR=bufwinnr(s:vimDiffSourceBuffer)
          if sourceWinNR != -1
            " The buffer is visible in at least one window
            let currentWinNR = winnr()
            while winbufnr(sourceWinNR) != -1
              if winbufnr(sourceWinNR) == s:vimDiffSourceBuffer
                execute sourceWinNR . 'wincmd w'
                if getwinvar('', "&diff")
                  execute s:vimDiffRestoreCmd
                endif
              endif
              let sourceWinNR = sourceWinNR + 1
            endwhile
            execute currentWinNR . 'wincmd w'
          else
            " The buffer is hidden.  It must be visible in order to set the
            " diff option.
            let currentBufNR = bufnr('')
            execute "hide buffer" s:vimDiffSourceBuffer
            if getwinvar('', "&diff")
              execute s:vimDiffRestoreCmd
            endif
            execute "hide buffer" currentBufNR
          endif

          unlet s:vimDiffRestoreCmd
          unlet s:vimDiffSourceBuffer
          unlet s:vimDiffBufferCount
          unlet s:vimDiffScratchList
        elseif s:vimDiffBufferCount == 0
          " All buffers are gone.
          unlet s:vimDiffSourceBuffer
          unlet s:vimDiffBufferCount
          unlet s:vimDiffScratchList
        endif
      endif
    endif
  finally
    let s:SVNCommandEditFileRunning = s:SVNCommandEditFileRunning - 1
  endtry
endfunction

augroup SVNVimDiffRestore
  au!
  au BufUnload * call s:SVNVimDiffRestore(expand("<abuf>"))
augroup END

" Section: Optional auto-execution of SVNCommitDiff on a svn-commit file. {{{1
if s:SVNGetOption('SVNAutoCommitDiff',0)
    au BufNewFile,BufRead  svn-commit.* setf svn | set textwidth=80 | call s:SVNCommitDiff() | :0
    au BufUnload           svn-commit.* :qa!
endif

" Section: Optional activation of buffer management {{{1
"
"

if s:SVNGetOption('SVNCommandEnableBufferSetup', 0)
  call SVNEnableBufferSetup()
endif

" Section: Plugin completion {{{1

let loaded_svncommand=2
silent do SVNCommand User SVNPluginFinish
