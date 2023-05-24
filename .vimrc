"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let mapleader =" "

set nocompatible
set encoding=utf-8
colorscheme pablo

filetype plugin on
filetype indent plugin on

"------------------------------------------------------------
" These are highly recommended options.
"

" Enable syntax highlighting
syntax on

set nowrap
set lazyredraw

" Better command-line completion
set wildmenu
set wildmode=longest:full,full

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches 
set hlsearch

" Status line.
hi statusline ctermfg=0 ctermbg=white

let g:currentmode={
      \ 'n'      : 'Normal',
      \ 'no'     : 'N·Operator Pending',
      \ 'v'      : 'Visual',
      \ 'V'      : 'V·Line',
      \ "\<C-v>" : 'V·Block',
      \ 'i'      : 'Insert',
      \ 'R'      : 'Replace',
      \}

let g:defaultmode={
      \ 's'      : 'Select',
      \ 'S'      : 'S·Line',
      \ "\<C-s>" : 'S·Block',
      \ 'Rv'     : 'V·Replace',
      \ 'c'      : 'Command',
      \ 'cv'     : 'Vim Ex',
      \ 'ce'     : 'Ex',
      \ 'r'      : 'Prompt',
      \ 'rm'     : 'More',
      \ 'r?'     : 'Confirm',
      \ '!'      : 'Shell',
      \ 't'      : 'Terminal'
      \}

function GetNormal()
    if (mode() =~# '\v(n|no)')
        return "< " . g:currentmode[mode()] . " >"
    else
        return ""
    endif
endfunction

function GetInsert()
    if (mode() ==# 'i')
        return "< " . g:currentmode[mode()] . " >"
    else
        return ""
    endif
endfunction

function GetReplace()
    if (mode() ==# 'R')
        return "< " . g:currentmode[mode()] . " >"
    else
        return ""
    endif
endfunction

function GetVisual()
    if (mode() =~# '\v(v|V)' || mode() ==# "\<C-v>")
        return "< " . g:currentmode[mode()] . " >"
    else
        return ""
    endif
endfunction

function GetDefault()
    if empty(get(g:defaultmode,mode(),''))
        return ""
    else
        return "> " . g:defaultmode[mode()] . " <"
    endif
endfunction

hi NormalColor guifg=Black guibg=Green ctermbg=46 ctermfg=0
hi InsertColor guifg=Black guibg=Orange ctermbg=202 ctermfg=0
hi ReplaceColor guifg=Black guibg=maroon1 ctermbg=165 ctermfg=0
hi VisualColor guifg=Black guibg=Cyan ctermbg=51 ctermfg=0
hi ColorColumn ctermbg=8

set laststatus=2 " Always show status line.
"set noshowmode
set statusline=
set statusline+=%#NormalColor#%{GetNormal()}
set statusline+=%#InsertColor#%{GetInsert()}
set statusline+=%#ReplaceColor#%{GetReplace()}
set statusline+=%#VisualColor#%{GetVisual()}
set statusline+=%0*%{GetDefault()}                       " The current mode
set statusline+=%1*\ %<%F%m%r%h%w\                       " File path, modified, readonly, helpfile, preview
set statusline+=%3*│                                     " Separator
set statusline+=%2*\ %Y\                                 " FileType
set statusline+=%3*│                                     " Separator
set statusline+=%2*\ %{''.(&fenc!=''?&fenc:&enc).''}     " Encoding
set statusline+=\ (%{&ff})                               " FileFormat (dos/unix..)
set statusline+=%=                                       " Right Side
set statusline+=%2*\ col:\ %02v\                         " Colomn number
set statusline+=%3*│                                     " Separator
set statusline+=%1*\ ln:\ %02l/%L\ (%3p%%)\              " Line number / total lines, percentage of document

hi User1 ctermfg=007 ctermbg=239 guibg=#4e4e4e guifg=#adadad
hi User2 ctermfg=007 ctermbg=236 guibg=#303030 guifg=#adadad
hi User3 ctermfg=236 ctermbg=236 guibg=#303030 guifg=#303030
hi User4 ctermfg=239 ctermbg=239 guibg=#4e4e4e guifg=#4e4e4e

"------------------------------------------------------------
" Usability options
"

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase
set incsearch

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
"set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Enable use of the mouse for all modes
set mouse=a

" Set the command window height to 2 lines
set cmdheight=2

" Display line numbers on the left
set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>

" Add dictionary search
set complete-=k complete+=k

" Scroll off
set scrolloff=3

set splitright
set splitbelow

set hidden

"------------------------------------------------------------
" Indentation options
"

" Indentation settings for using 4 spaces instead of tabs.
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab

set relativenumber

"------------------------------------------------------------
" Latex suite requirements
"

set grepprg=grep\ -nH\ $*
let g:tex_flavor = "latex"

function! ClipboardYank()
  call system('xclip -i -selection clipboard', @@)
endfunction
function! ClipboardPaste()
  let @@ = system('xclip -o -selection clipboard')
endfunction

vnoremap <silent> y y:call ClipboardYank()<cr>
vnoremap <silent> d d:call ClipboardYank()<cr>
"nnoremap <silent> p :call ClipboardPaste()<cr>p

" Tweak for browsing
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_browse_split = 3
let g:netrw_altv = 1
let g:netrw_winsize = 25

" My mappings
inoremap jk <esc>l

nnoremap <leader>s [s1z=<c-o>
imap <c-s> <c-g>u<Esc>[s1z=`]a<c-g>u

"nnoremap <leader><CR> :w \| !%:p<CR>

nnoremap <leader>' viw<esc>a'<esc>bi'<esc>lel
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel
nnoremap <leader>( viw<esc>a)<esc>bi(<esc>lel
nnoremap <leader>{ viw<esc>a}<esc>bi{<esc>lel
vnoremap <leader>' <esc>`>a'<esc>`<i'<esc>`>l
vnoremap <leader>" <esc>`>a"<esc>`<i"<esc>`>l
vnoremap <leader>( <esc>`>a)<esc>`<i(<esc>`>l
vnoremap <leader>{ <esc>`>a}<esc>`<i{<esc>`>l

let g:comment_symbol = "#"
function! InsertComment()
    exe "normal! 0i" . g:comment_symbol
endfunction

nnoremap <leader>m :call InsertComment()<cr>
vnoremap <leader>m :call InsertComment()<cr>

function! NextTextObject(motion)
    let c = nr2char(getchar())
    exe "normal! /" . c . "\rv" . a:motion . c
endfunction

onoremap in :<c-u>call NextTextObject('i')<cr>
xnoremap in :<c-u>call NextTextObject('i')<cr>

onoremap an :<c-u>call NextTextObject('a')<cr>
xnoremap an :<c-u>call NextTextObject('a')<cr>

"Key re-map
nnoremap <Up>    gk
nnoremap <Down>  gj
nnoremap <Left>  :vertical resize -2<CR>
nnoremap <Right> :vertical resize +2<CR>

:au BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
\ |   exe "normal! g`\""
\ | endif
