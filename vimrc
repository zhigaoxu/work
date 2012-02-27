" Author:  Matthew Wozniski (mjw@drexel.edu)
"
" Feel free to do whatever you would like with this file as long as you give
" credit where credit is due.
"
" NOTE:
" If you're editing this in Vim and don't know how folding works, type zR to
" unfold everything.  And then read ":help folding".

" Stop behaving like vi; vim's enhancements are better.
set nocompatible

if version >= 603
    set helplang=cn
endif

" Skip the rest of this file unless we have +eval and Vim 7.0 or greater.
" With an older Vim, I'd rather just plain ol' vi-like features reminding me
" to upgrade.
if version >= 700
""" Settings
"""" Locations environment
set exrc

"""" Locations searched for scripts
let rtp = []                 " Add anything in a 'runtimes' subdirectory of
for dir in split(&rtp, ',')  " 'runtimepath' to 'runtimepath'
  let rtp += [ dir ]
  let rtp += split(globpath(dir, 'runtimes/*'), '\n')
endfor
for dir in split(&rtp, ',')
  let rtp += split(globpath(dir, 'runtimes/*/after'), '\n')
endfor
let &rtp = join(rtp, ',')
unlet rtp

"""" Mouse, Keyboard, Terminal
set mouse=a                 " Allow mouse use in normal and visual mode.
" set ttymouse=xterm2         " Most terminals send modern xterm mouse reporting
                            " but this isn't always detected in GNU Screen.
set timeoutlen=2000         " Wait 2 seconds before timing out a mapping
set ttimeoutlen=100         " and only 100 ms before timing out on a keypress.
set lazyredraw              " Avoid redrawing the screen mid-command.
set ttyscroll=3             " Prefer redraw to scrolling for more than 3 lines

" XXX Fix a vim bug: Only t_te, not t_op, gets sent when leaving an alt screen
exe "set t_te=" . &t_te . &t_op

""""" Titlebar
set title                   " Turn on titlebar support

" Set the to- and from-status-line sequences to match the xterm titlebar
" manipulation begin/end sequences for any terminal where
"   a) We don't know for a fact that these sequences would be wrong, and
"   b) the sequences were not already set in terminfo.
" NOTE: This would be nice to fix in terminfo, instead...
if &term !~? '^\v(linux|cons|vt)' && empty(&t_ts) && empty(&t_fs)
  exe "set t_ts=\<ESC>]2;"
  exe "set t_fs=\<C-G>"
endif

"  Titlebar string: hostname> ${PWD:s/^$HOME/~} || (view|vim) filename ([+]|)
let &titlestring  = hostname() . '> ' . '%{expand("%:p:~:h")}'
                \ . ' || %{&ft=~"^man"?"man":&ro?"view":"vim"} %f %m'

" When vim exits and the original title can't be restored, use this string:
if !empty($TITLE)
  " We know the last title set by the shell. (My zsh config exports this.)
  let &titleold = $TITLE
else
  "  Old title was probably something like: hostname> ${PWD:s/^$HOME/~}
  let &titleold = hostname() . '> ' . fnamemodify($PWD,':p:~:s?/$??')
endif

""""" Encoding/Multibyte
if has('multi_byte')        " If multibyte support is available and
  if &enc !~? 'utf-\=8'     " the current encoding is not Unicode,
    if empty(&tenc)         " default to
      let &tenc = &enc      " using the current encoding for terminal output
    endif                   " unless another terminal encoding was already set
  endif
  set encoding=utf-8        " set default encoding as UTF-8
  set termencoding=utf-8    " support Chinese display in rxvt-unicode
  set fileencodings=ucs-bom,utf-8,chinese,latin1 " fileconding detection order
  if has("win32")
    set fileencoding=chinese
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
    language messages zh_CN.utf-8
  else
    set fileencoding=utf-8
  endif
endif

"""" Moving Around/Editing
set nostartofline           " Avoid moving cursor to BOL when jumping around
"set whichwrap=b,s,h,l,<,>   " <BS> <Space> h l <Left> <Right> can change lines
set virtualedit=block       " Let cursor move past the last char in <C-v> mode
set scrolloff=3             " Keep 3 context lines above and below the cursor
" set backspace=2             " Allow backspacing over autoindent, EOL, and BOL
set backspace=eol,start,indent "Set backspace
set showmatch               " Briefly jump to a paren once it's balanced
set matchtime=2             " (for only .2 seconds).

"""" Searching and Patterns
set ignorecase              " Default to using case insensitive searches,
set smartcase               " unless uppercase letters are used in the regex.
set hlsearch                " Highlight searches by default.
set incsearch               " Incrementally search while typing a /regex

"""" Windows, Buffers
set noequalalways           " Don't keep resizing all windows to the same size
set hidden                  " Hide modified buffers when they are abandoned
set swb=useopen,usetab      " Allow changing tabs/windows for quickfix/:sb/etc
set splitright              " New windows open to the right of the current one

"""" Insert completion
set completeopt-=preview    " Don't show preview menu for tags.
set infercase               " Try to adjust insert completions for case.

"""" Folding
set foldmethod=syntax       " By default, use syntax to determine folds
set foldlevelstart=99       " All folds open by default

"""" Text Formatting
set formatoptions=q         " Format text with gq, but don't format as I type.
set formatoptions+=n        " gq recognizes numbered lists, and will try to
set formatoptions+=1        " break before, not after, a 1 letter word

"""" Display
set number                  " Display line numbers
set numberwidth=1           " using only 1 column (and 1 space) while possible

if &enc =~ '^u\(tf\|cs\)'   " When running in a Unicode environment,
  " set list                  " visually represent certain invisible characters:
  let s:arr = nr2char(9655) " using U+25B7 (▷) for an arrow, and
  let s:dot = nr2char(8901) " using U+22C5 (⋅) for a very light dot,
  " display tabs as an arrow followed by some dots (▷⋅⋅⋅⋅⋅⋅⋅),
  exe "set listchars=tab:"    . s:arr . s:dot
  " and display trailing and non-breaking spaces as U+22C5 (⋅).
  exe "set listchars+=trail:" . s:dot
  exe "set listchars+=nbsp:"  . s:dot
  " Also show an arrow+space (↪ ) at the beginning of any wrapped long lines?
  " I don't like this, but I probably would if I didn't use line numbers.
  " let &sbr=nr2char(8618).' '
endif

"""" Messages, Info, Status
set vb t_vb=                " Disable all bells.  I hate ringing/flashing.
set confirm                 " Y-N-C prompt if closing with unsaved changes.
set showcmd                 " Show incomplete normal mode commands as I type.
set report=0                " : commands always print changed line count.
set shortmess+=a            " Use [+]/[RO]/[w] for modified/readonly/written.
set ruler                   " Show some info, even without statuslines.
set laststatus=2            " Always show statusline, even if only 1 window.

let &statusline = '%<%f%{&mod?"[+]":""}%r%'
 \ . '{&fenc !~ "^$\\|utf-8" || &bomb ? "[".&fenc.(&bomb?"-bom":"")."]" : ""}'
 \ . '%='
 \ . '%{exists("actual_curbuf")&&bufnr("")==actual_curbuf?CountMatches(1):""}'
 \ . '%15.(%l,%c%V %P%)'

"""" Tabs/Indent Levels
set autoindent              " Do dumb autoindentation when no filetype is set
set tabstop=4               " Real tab characters are 4 spaces wide,
set shiftwidth=4            " but an indent level is 4 spaces wide.
set softtabstop=4           " <BS> over an autoindent deletes both spaces.
set expandtab               " Use spaces, not tabs, for autoindent/tab key.

"""" Tags
set tags=./tags;/home       " Tags can be in ./tags, ../tags, ..., /home/tags.
set showfulltag             " Show more information while completing tags.
if has("win32")
    set path=.
    set tag=tags,
else
    set tag=tags,../tags,../../tags,~/.vim/tags/libc.tags
    " set autochdir
    "set tag=tags,~/.vim/tags/libc.tags,~/.vim/tags/libminigui.tags,
    "set path =.,./include,/usr/include/,/usr/include/linux/,/usr/include/sys,
endif
" auto load cscope.out
if has("cscope")
    if has("win32")
        set csprg=e:\cygwin\root\bin\mlcscope.exe
    endif
    set cscopetag               " When using :tag, <C-]>, or "vim -t", try cscope:
    set cscopetagorder=0        " try ":cscope find g foo" and then ":tselect foo"
    set csto=0
    set cspc=5
    set cst
    set nocsverb
    if filereadable("./cscope.out") 
        execute 'cscope add ./cscope.out'
    elsei filereadable("../cscope.out") 
        execute 'cscope add ../cscope.out'
    elsei filereadable("../../cscope.out") 
        execute 'cscope add ../../cscope.out'
    endif
endif
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

"""" Reading/Writing
set noautowrite             " Never write a file unless I request it.
set noautowriteall          " NEVER.
set noautoread              " Don't automatically re-read changed files.
set modeline                " Allow vim options to be embedded in files;
set modelines=5             " they must be within the first or last 5 lines.
set ffs=unix,dos,mac        " Try recognizing dos, unix, and mac line endings.

"""" Backups/Swap Files
" Make sure that the directory where we want to put swap/backup files exists.
if ! len(glob("~/.backup/"))
  " echomsg "Backup directory ~/.backup doesn't exist!"
  call mkdir("~/.backup/")
endif

set writebackup             " Make a backup of the original file when writing
set backup                  " and don't delete it after a succesful write.
set backupskip=             " There are no files that shouldn't be backed up.
set updatetime=2000         " Write swap files after 2 seconds of inactivity.
set backupext=~             " Backup for "file" is "file~"
set backupdir^=~/.backup    " Backups are written to ~/.backup/ if possible.
set directory^=~/.backup//  " Swap files are also written to ~/.backup, too.
" ^ Here be magic! Quoth the help:
" For Unix and Win32, if a directory ends in two path separators "//" or "\\",
" the swap file name will be built from the complete path to the file with all
" path separators substituted to percent '%' signs.  This will ensure file
" name uniqueness in the preserve directory.
if version >= 703
  set undofile
  set undolevels=200
  if ! isdirectory("/tmp/vim_undo/")
    call mkdir("/tmp/vim_undo/")
  endif
  set undodir=/tmp/vim_undo/
endif


"""" Command Line
set history=1000            " Keep a very long command-line history.
set wildmenu                " Menu completion in command mode on <Tab>
set wildmode=full           " <Tab> cycles between all matching choices.
set wcm=<C-Z>               " Ctrl-Z in a mapping acts like <Tab> on cmdline
source $VIMRUNTIME/menu.vim " Load menus (this would be done anyway in gvim)
" <F4> triggers the menus, even in terminal vim.
" map <F4> :emenu <C-Z>

"""" Per-Filetype Scripts
" NOTE: These define autocmds, so they should come before any other autocmds.
"       That way, a later autocmd can override the result of one defined here.
filetype on                 " Enable filetype detection,
filetype indent on          " use filetype-specific indenting where available,
filetype plugin on          " also allow for filetype-specific plugins,
syntax on                   " and turn on per-filetype syntax highlighting.

"""" Sessions
set sessionoptions=buffers,curdir,help,tabpages

""" Plugin Settings
let lisp_rainbow=1          " Color parentheses by depth in LISP files.
let is_posix=1              " I don't use systems where /bin/sh isn't POSIX.
let bufExplorerFindActive=0 " Disable emulated 'switchbuf' from BufExplorer
let vim_indent_cont=4       " Spaces to add for vimscript continuation lines
let no_buffers_menu=1       " Disable gvim 'Buffers' menu
let surround_indent=1       " Automatically reindent text surround.vim actions

" Disable FuzzyFinder's MRU Command completion, since it breaks :debug
let FuzzyFinderOptions = { 'MruCmd' : { 'mode_available' : 0 } }

" Turn off automatic omnicompletion for C++, I'll ask for it if I want it.
let [ OmniCpp_MayCompleteDot, OmniCpp_MayCompleteArrow ] = [ 0, 0 ]

" When using a gvim-only colorscheme in terminal vim with CSApprox
"   - Disable the bold and italic attributes completely
"   - Use the color specified by 'guisp' as the foreground color.
let g:CSApprox_attr_map = { 'bold' : '', 'italic' : '', 'sp' : 'fg' }

" Enable syntax folding in perl scripts.
let [ g:perl_fold, g:perl_fold_blocks ] = [ 1, 1 ]

" for BASH_SUPPORT
let g:BASH_AuthorName   = 'Zeroman Yang'     
let g:BASH_AuthorRef    = 'Zeroman'                         
let g:BASH_Email        = '51feel@gmail.com'            
let g:BASH_Company      = 'BLT.Ltd'    

" for doxygen
let g:DoxygenToolkit_authorName="Zeroman Yang <51feel@gmail.com>" 
let g:DoxygenToolkit_versionTag="0.01"
let g:DoxygenToolkit_commentType = "C++" 

" for grep.vim
nnoremap <silent> <F6> :Rgrep<CR>
let Grep_Default_Filelist = '*.cpp *.c *.h *.CPP *.H'
if has("win32")
    let Grep_Path = 'd:\\Vim\\GnuWin32\\bin\\grep.exe'
    let Fgrep_Path = 'd:\\Vim\GnuWin32\\bin\\fgrep.exe'
    let Egrep_Path = 'd:\\Vim\\GnuWin32\\bin\\egrep.exe'
    let Grep_Find_Path = 'd:\\Vim\\GnuWin32\\bin\\find.exe'
    let Grep_Xargs_Path = 'd:\\Vim\\GnuWin32\\bin\\xargs.exe'
    "let Grep_Default_Options = 
    let Grep_OpenQuickfixWindow = 1
    " let Grep_Cygwin_Find = 1
endif

" for showmarks
let g:showmarks_hlline_lower=1
let g:showmarks_textlower=" "
let g:showmarks_include="abcdefghijklmnopqrstuvwxyz"

" for neocomplcache
let g:neocomplcache_enable_at_startup=1
let g:neocomplcache_enable_auto_select=1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_min_syntax_length = 3

" for plugin Align
let g:Align_xstrlen = 3

" set MRU
map <F7> <C-c>:Mru <cr>
let MRU_Max_Entries = 2000
let MRU_Auto_Close = 1
let MRU_Add_Menu = 0

" for EnhComment
let g:EnhCommentifyMultiPartBlocks = 'yes'
let g:EnhCommentifyPretty = 'Yes'
let g:EnhCommentifyRespectIndent = 'Yes'

" for command-t
set wildignore+=*.o,*.arm,*.html,*.obj,.git,.svn,*.d


" for errormarker
let errormarker_disablemappings = 1
nmap <silent> <unique> <Leader>em :ErrorAtCursor<CR>

" for vcscommand
let VCSCommandMapPrefix='<Leader>v'

" for taglist
nnoremap <silent> <F3> :TlistToggle<CR>

" for NerdComment
let NERDSpaceDelims = 1
let NERDCompactSexyComs = 1
nmap <F4> <plug>NERDCommenterInvert
vmap <F4> <plug>NERDCommenterMinimal
map <S-F4> <plug>NERDCommenterUncomment

" for autopair"
let g:AutoPairs = {'[':']', '{':'}',"'":"'",'"':'"'}

""" Autocommands
if has("autocmd")
  augroup vimrcEx
  au!
  " In plain-text files and svn commit buffers, wrap automatically at 78 chars
  au FileType text,svn setlocal tw=78 fo+=t

  " Try to jump to the last spot the cursor was at in a file when reading it.
  au BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif

  " Use :make to syntax check a perl script.
  au FileType perl set makeprg=perl\ -c\ %\ $* errorformat=%f:%l:%m

  " Use :make to compile C, even without a makefile
  au FileType c   if glob('[Mm]akefile') == "" | let &mp="gcc -o %< %" | endif

  " Use :make to compile C++, too
  au FileType cpp if glob('[Mm]akefile') == "" | let &mp="g++ -o %< %" | endif

  " Insert Vim-version as X-Editor in mail headers
  au FileType mail sil 1  | call search("^$")
               \ | sil put! ='X-Editor: Vim-' . Version()

  au Filetype * let &l:ofu = (len(&ofu) ? &ofu : 'syntaxcomplete#Complete')

  au BufRead,BufNewFile ~/.zsh/.zfunctions/[^.]* setf zsh

  au BufWritePost ~/.Xdefaults redraw|echo system('xrdb '.expand('<amatch>'))

  au BufNewFile *.h,*.c,*.cpp         :DoxAuthor
  au BufNewFile *.py                  call NewPyFile()
  " au BufNewFile *.sh                  call NewShFile()
  au BufNewFile,BufRead *.t2t set ft=txt2tags
  au FileType c,cpp set efm=%f%l:\ %m,In\ file\ included\ from\ %f:%l:%c:,%f:%l:%c:\ %m
  " au BufWritePost,FileWritePost   *.h,*.c,*.cpp    call AutoTag()
  " au BufWritePre *vimrc,*.vim         call Timestamp('"')
  " au BufWritePre .exrc                call Timestamp('"')
  " au BufWritePre *.h,*.c              call Timestamp('//')
  " au BufWritePre Makefile             call Timestamp('#')



  " au BufRead,BufNewFile * nested if &l:filetype =~# '^\(c\|cpp\)$'
  " \ | let &l:ft .= ".doxygen.glib.gobject.gdk.gdkpixbuf.gtk.gimp"
  " \ | endif

  augroup END
endif

""" Colorscheme
if $COLORSCHEME == "light" && (&t_Co > 16 || has('gui_running'))
  colorscheme autumnleaf  " 256 color light scheme
elseif $COLORSCHEME == "light"
  colorscheme biogoo      " 16 color light scheme
elseif &t_Co > 16 || has('gui_running')
  " colorscheme brookstream " 256 color dark scheme
  colorscheme blacksea " 256 color dark scheme
else
  colorscheme torte       " 16 color dark scheme
endif
hi Pmenu guibg=#010101 guifg=#ffccff

""" Key Mappings

" Make [[ and ]] work even if the { is not in the first column
nnoremap <silent> [[ :call search('^\S\@=.*{$', 'besW')<CR>
nnoremap <silent> ]] :call search('^\S\@=.*{$', 'esW')<CR>
onoremap <expr> [[ (search('^\S\@=.*{$', 'ebsW') && (setpos("''", getpos('.'))
                  \ <bar><bar> 1) ? "''" : "\<ESC>")
onoremap <expr> ]] (search('^\S\@=.*{$', 'esW') && (setpos("''", getpos('.'))
                  \ <bar><bar> 1) ? "''" : "\<ESC>")

" Use \sq to squeeze blank lines with :Squeeze, defined below
nnoremap <leader>sq :Squeeze<CR>

" In visual mode, \box draws a box around the highlighted text.
vnoremap <leader>box <ESC>:call <SID>BoxIn()<CR>gvlolo

" I'm sorry.  :(  Some Emacs bindings for the command window
cnoremap <C-A>     <Home>
cnoremap <ESC>b    <S-Left>
cnoremap <ESC>f    <S-Right>
cnoremap <ESC><BS> <C-W>

" Extra functionality for some existing commands:
" <C-6> switches back to the alternate file and the correct column in the line.
nnoremap <C-6> <C-6>`"

" CTRL-g shows filename and buffer number, too.
nnoremap <C-g> 2<C-g>

" <C-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :nohl<CR><C-l>

" In normal/insert mode, ar inserts spaces to right align to &tw or 80 chars
nnoremap <leader>ar :AlignRight<CR>

" In normal/insert mode, ac center aligns the text after it to &tw or 80 chars
nnoremap <leader>ac :center<CR>

" Zoom in on the current window with <leader>z
nmap <leader>z <Plug>ZoomWin

" F10 toggles highlighting lines that are too long
nnoremap <F10> :call <SID>ToggleTooLongHL()<CR>

" F11 toggles line numbering
nnoremap <silent> <F11> :set number! <bar> set number?<CR>

" F12 toggles search term highlighting
nnoremap <silent> <F12> :set hlsearch! <bar> set hlsearch?<CR>

" Q formats paragraphs, instead of entering ex mode
noremap Q gq

nnoremap <silent> gqJ :call Exe#ExeWithOpts('norm! gqj', { 'tw' : 2147483647 })<CR>

" <space> toggles folds opened and closed
nnoremap <space> za

" <space> in visual mode creates a fold over the marked range
vnoremap <space> zf

" Pressing an 'enter visual mode' key while in visual mode changes mode.
vmap <C-V> <ESC>`<<C-v>`>
vmap V     <ESC>`<V`>
vmap v     <ESC>`<v`>

" Make { and } in visual mode stay in the current column unless 'sol' is set.
vnoremap <expr> { line("'{") . 'G'
vnoremap <expr> } line("'}") . 'G'

" <leader>bsd inserts BSD copyright notice
nnoremap <leader>bsd :BSD<CR>

" <leader>sk inserts skeleton for the current filetype
nnoremap <leader>sk :Skel<CR>

" Insert a modeline on the last line with <leader>ml
nmap <leader>ml :$put =ModelineStub()<CR>

" Tapping C-W twice brings me to previous window, not next.
nnoremap <C-w><C-w> :winc p<CR>

" Get old behavior with <C-w><C-e>
nnoremap <C-w><C-e> :winc w<CR>

" Y behaves like D rather than like dd
nnoremap Y y$

" Tab configuration
nmap T :tabedit 
map <M-1> <ESC><ESC>:tabnext<cr>
map <M-2> <ESC><ESC>:tabprevious<cr>
imap <M-1> <ESC><ESC>:tabnext<cr>
imap <M-2> <ESC><ESC>:tabprevious<cr>

" Fast cmd
map <leader>qq :qa<cr>
map <leader>qw :wqa<cr>
map <leader>set :tabedit ~/.vimrc<cr>
map <leader>sh :tabedit ~/.bashrc<cr>
map <M-v> "+p
map <M-c> "+y
map <M-t> d

" Fast remove highlight search
nmap <silent> <leader><cr> :noh<cr>

" For Some shorcut keys
map   <F2> <ESC>:w<cr>
imap  <F2> <ESC>:w<cr>
nmap <F5> <ESC>:Dox<cr>
imap <F5> <ESC>:Dox<cr>
nmap <F8> <ESC>:call Do_make('')<cr>
nmap <M-F8> <ESC>:call Do_make('arm')<cr>
nmap <M-`> <C-c>:bd<cr>

""" Abbreviations
function! EatChar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunc

iabbr _me Matthew Wozniski (mjw@drexel.edu)<C-R>=EatChar('\s')<CR>
iabbr #i< #include <><left><C-R>=EatChar('\s')<CR>
iabbr #i" #include ""<left><C-R>=EatChar('\s')<CR>
iabbr _t  <C-R>=strftime("%H:%M:%S")<CR><C-R>=EatChar('\s')<CR>
iabbr _d  <C-R>=strftime("%a, %d %b %Y")<CR><C-R>=EatChar('\s')<CR>
iabbr _dt <C-R>=strftime("%a, %d %b %Y %H:%M:%S %z")<CR><C-R>=EatChar('\s')<CR>

""" Cute functions
" Squeeze blank lines with :Squeeze
command! -nargs=0 Squeeze g/^\s*$/,/\S/-j

function! s:ToggleTooLongHL()
  if exists('*matchadd')
    if ! exists("w:TooLongMatchNr")
      let last = (&tw <= 0 ? 80 : &tw)
      let w:TooLongMatchNr = matchadd('ErrorMsg', '.\%>' . (last+1) . 'v', 0)
      echo "   Long Line Highlight"
    else
      call matchdelete(w:TooLongMatchNr)
      unlet w:TooLongMatchNr
      echo "No Long Line Highlight"
    endif
  endif
endfunction

function! s:BoxIn()
  let mode = visualmode()
  if mode == ""
    return
  endif
  let vesave = &ve
  let &ve = "all"
  exe "norm! ix\<BS>\<ESC>"
  if line("'<") > line("'>")
    undoj | exe "norm! gvo\<ESC>"
  endif
  if mode != "\<C-v>"
    let len = max(map(range(line("'<"), line("'>")), "virtcol([v:val, '$'])"))
    undoj | exe "norm! gv\<C-v>o0o0" . (len-2?string(len-2):'') . "l\<esc>"
  endif
  let diff = virtcol("'>") - virtcol("'<")
  if diff < 0
    let diff = -diff
  endif
  let horizm = "+" . repeat('-', diff+1) . "+"
  if mode == "\<C-v>"
    undoj | exe "norm! `<O".horizm."\<ESC>"
  else
    undoj | exe line("'<")."put! ='".horizm."'" | norm! `<k
  endif
  undoj | exe "norm! yygvA|\<ESC>gvI|\<ESC>`>p"
  let &ve = vesave
endfunction

function! ModelineStub()
  let fmt = ' vim: set ts=%d sts=%d sw=%d %s: '
  let x = printf(&cms, printf(fmt, &ts, &sts, &sw, (&et?"et":"noet")))
  return substitute(substitute(x, '\ \+', ' ', 'g'), ' $', '', '')
endfunction

" Replace tabs with spaces in a string, preserving alignment.
function! Retab(string)
  let rv = ''
  let i = 0

  for char in split(a:string, '\zs')
    if char == "\t"
      let rv .= repeat(' ', &ts - i)
      let i = 0
    else
      let rv .= char
      let i = (i + 1) % &ts
    endif
  endfor

  return rv
endfunction

" Right align the portion of the current line to the right of the cursor.
" If an optional argument is given, it is used as the width to align to,
" otherwise textwidth is used if set, otherwise 80 is used.
function! AlignRight(...)
  if getline('.') =~ '^\s*$'
    call setline('.', '')
  else
    let line = Retab(getline('.'))

    let prefix = matchstr(line, '.*\%' . virtcol('.') . 'v')
    let suffix = matchstr(line, '\%' . virtcol('.') . 'v.*')

    let prefix = substitute(prefix, '\s*$', '', '')
    let suffix = substitute(suffix, '^\s*', '', '')

    let len  = len(substitute(prefix, '.', 'x', 'g'))
    let len += len(substitute(suffix, '.', 'x', 'g'))

    let width  = (a:0 == 1 ? a:1 : (&tw <= 0 ? 80 : &tw))

    let spaces = width - len

    call setline('.', prefix . repeat(' ', spaces) . suffix)
  endif
endfunction
com! -nargs=? AlignRight :call AlignRight(<f-args>)

function! Version()
  let i=1
  while has("patch" . i)
    let i+=1
  endwhile
  return v:version / 100 . "." . v:version % 100 . "." . (i-1)
endfunction
command! Version :echo Version()

command! -nargs=1 -complete=dir Rename saveas <args> | call delete(expand("#"))

""" Self define functions
function! NewPyFile() 
    exec "normal ggi"."#!/usr/bin/env python\n# -*- coding: utf-8 -*-\n"
endfunction 

function! NewShFile() 
    exec "normal ggi"."#!/bin/sh\n\n"
endfunction 

function! AutoTag() 
    if filereadable("./tags")
        if has("win32")
            silent  exec "!e:\cygwin\root\bin\ctags -a \"%\" > /dev/null"
        else
            silent  exec "!ctags -a \"%\" > /dev/null"
        endif
        " :redraw
    endif
endfunction 

function! Timestamp(comment)
  if (a:comment == '')
    return
  endif
  let pattern = '\('.a:comment.' Last Change:\s\+\)\d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2}:\d\{2}'
  let row = search('\%^\_.\{-}\(^\zs' . pattern . '\)', 'n')
  let now = strftime('%Y-%m-%d %H:%M:%S', localtime())
  if row != 0
    let new_row_str =substitute(getline(row), '^' . pattern , '\1', '') . now
    call setline(row, new_row_str)
  else
    normal m'
    silent! :1
    normal O
    let new_row_str = a:comment . " Last Change: " . now
    call setline(1, new_row_str)
    normal ''
  endif
endfunction


function! AutoChangeTheme()
  let col_tags = globpath("d:/vim/vimfiles/colors,", "*.vim")
  let col_files = split(col_tags, "\n", "\zs")
  let col_num = len(col_files)
  for i in range(0,col_num)
    " echo matchstr(col_files[i],
  endfo
  " source d:\vim\vimfiles\colors\adam.vim
  unlet col_files
  unlet col_num
endfunction

function! Do_splint()
  let makeprg_saved='"'.&makeprg.'"'
  exe	":cclose"
  :setlocal makeprg=splint
  exe "make \"%\" -nullpass -warnposix +matchanyintegral"
  exe	"setlocal makeprg=".makeprg_saved
  :redraw!
  exe	":botright cwindow"
endfunction

function! Do_make(arch)
  if filereadable("Makefile")
    exe	":cclose"
    if (a:arch == 'arm')
      " exe "make ARCH=arm"
      :set makeprg="make ARCH=arm"
    else
      :set makeprg=make
    endif
    exe ":make"
    :redraw!
    exe	":botright cwindow"
  else
    exe "!gcc % -g"
    :redraw!
    exe	":botright cwindow"
  endif
endfunction

function! GtkTags()
  " set tag=tags,~/.vim/tags/libc.tags,~/.vim/tags/libgtk.tags,
  " set tag=tags,~/.vim/tags/libc.tags,~/.vim/tags/libgtk.tags,
  " execute 'cscope add ~/.vim/tags/libgtk.out'
  set tag=tags,
endfunction

""" Some help
" :%s/^[0-9]\{1,4}//g  删除首行的4个数字。
" :%s/^[0-9]\{1,}//g  删除首行的数字。
" :%s/78 \(\x\{4}\) \(\x\{2}\)/{0x\1, 0x\2, 0, 0},/g 

"" Stop skipping here
endif
"" vim:fdm=expr:fdl=0
"" vim:fde=getline(v\:lnum)=~'^""'?'>'.(matchend(getline(v\:lnum),'""*')-2)\:'='
