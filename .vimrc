if !1 | finish | endif

"------------------------------------
" OSの判定
"------------------------------------
let OSTYPE = system('uname')

"------------------------------------
" dein
"------------------------------------
"{{{
"dein Scripts-----------------------------
if &compatible
    set nocompatible               " Be iMproved
endif
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim
if dein#load_state('~/.cache/dein/')
    call dein#begin('~/.cache/dein/')
    call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')
    let g:rc_dir    = expand('~/.vim/rc')
    let s:toml      = g:rc_dir . '/dein.toml'
    let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'
    call dein#load_toml(s:toml,      {'lazy': 0})
    call dein#load_toml(s:lazy_toml, {'lazy': 1})
    call dein#end()
    call dein#save_state()
endif
filetype plugin indent on
syntax enable
if dein#check_install()
  call dein#install()
endif
"End dein Scripts-------------------------
" }}}

"------------------------------------
" デフォルトの人たち
"------------------------------------
"{{{
set modelines=0
set nocompatible
set backspace=2
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
au BufWrite /private/etc/pw.* set nowritebackup nobackup
"}}}

"------------------------------------
" 補完の設定
"------------------------------------
"{{{
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
"}}}

"------------------------------------
" ペーストができるように
"------------------------------------
"{{{
if &term =~ "xterm"
    let &t_ti .= "\e[?2004h"
    let &t_te .= "\e[?2004l"
    let &pastetoggle = "\e[201~"
    function! XTermPasteBegin(ret)
        set p;ste
        return a:ret
    endfunction
    noremap <special> <expr> <Esc>[200~ XTermPasteBegin("0i")
    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
    cnoremap <special> <Esc>[200~ <nop>
    cnoremap <special> <Esc>[201~ <nop>
endif
"}}}

"------------------------------------
" キーマッピング
"------------------------------------
"{{{
noremap vf :VimFiler -auto-cd<CR>
nnoremap VS :VimShellInteractive zsh<CR>
noremap DU :call dein#update()<CR>
map <Space> <Plug>(operator-replace)

noremap te :LLPStartPreview<CR>

"inoremap { {}<Left>
"inoremap ( ()<Left>
"inoremap [ []<LEFT>
"inoremap < <><LEFT>
"inoremap ' ''<LEFT>
"inoremap " ""<LEFT>
" ==でインデント調整
nnoremap == gg=G''

" 検索結果を画面の中央に
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz


" nnoremap ; :
" nnoremap : ;
nnoremap x "_x

" 行移動を表示行での移動に
nnoremap j gj
nnoremap gj j
nnoremap k gk
nnoremap gk k
nnoremap <Up> gk
nnoremap <Down> j
vnoremap j gj
vnoremap k gk
vnoremap gj j
vnoremap gk k
vnoremap <Up> gk
vnoremap <Down> j

" 廃止
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
nnoremap Q gq
"}}}

"------------------------------------
" vimshell起動時、Ctrl-yで履歴をヤンク
"------------------------------------
" {{{ " after/ftplugin/unite.vim
"let s:context = unite#get_context()
"if s:context.buffer_name ==# 'completion'
"    inoremap <buffer> <expr> <C-y> unite#do_action('insert')
"endif
" }}}

"------------------------------------
" 画面分割(キーマッピング)
"------------------------------------
"{{{
noremap vs :vs<CR>
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
call submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
call submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
call submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
call submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
call submode#map('bufmove', 'n', '', '>', '<C-w>>')
call submode#map('bufmove', 'n', '', '<', '<C-w><')
call submode#map('bufmove', 'n', '', '+', '<C-w>+')
call submode#map('bufmove', 'n', '', '-', '<C-w>-')
"}}}

"------------------------------------
" ノーマルモード移行時に自動で英数IMEに切り替え→Macのみ
"------------------------------------
"{{{
"if OSTYPE == "Darwin\n"
"    set ttimeoutlen=1
"    let g:imeoff = 'osascript -e "tell application \"System Events\" to key code 102"'
"    augroup MyIMEGroup
"        autocmd!
"        autocmd InsertLeave * :call system(g:imeoff)
"    augroup END
"    inoremap <silent> <ESC> <ESC>:call system(g:imeoff)<CR>
"endif
"}}}

"------------------------------------
" その他の設定
"------------------------------------
"{{{
if has("syntax")
    syntax on
endif

" VimFilerで自動cd
let g:vimfiler_enable_auto_cd = 1

" Rainbow Parentheses Improved
let g:rainbow_active = 1

" 改行時の自動コメント化を無効に
augroup auto_comment_off
    autocmd!
    autocmd BufEnter * setlocal formatoptions-=r
    autocmd BufEnter * setlocal formatoptions-=o
augroup END

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

hi Comment ctermfg=cyan
vnoremap * "zy:let @/ = @z<CR>

if OSTYPE == "Linux\n"
    set clipboard+=unnamedplus
else
    set clipboard+=unnamed
endif


"w!!でsudo 保存
cabbr w!! w !sudo tee > /dev/null %
" swp 生成先を変更
"set directory=~/.vim/tmp
set noswapfile

hi Normal ctermbg=NONE guibg=NONE
hi NonText ctermbg=NONE guibg=NONE
"}}}

"------------------------------------
" プログラム言語共通の設定
"------------------------------------
" コンパイルエラー時の処理
"au QuickFixCmdPost * nested cwindow | redraw! 

"------------------------------------
" JAVA-SCRIPT系の設定
"------------------------------------
" {{{
" 保存時にコンパイル
au BufWritePost *.coffee silent make -b
au QuickFixCmdPost * nested cwindow | redraw! 
" リアルタイムプレビュー
" au BufWritePost *.coffee :CoffeeWatch vert
function! EnableJavascript()
  " Setup used libraries
  let g:used_javascript_libs = 'jquery,underscore,react,flux,jasmine,d3'
  let b:javascript_lib_use_jquery = 1
  let b:javascript_lib_use_underscore = 1
  let b:javascript_lib_use_react = 1
  let b:javascript_lib_use_flux = 0
  let b:javascript_lib_use_jasmine = 0
  let b:javascript_lib_use_d3 = 0
endfunction

autocmd BufNewFile,BufRead *.js setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd BufNewFile,BufRead *.sol set filetype=javascript
autocmd BufNewFile,BufRead *.jsx set filetype=typescript tabstop=2 softtabstop=2 shiftwidth=2
autocmd BufNewFile,BufRead *.ts set filetype=typescript tabstop=2 softtabstop=2 shiftwidth=2
autocmd BufNewFile,BufRead *.tsx set filetype=typescript tabstop=2 softtabstop=2 shiftwidth=2
autocmd BufNewFile,BufRead FileType javascript,javascript.jsx,javascript.tsx call EnableJavascript()
autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
"}}}

"------------------------------------
" PHPの設定
"------------------------------------
"{{{
"augroup PHP
"    autocmd!
"    autocmd FileType php set makeprg=php\ -l\ %
"    autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
"    " php -lの構文チェックでエラーがなければ「No syntax errors」の一行だけ出力される
"    autocmd BufWritePost *.php silent make | if len(getqflist()) != 1 | copen | else | cclose | endif
"augroup END
"}}}

"------------------------------------
" C++
"------------------------------------
"{{{
" 保存時にコンパイル
"au BufWritePost *.cpp silent :gcc 
"au BufWritePost *.cpp :lcd %:h | :!clang++ -Wall -std=c++14 %:p 1>/dev/null
"au QuickFixCmdPost * nested cwindow | redraw! 
"}}}

"------------------------------------
" MD記法
"------------------------------------
" {{{
autocmd BufRead,BufNewFile *.{mkd,md} set filetype=markdown
autocmd! FileType markdown hi! def link markdownItalic Normal
autocmd FileType markdown set commentstring=<\!--\ %s\ -->
" for plasticboy/vim-markdown
" let g:vim_markdown_no_default_key_mappings = 1
" let g:vim_markdown_math = 1
" let g:vim_markdown_frontmatter = 1
" let g:vim_markdown_toc_autofit = 1
" let g:vim_markdown_folding_style_pythonic = 1
nnoremap md :MarkdownPreview<CR>
" let g:md_pdf_viewer="/usr/bin/mupdf"
" nnoremap md :StartMdPreview<CR>

" }}}

"------------------------------------
" Plugins Settings
"------------------------------------
"{{{
" VimFiler
let g:vimfiler_as_default_explorer = 1

" VimShell
let g:vimshell_prompt = "> "
let g:vimshell_secondary_prompt = "> "
let g:vimshell_user_prompt = 'getcwd()'

"}}}

"------------------------------------
" Highlights
"------------------------------------
" {{{
highlight Pmenu ctermbg=4
highlight PmenuSel ctermbg=1
highlight PMenuSbar ctermbg=4
highlight MatchParen cterm=bold ctermbg=none ctermfg=white
" }}}

autocmd BufRead,BufNewFile *.tera  set filetype=jinja
autocmd BufNewFile,BufRead *.pug setlocal tabstop=2 softtabstop=2 shiftwidth=2
" let &colorcolumn=join(range(81,82),",")
" hi ColorColumn ctermbg=235 guibg=#2c2d27


