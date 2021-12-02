if !1|finish|en

" +----------------------------------------------------------+
" | which OS ? -> OSTYPE: {'unknown', 'unix', 'mac', 'win' } |
" +----------------------------------------------------------+
let OSTYPE = 'unknown'
if has('unix') | let OSTYPE = 'unix' | en
if has('mac') | let OSTYPE = 'mac' | en
if has('win32') || has ('win64')
  let OSTYPE = 'win'
en


" +----------------------------------------------------------+
" | dein                                                     |
" +----------------------------------------------------------+
if &compatible
  se nocp " nocompatible " Be iMproved
en

se runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim
if dein#load_state('~/.cache/dein/')
  cal dein#begin('~/.cache/dein/')
  cal dein#add('Shougo/vimproc.vim', {'build' : 'make'})
  let g:rc_dir    = expand('~/.vim/rc')
  cal dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')
  cal dein#load_toml(g:rc_dir . '/dein.toml', {'lazy': 0})
  " cal dein#load_toml(g:rc_dir . '/lazy.toml', {'lazy': 1})
  cal dein#end()
  cal dein#save_state()
en
filetype plugin indent on
syntax enable
if dein#check_install()
  cal dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')
  cal dein#install()
en


" +----------------------------------------------------------+
" | Can Paste                                                |
" +----------------------------------------------------------+
if &term =~ "xterm"
  let &t_ti .= "\e[?2004h"
  let &t_te .= "\e[?2004l"
  let &pastetoggle = "\e[201~"
  func! XTermPasteBegin(ret)
    set paste
    return a:ret
  endf
  no <special> <expr> <Esc>[200~ XTermPasteBegin("0i")
  ino <special> <expr> <Esc>[200~ XTermPasteBegin("")
  cno <special> <Esc>[200~ <nop>
  cno <special> <Esc>[201~ <nop>
en


" +----------------------------------------------------------+
" | Key Mappings                                             |
" +----------------------------------------------------------+
"      mode: |Norm|Ins|Cmd|Vis|Sel|Opr|Term|Lang|
" command    +----+---+---+---+---+---+----+----+
" [nore]map  |yes | - | - |yes|yes|yes| -  | -  |
" n[nore]map |yes | - | - | - | - | - | -  | -  |
" [nore]map! | -  |yes|yes| - | - | - | -  | -  |
" i[nore]map | -  |yes| - | - | - | - | -  | -  |
" c[nore]map | -  | - |yes| - | - | - | -  | -  |
" v[nore]map | -  | - | - |yes|yes| - | -  | -  |
" x[nore]map | -  | - | - |yes| - | - | -  | -  |
" s[nore]map | -  | - | - | - |yes| - | -  | -  |
" o[nore]map | -  | - | - | - | - |yes| -  | -  |
" t[nore]map | -  | - | - | - | - | - |yes | -  |
" l[nore]map | -  |yes|yes| - | - | - | -  |yes |

" nn: n[nore]map: normalmode-no-remap
nn == gg=G''
nn n nzz
nn N Nzz
nn * *zz
nn # #zz
nn g* g*zz
nn g# g#zz
nn x "_x
nn ZZ <Nop>
nn ZQ <Nop>
nn Q gq

" no: [nore]map: no-remap
no <Space> <Plug>(operator-replace)
no j gj
no gj j
no k gk
no gk k
no <Up> gk
no <Down> j
no vs :vs<CR>

" " separate window
nn s <Nop>
nn sj <C-w>j
nn sk <C-w>k
nn sl <C-w>l
nn sh <C-w>h
nn sJ <C-w>J
nn sK <C-w>K
nn sL <C-w>L
nn sH <C-w>H
nn sn gt
nn sp gT
nn sr <C-w>r
nn s= <C-w>=
nn sw <C-w>w
nn so <C-w>_<C-w>|
nn sO <C-w>=
nn sN :<C-u>bn<CR>
nn sP :<C-u>bp<CR>
nn st :<C-u>tabnew<CR>
nn sT :<C-u>Unite tab<CR>
nn ss :<C-u>sp<CR>
nn sv :<C-u>vs<CR>
nn sq :<C-u>q<CR>
nn sQ :<C-u>bd<CR>
nn sb :<C-u>Unite buffer_tab -buffer-name=file<CR>
nn sB :<C-u>Unite buffer -buffer-name=file<CR>

cal submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
cal submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
cal submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
cal submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
cal submode#map('bufmove', 'n', '', '>', '<C-w>>')
cal submode#map('bufmove', 'n', '', '<', '<C-w><')
cal submode#map('bufmove', 'n', '', '+', '<C-w>+')
cal submode#map('bufmove', 'n', '', '-', '<C-w>-')


" +----------------------------------------------------------+
" | Language Configs: set, setlocalの違い                    |
" | https://secret-garden.hatenablog.com/entry/2017/12/14/175143 |
" +----------------------------------------------------------+
" Javascript
func! JSFolds()
  let thisline = getline(v:lnum)
  if match(thisline, '/\*\*') >= 0
    return 'a1'
  elseif match(thisline, '\*/') >= 0
    return 's1'
  else
    return '='
  en
endf

" ft: filetype, fdm: foldMethod, fde: foldExpression
" au BufRead,BufNewFile *.json setl ft=typescriptreact fdm=expr fde=JSFolds()
au BufRead,BufNewFile *.json setl ft=typescriptreact
au BufRead,BufNewFile *.js   setl ft=typescriptreact
au BufRead,BufNewFile *.ts   setl ft=typescriptreact
au BufRead,BufNewFile *.jsx  setl ft=typescriptreact

au FileType typescriptreact  setl sts=2 ts=2 sw=2 fdm=syntax fdl=0 fdn=2

" Tex
au BufRead,BufNewFile *.tex  setl ts=4 sts=4 sw=4

" Python
au FileType python           setl fdm=indent fdl=0 fdn=2

" Html
au BufRead,BufNewFile *.html setl ft=htmldjango
au BufRead,BufNewFile *.tera setl ft=htmldjango

" Cpp like lang
au BufRead,BufNewFile *.c    setl ft=cpp
au BufRead,BufNewFile *.cl   setl ft=cpp
au BufRead,BufNewFile *.mq4  setl ft=cpp
au BufRead,BufNewFile *.mqh  setl ft=cpp
au FileType cpp              setl sts=2 ts=2 sw=2 fdm=syntax fdl=0 fdn=2

" Rust
au FileType rust             setl fdm=indent fdl=0 fdn=2

" Markdown
au FileType markdown         setl sts=4 ts=4 sw=4 fdm=syntax fdl=0 fdn=2

" Shell
au FileType sh               setl sts=2 ts=2 sw=2 fdm=syntax fdl=0 fdn=2
au FileType zsh              setl ft=sh

" Vim
au FileType vim              setl sts=2 ts=2 sw=2 fdm=syntax fdl=0 fdn=2

" Vue
au FileType vue              setl sts=2 ts=2 sw=2 fdm=syntax fdl=0 fdn=2
"au FileType vue              setl noexpandtab " tmp

" SQL
au FileType sql              setl sts=2 ts=2 sw=2 fdm=syntax fdl=0 fdn=2

" Golang
au FileType go               setl sts=2 ts=2 sw=2 fdm=syntax fdl=0 fdn=2

" PHP
au FileType php              setl sts=4 ts=4 sw=4 fdm=syntax fdl=0 fdn=2

" Jinja
au BufRead,BufNewFile *.liquid setl ft=jinja
au FileType jinja            setl sts=4 ts=4 sw=4

" Pug
au FileType jinja            setl sts=2 ts=2 sw=2

" Other Files
func! s:GetBufByte()
  let byte = line2byte(line('$') + 1)
  if byte == -1
    return 0
  else
    return byte - 1
  en
endf
au VimEnter * nested if @% == '' && s:GetBufByte() == 0 | se ft=sh | en
au BufRead,BufNewFile * nested if @% !~ '\.' | se ft=sh | en


" +----------------------------------------------------------+
" | Plugins Configs                                          |
" +----------------------------------------------------------+
" dein vim
nn DU :call dein#update()<CR>
nn RES :call dein#recache_runtimepath()<CR>

" VimFiler
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_enable_auto_cd = 1 " 自動cd
nn vf :VimFiler -auto-cd<CR>

" VimShell
let g:vimshell_split_command = 'split'
let g:vimshell_user_prompt = 'getcwd()'
nn VS :VimShellInteractive zsh<CR>

" Rainbow Parentheses Improved
let g:rainbow_active = 1

" deoplete
let g:deoplete#enable_at_startup = 1

" jsx color
let g:vim_jsx_pretty_colorful_config = 0

" markdown preview
let g:vim_markdown_folding_disabled=1
let g:previm_show_header=0
" let g:previm_open_cmd='/usr/bin/google-chrome-stable'
nn md :PrevimOpen<CR>


" +----------------------------------------------------------+
" | Set Configs                                              |
" +----------------------------------------------------------+
se ml " modeline
se mls=2 " modelines
se bs=indent,eol,start " backspace: backspace can delete `indent`, `eol`, `before start position`
se cot=menuone " completeopt: Option for completion
se enc=utf-8 " encoding: File encoding se fencs+=sjis,utf-8 " fileencodings
if has("syntax") | syntax on | endif
" Disable auto comment when new line
aug auto_comment_off
  au!
  au BufEnter * setl fo-=r " formatoptions
  au BufEnter * setl fo-=o
aug END

se nu " number
se ambw=double " ambiwidth
se et " expandtab
se ai " autoindent
se si " smartindent
se wrap
se list " Show invisible chars
se lcs=tab:░░,trail:-,nbsp:↲,eol:↲,extends:»,precedes:« " listchars: Show invisible chars as this
se ffs=unix " fileformats: Force newline char LF
se nf-=octal " nrformats: disable octal {in/de}crement when <C-a> <C-x>
se hid " hidden
se history=50
se ve=all " virtualedit
se ww=b,s,[,],<,>,~ " whichwrap
se wmnu " wildmenu

se ignorecase
se mouse=a

color monokai " colorscheme
se t_Co=256
se smc=512 " synmaxcol

" sudo save with 'w!!'
cabbr w!! w !sudo tee > /dev/null %

" swp create to /tmp/vimswp
if OSTYPE == "unix" || OSTYPE == "mac"
  silent !mkdir -p /tmp/vimswp
  " se dir=/tmp/vimswp " directory
else
  se noswapfile " noswapfile
en
se noswapfile " noswapfile

" Current line content to clipboard
:command -range Xz :silent :<line1>,<line2>w !xsel -i -b
:cabbrev xz Xz

" DateTime now
nn dt :pu=strftime('%Y-%m-%dT%H:%M:%S.000Z')<CR>

" Shell Bootstrap
func! s:ShellDefault()
  let s:shell_default =<< trim END
    #!/bin/bash
    DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"&>/dev/null &&pwd)" # SCRIPT_DIR
    err() {
      echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
    }
    ok=1
    require() {
      is_ok=true
      for cmd in $*; do
        if ! type $cmd&>/dev/null; then
          err "command '$cmd' is required."
          is_ok=false
        fi
      done
      if [ $is_ok != true ]; then
        # when use `source` command
        if [ "$(sed -e 's/\x0/ /g' /proc/$$/cmdline)" = "$SHELL " ]; then
          echo "exit"
          ok=''
          return
        else
          exit 1
        fi
      fi
    }
    # [ $ok ] && require REQUIRED_COMMAND1 REQUIRED_COMMAND2

  END
  return s:shell_default
endf
:command Nsh :pu=s:ShellDefault()
:cabbrev nsh Nsh


" +----------------------------------------------------------+
" | Highlights                                               |
" +----------------------------------------------------------+
hi Pmenu      ctermfg=81 ctermbg=8 guifg=#66D9EF guibg=#606060
hi PmenuSel   ctermfg=242 ctermbg=1 guifg=#dddd00 guibg=#1f82cd
hi PmenuSbar  ctermbg=0 guibg=#d6d6d6
hi MatchParen cterm=bold ctermbg=none ctermfg=white
hi Normal     ctermbg=NONE guibg=NONE
hi NonText    ctermbg=NONE guibg=NONE
hi Comment    ctermfg=cyan
vn * "zy:let @/ = @z<CR>

