"------------------------------------
" OSの判定
"------------------------------------
"{{{
if has("mac")
    let g:ostype = 'Mac'
    let g:home = 'usr'
elseif has("unix")
    let g:ostype = 'Linux'
    let g:home = 'usr'
elseif has("win64")
    let g:ostype = 'Win64'
elseif has("win32unix")
    let g:ostype = 'Cygwin'
elseif has("win32")
    let g:ostype = 'Win32'
endif
"}}}

"------------------------------------
" dein
"------------------------------------
"{{{
if g:ostype == 'Mac' || g:ostype == 'Linux'
    "dein Scripts-----------------------------
    if &compatible
        set nocompatible               " Be iMproved
    endif

    " プラグインが実際にインストールされるディレクトリ
    let s:dein_dir = expand('~/.vim/.cache/dein')
    " dein.vim 本体
    let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

    " dein.vim がなければ github から落としてくる
    if &runtimepath !~# '/dein.vim'
        if !isdirectory(s:dein_repo_dir)
            execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
        endif
        execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
    endif
    " set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim

    " Required:
    "if dein#load_state(expand('~/usr/.vim/dein'))
    if dein#load_state(expand('~/'.g:home.'/.vim/dein'))
        call dein#begin(expand('~/.vim/dein'))

        " プラグインリストを収めた TOML ファイル
        " 予め TOML ファイル（後述）を用意しておく
        let g:rc_dir    = expand('~/.vim/rc')
        let s:toml      = g:rc_dir . '/dein.toml'
        let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

        " TOML を読み込み、キャッシュしておく
        call dein#load_toml(s:toml,      {'lazy': 0})
        call dein#load_toml(s:lazy_toml, {'lazy': 1})

        " Required:
        call dein#end()
        call dein#save_state()
    endif

    " Required:
    filetype plugin indent on
    syntax enable

    " If you want to install not installed plugins on startup.
    if dein#check_install()
        call dein#install()
    endif

    "End dein Scripts-------------------------
endif " }}}

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
" JAVA-SCRIPT系の設定
"------------------------------------
" {{{
" 保存時にコンパイル
au BufWritePost *.coffee silent make -b
" リアルタイムプレビュー
" au BufWritePost *.coffee :CoffeeWatch vert

" jasmine.vim
" ファイルタイプを変更
function! JasmineSetting()
    au BufRead,BufNewFile *Helper.js,*Spec.js  set filetype=jasmine.javascript
    au BufRead,BufNewFile *Helper.coffee,*Spec.coffee  set filetype=jasmine.coffee
    au BufRead,BufNewFile,BufReadPre *Helper.coffee,*Spec.coffee  let b:quickrun_config = {'type' : 'coffee'}
    call jasmine#load_snippets()
    map <buffer> <leader>m :JasmineRedGreen<CR>
    command! JasmineRedGreen :call jasmine#redgreen()
    command! JasmineMake :call jasmine#make()
endfunction
au BufRead,BufNewFile,BufReadPre *.coffee,*.js call JasmineSetting()
" indent_guides
" インデントの深さに色を付ける
let g:indent_guides_start_level=2
let g:indent_guides_auto_colors=0
let g:indent_guides_enable_on_vim_startup=0
let g:indent_guides_color_change_percent=20
let g:indent_guides_guide_size=1
let g:indent_guides_space_guides=1

hi IndentGuidesOdd  ctermbg=235
hi IndentGuidesEven ctermbg=237
au FileType coffee,ruby,javascript,python IndentGuidesEnable
nmap <silent><Leader>ig <Plug>IndentGuidesToggle
autocmd BufNewFile,BufRead *.coffee setlocal tabstop=2 softtabstop=2 shiftwidth=2
"}}}

"------------------------------------
" PHPの設定
"------------------------------------
"{{{
augroup PHP
  autocmd!
  autocmd FileType php set makeprg=php\ -l\ %
  autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
  " php -lの構文チェックでエラーがなければ「No syntax errors」の一行だけ出力される
  autocmd BufWritePost *.php silent make | if len(getqflist()) != 1 | copen | else | cclose | endif
augroup END
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
" プログラム言語共通の設定
"------------------------------------
" コンパイルエラー時の処理
au QuickFixCmdPost * nested cwindow | redraw! 

"------------------------------------
" 補完の設定
"------------------------------------
"{{{
highlight Pmenu ctermbg=4
highlight PmenuSel ctermbg=1
highlight PMenuSbar ctermbg=4

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
    function XTermPasteBegin(ret)
        set paste
        return a:ret
    endfunction
    noremap <special> <expr> <Esc>[200~ XTermPasteBegin("0i")
    "inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
    cnoremap <special> <Esc>[200~ <nop>
    cnoremap <special> <Esc>[201~ <nop>
endif
"}}}

"------------------------------------
" ノーマルモード移行時に自動で英数IMEに切り替え→Macのみ
"------------------------------------
"{{{
if g:ostype == 'Mac'
  set ttimeoutlen=1
  let g:imeoff = 'osascript -e "tell application \"System Events\" to key code 102"'
  augroup MyIMEGroup
    autocmd!
    autocmd InsertLeave * :call system(g:imeoff)
  augroup END
  noremap <silent> <ESC> <ESC>:call system(g:imeoff)<CR>
endif
"}}}

"------------------------------------
" キーマッピング
"------------------------------------
"{{{
noremap vf :VimFiler<CR>
noremap VS :VimShell<CR>
noremap DU :call dein#update()<CR>

inoremap { {}<Left>
inoremap ( ()<Left>
inoremap [ []<LEFT>
inoremap < <><LEFT>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>
" ==でインデント調整
nnoremap == gg=G''

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
" VimShellのプロンプト
"------------------------------------
"{{{
let g:vimshell_prompt = "> "
let g:vimshell_secondary_prompt = "> "
let g:vimshell_user_prompt = 'getcwd()'

"}}}
"------------------------------------
" その他の設定
"------------------------------------
if has("syntax")
    syntax on
endif

" VimFilerで自動cd
let g:vimfiler_enable_auto_cd = 1

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
set clipboard+=unnamed
colorscheme molokai
set t_Co=256
vnoremap * "zy:let @/ = @z<CR>

"w!!でsudo 保存
cabbr w!! w !sudo tee > /dev/null %
" swp 生成先を変更
"set directory=~/.vim/tmp



