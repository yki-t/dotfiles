" OSの判定
if has('win32')
    let ostype = 'Win32'
    let dsp = '\'
elseif has('mac')
    let ostype = 'Mac'
    let dsp = '/'
else
    let ostype = system('uname')
    let dsp = '/'
endif

"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

if ostype == 'Win'
    set runtimepath+=$HOME\.cache\dein\repos\github.com\Shougo\dein.vim
else
    set runtimepath+=$HOME/.cache/dein/repos/github.com/Shougo/dein.vim
endif

if dein#load_state($HOME.dsp.'.cache'.dsp.'dein')
  call dein#begin($HOME.dsp.'.cache'.dsp.'dein')
  call dein#add($HOME.dsp.'.cache'.dsp.'dein'.dsp.'repos'.dsp.'github.com'.dsp.'Shougo'.dsp.'dein.vim')

  " Add or remove your plugins here.
  call dein#add('Shougo'.dsp.'neosnippet.vim')
  call dein#add('Shougo'.dsp.'neosnippet-snippets')

  " You can specify revision'.dsp.'branch'.dsp.'tag.
  call dein#add('Shougo'.dsp.'vimshell', { 'rev': '3787e5' })

  call dein#end()
  call dein#save_state()
endif


filetype plugin indent on
syntax enable
if dein#check_install()
  call dein#install()
endif
"End dein Scripts-------------------------



"
set modelines=0        " CVE-2007-2438

" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
set nocompatible    " Use Vim defaults instead of 100% vi compatibility
set backspace=2        " more powerful backspacing

if ostype == 'Win'
    " Don't write backup file if vim is being called by "crontab -e"
    au BufWrite \private\tmp\crontab.* set nowritebackup nobackup
    " Don't write backup file if vim is being called by "chpass"
    au BufWrite \private\etc\pw.* set nowritebackup nobackup
else
    " Don't write backup file if vim is being called by "crontab -e"
    au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
    " Don't write backup file if vim is being called by "chpass"
    au BufWrite /private/etc/pw.* set nowritebackup nobackup
endif

if has("syntax")
    syntax on
endif

set number
set expandtab
set tabstop=4
set ambiwidth=double
set shiftwidth=4 
set smartindent
set wrap
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set nrformats-=octal
set hidden
set history=50
set virtualedit=block
set whichwrap=b,s,[,],<,>
set backspace=indent,eol,start
set wildmenu

set foldmethod=marker
set ignorecase
set mouse=a

colorscheme molokai
set t_Co=256

" ###########################################################
" 補完の設定
" ###########################################################
highlight Pmenu ctermbg=4
highlight PmenuSel ctermbg=1
highlight PMenuSbar ctermbg=4

set completeopt=menuone
set completeopt=menuone
let g:rsenseUseOmniFunc = 1
let g:auto_ctags = 1
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_enable_camel_case_completion  =  1
let g:neocomplcache_enable_auto_select = 1
let g:neocomplcache_max_list = 20
let g:neocomplcache_min_syntax_length = 3
autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.ruby = '[^.*\t]\.\w*\|\h\w*::'

if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'


" ###########################################################
" キーマッピング
" ###########################################################
" dein update
nmap du :call dein#update()<cr>
" Plugin shortcut
nnoremap c <Nop>
nmap cf :VimFiler
nmap cs :VimShell

inoremap { {}<Left>
inoremap ( ()<Left>
inoremap [ []<LEFT>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>

" 検索結果を画面の中央に
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz


nnoremap ; :
nnoremap : ;
nnoremap x "_x

" 行移動を表示行での移動に
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

" 画面分割系統
nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap sH <C-w>H
nnoremap sn gt
nnoremap sp gT
nnoremap sr <C-w>r
nnoremap s= <C-w>=
nnoremap sw <C-w>w
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap sN :<C-u>bn<CR>
nnoremap sP :<C-u>bp<CR>
nnoremap st :<C-u>tabnew<CR>
nnoremap sT :<C-u>Unite tab<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap sq :<C-u>q<CR>
nnoremap sQ :<C-u>bd<CR>
nnoremap sb :<C-u>Unite buffer_tab -buffer-name=file<CR>
nnoremap sB :<C-u>Unite buffer -buffer-name=file<CR>

" 廃止
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
nnoremap Q gq

" Paste Setting
if &term =~ "xterm"
    let &t_ti .= "\e[?2004h"
    let &t_te .= "\e[?2004l"
    let &pastetoggle = "\e[201~"
    function XTermPasteBegin(ret)
    set paste
    return a:ret
    endfunction
    noremap <special> <expr> <Esc>[200~ XTermPasteBegin("0i")
    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
    cnoremap <special> <Esc>[200~ <nop>
    cnoremap <special> <Esc>[201~ <nop>
endif

" call submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
" call submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
" call submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
" call submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
" call submode#map('bufmove', 'n', '', '>', '<C-w>>')
" call submode#map('bufmove', 'n', '', '<', '<C-w><')
" call submode#map('bufmove', 'n', '', '+', '<C-w>+')
" call submode#map('bufmove', 'n', '', '-', '<C-w>-')


