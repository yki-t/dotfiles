# Prompt
set -o pipefail
autoload -Uz colors; colors
if [ "$VIMSHELL" ]; then
  PROMPT="%{${fg_bold[yellow]}%}%~%{${reset_color}%} $ "
elif [ ${UID} -eq 0 ]; then # if Root
  PROMPT="${fg[red]}[%n:${HOST}] ${reset_color}@${fg[white]} %D{%Y-%m-%d %H:%M:%S}
%{${fg_bold[yellow]}%}%~%{${reset_color}%}
# "
else
  PROMPT="${fg[green]}[%n:${HOST}] ${reset_color}@${fg[white]} %D{%Y-%m-%d %H:%M:%S}
%{${fg_bold[yellow]}%}%~%{${reset_color}%}
$ "
fi

# zsh settings
autoload -U compinit; compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt magic_equal_subst
setopt list_types
unsetopt no_match
setopt IGNOREEOF
setopt AUTO_CD
setopt SH_WORD_SPLIT
unset zle_bracketed_paste # disable ^[[2004h
bindkey -a '^[[3${HOME}' delete-char # <DEL> to be {lower,upper}case
zstyle ':completion:*' list-colors "${LS_COLORS}"


local LS=ls
if [ ! "$(which ls|grep aliased)" ]; then
  LS=$(which ls)
fi

if type exa &>/dev/null;then
  alias ls="$(which exa) --long -m --time-style iso"
else
  alias ls="$LS --color=auto"
fi

if type rg &>/dev/null; then
  alias rg='rg --no-ignore --hidden'
fi

# aliases and functions
# Error print to stderr
err() {
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}
# Require commands
require() {
  is_ok=true
  for cmd in $*; do
    if ! (type $cmd &>/dev/null); then
      err "command '$cmd' is required."
      is_ok=false
    fi
  done
  [ $is_ok != true ] && return 1
  return 0
}

CMD_COPY() {
  if [ $(uname) = 'Darwin' ]; then
    pbcopy
  else
    xsel -bi
  fi
}

# Record
# function rec() {
#     if echo $(hostname) | grep -F -q laptop; then
#         if !(type arecord&>/dev/null); then
#             echo "arecord is not installed"
#             return
#         fi
#         [ ! -d "${HOME}/Music/Records" ] && mkdir -p "${HOME}/Music/Records"
#         arecord -f S16_LE -r 44100 "${HOME}/Music/Records/$(date "+%Y.%m.%d;%H:%M:%S").wav"
#     fi
# }

# LINE notify
rep() {
  require curl || return
  [ ! -z "${LINE_NOTIFY_TOKEN}" ] || return $(err "env_var 'LINE_NOTIFY_TOKEN' must be set.")
  local message=$1
  if [ $# -ne 1 ] || [ -z "${message}" ]; then
    return $(err 'usage: `rep some_message_you_want`')
  fi
  curl -Ss -X POST \
    -H "Authorization: Bearer ${LINE_NOTIFY_TOKEN}" \
    -F "message=$message" \
    https://notify-api.line.me/api/notify
  }

# Desktop notify
n() {
  require notify-send || return
  notify-send $*
}

# rsync & rm -rf
rmSync() {
  require rsync notify-send rm ls || return
  while read f; do
    if [ "$f" = '.' ] || [ "$f" = '..' ]; then continue; fi
    rsync -Pr "$1/$f" "$2"
    if [ $? -eq 0 ]; then
      rm -rf "$1/$f"
    else
      n 'rmSyncFailed'
      rm -rf "$2/$f"
      break
    fi
    n 'rmSyncDone'
  done< <($LS -a "$1")
}

# p*xz compress
pxc() {
  require pixz tar pv du awk rm sed || return
  [ $# -eq 0 ] && return $(err 'Quets must be set like `pxc "folder_to_compress/"`')
  for f in "$@"; do
    f=$(echo "$f"|sed 's~/$~~')
    [ ! -e "$f" ] && continue
    if [ $(uname) = 'Darwin' ]; then
      tar -Pcf - "$f" \
        | pv -s $(($(du -sk "$f" | awk '{print $1}') * 1024)) \
        | pixz -9 -- \
        > "$f.tar.xz"
    else
      tar cf - "$f" -P \
        | pv -s $(du -sb "$f" | awk '{print $1}') \
        | pixz -9 -- \
        > "$f.tar.xz"
    fi
    [ $? -ne 0 ] && rm -rf "$f.tar.xz"
  done
}

# p*xz decompress
pxx() {
  require pixz tar || return
  [ $# -eq 0 ] && return $(err 'Quets must be set like `pxx "folder_to_decompress.tar.xz"`')
  for f in "$@"; do
    [ ! -e "$f" ] && continue
    echo "Expanding $f"
    tar --use-compress-program 'pixz -d' -x -f "$f"
  done
}

# Encrypt file
function encrypt() {
  require openssl || return
  local file=$1 pass
  if [ $# -ne 1 ] || [ ! -e "$file" ]; then
    return $(err 'usage: `encrypt file`')
  fi
  read -s "passwd?Enter passphrase: "; echo
  read -s "passwd2?Enter same passphrase again: "; echo
  if [ "$passwd" != "$passwd2" ]; then
    return $(err 'Passphrase does not match')
  fi

  echo -n "$passwd" \
    | openssl enc -aes-256-cbc -pbkdf2 -in "$file" -pass stdin \
    | pv -s $(($(du -sk "$file" | awk '{print $1}') * 1024)) \
    > "$file.enc"
}

function decrypt() {
  require openssl || return
  local file=$1 pass
  if [ $# -ne 1 ] || [ ! -e "$file" ]; then
    return $(err 'usage: `decrypt file`')
  fi
  read -s "passwd?Enter passphrase: "; echo
  echo -n "$passwd" \
    | openssl enc -d -aes-256-cbc -pbkdf2 -in "$file" -pass stdin \
    | pv -s $(($(du -sk "$file" | awk '{print $1}') * 1024)) \
    > "${file%.enc}"
}

__git_files() { _files }

rand() {
  local range max to_clipboard randstr
  local number small large symbol
  local -A opthash
  zparseopts -D -A opthash -- i -int w -week c -clipboard e -easy

  if [[ -n "${opthash[(i)-e]}" ]] || [[ -n "${opthash[(i)--easy]}" ]]; then
    number='23456789'
    small='abcdefghijkmnpqrstuvwxyz'
    large='ABCDEFGHJKLMNPQRSTUVWXYZ'
    symbol='!#$%&()*+-/<=>?@[]{}'
  else
    number='0123456789'
    small='abcdefghijklmnopqrstuvwxyz'
    large='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    symbol='!#$%&()*+,-./:;<=>?@[]^_{|}~'
  fi

  if [[ -n "${opthash[(i)-i]}" ]] || [[ -n "${opthash[(i)--int]}" ]]; then
    range="$number"
  elif [[ -n "${opthash[(i)-w]}" ]] || [[ -n "${opthash[(i)--week]}" ]]; then
    range="$number$small$large"
  else
    range="$number$small$large$symbol"
  fi

  to_clipboard=0
  if [[ -n "${opthash[(i)-c]}" ]] || [[ -n "${opthash[(i)--clipboard]}" ]]; then
    to_clipboard=1
  fi

  if [ $# -eq 1 ];then
    count=$(($1))
  else
    count=128
  fi
  randstr="$(cat /dev/urandom | LC_CTYPE=C tr -dc $range | head -c $count | sed -e's|[\r\n]||g')"
  if [ $to_clipboard -eq 1 ];then
    print "$randstr"|$CMD_COPY
  else
    print "$randstr"
  fi
}

keygen() {
  local comment path
  local -A opthash
  zparseopts -D -A opthash -- f: -file:
  path="${HOME}/.ssh/id_ed25519"
  if [[ -n "${opthash[(i)-f]}" ]];then
    path="${opthash[-f]}"
  elif [[ -n "${opthash[(i)--file]}" ]];then
    path="${opthash[--file]}"
  fi

  if [ $# -eq 1 ];then
    comment="$1"
  else
    comment="$HOST"
  fi
  /usr/bin/ssh-keygen -o -a 100 -t ed25519 -f "$path" -C "$comment"
}

rust() {
  if (!type cargo &>/dev/null); then
    echo "This function needs 'cargo'"
    return 1
  fi
  if (!type systemfd &>/dev/null); then
    echo "This function needs 'systemfd'"
    echo "please 'cargo install systemfd'"
    return 1
  fi
  local port mode
  local -A opthash
  zparseopts -D -A opthash -- p: t v
  port=3000
  if [[ -n "${opthash[(i)-p]}" ]];then
    port="${opthash[-p]}"
  fi

  mode='run'
  if [[ -n "${opthash[(i)-t]}" ]];then
    mode='test'
  fi
  if [[ -n "${opthash[(i)-v]}" ]];then
    mode='vue'
  fi

  if [ "${mode}" = 'vue' ];then
    systemfd --no-pid -s http::"${port}" -- cargo watch -i 'static/*' -s 'cd vue && yarn build && cd .. && cargo run'
  else
    systemfd --no-pid -s http::"${port}" -- cargo watch -x ${mode}
  fi
}

cnv() {
  require cat nkf
  for inp in "$@"; do
    local temp=$(mktemp)
    if [ ! -n "$inp" ] || [ ! -n "$temp" ]; then
      return $(err "Specify argument")
    fi
    cat "$inp"|nkf > "$temp" \
      && mv "$temp" "$inp"
  done
}

wgetAll() {
  wget \
    --mirror \
    --page-requisites \
    --quiet \
    --show-progress \
    --no-parent \
    --convert-links \
    --adjust-extension \
    --execute robots=off \
    "$@"
}

wgetOne() {
  wget \
    --quiet \
    --show-progress \
    --no-parent \
    --page-requisites \
    --convert-links \
    --adjust-extension \
    --execute robots=off \
    --level 2 \
    "$@"
}
wgetOneDesktop() {
  wget \
    --quiet \
    --show-progress \
    --no-parent \
    --page-requisites \
    --convert-links \
    --adjust-extension \
    --execute robots=off \
    --level 2 \
    --user-agent='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36' \
    "$@"
}
wgetOneMobile() {
  wget \
    --quiet \
    --show-progress \
    --no-parent \
    --page-requisites \
    --convert-links \
    --adjust-extension \
    --execute robots=off \
    --level 2 \
    --user-agent='Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Mobile Safari/537.36' \
    "$@"
}
u() {
  require loginctl || return
  loginctl unlock-session $*
}

bakup() {
  require tar pv pixz du xargs awk realpath || return
  local args=()
  local ignores=()
  while (( $# > 0 )); do
    case $1 in
      -*)
        if [[ "$1" =~ 'i' ]]; then
          ignores+=("$2")
          shift
        fi
        shift
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done
  [ ${#args} -ne 2 ] && return $(err 'usage: `backup srcDir dstDir [-i ignoreDir1 -i ignoreDir2]`')
  local srcDir="${args[1]}"
  local dstDir="${args[2]}"

  mkdir -p $dstDir

  local isIncomplete=''
  while read srcNode; do
    if [ "$srcNode" = '.' ] || [ "$srcNode" = '..' ]; then continue; fi
    if [ "$(find /tmp -name 'bakupLog-*' 2>/dev/null)" ] && [ ! -f "/tmp/bakupLog-$srcNode" ]; then
      isIncomplete=1
      echo "restarting from previous operation. ignore $srcNode"
      continue
    else
      touch "/tmp/bakupLog-$srcNode"
    fi
    src="$(realpath "$srcDir/$srcNode")"

    if [[ "${ignores[@]}" =~ "${srcNode}" ]]; then
      echo "Backup: '$src' is in ignores list. ignore"
      rm "/tmp/bakupLog-$srcNode"
      continue
    fi
    if [[ ! "$src" =~ "^$srcDir" ]]; then
      echo "Backup: '$src' is a symlink. ignore"
      rm "/tmp/bakupLog-$srcNode"
      continue
    fi
    srcSize="$(du -s "$src"|awk '{print $1}')"
    srcHash="$(find "$src"|LC_ALL=C sort|md5sum|awk '{print $1}')"
    dst="$(realpath "$dstDir/$srcNode")-$srcHash-$srcSize.tar.xz"
    if [ -f "$dst" ] \
      && [ "$(du -s "$dst"|awk '{print $1}')" -ne 0 ] \
      && [ ! $isIncomplete ] \
      ; then
      echo "Backup: '$src' is not changed. ignore"
      rm "/tmp/bakupLog-$srcNode"
      continue
    fi
    echo "Backing up: '$src' -> '$dst'"
    tar cf - "$src" -P \
      | pv -s $(du -sb "$src"|awk '{print $1}') \
      | pixz -9 -- \
      > "$dst"
    rm "/tmp/bakupLog-$srcNode"
    isIncomplete=''
  done< <($LS -a "$srcDir")
}

combineVideos() {
  require ffmpeg || return
  local argCnt=$# cmd='ffmpeg' firstStr="$1" outFile='' avs='' msg=''
  [ $argCnt -lt 2 ] && return $(err 'usage: `combineVideos srcA.mp4 srcB.mp4` makes src.mp4')

  for arg in "$@"; do
    cmd+=" -i $arg"
    outFile=''
    for i in $(seq 0 ${#arg}); do
      # printf "$i:<${arg:$i:1} ${firstStr:$i:1}>"
      if [ "${arg:$i:1}" = "${firstStr:$i:1}" ]; then
        outFile+="${arg:$i:1}"
      else
        outFile+="X"
      fi
    done
  done

  avs=$(for i in $(seq 0 $((argCnt-1))); do printf "[${i}:v:0][${i}:a:0]"; done)
  cmd+=" -filter_complex ${avs}concat=n=$argCnt:v=1:a=1[outv][outa] -map [outv] -map [outa]"
  cmd+=" $outFile"

  msg+="[${C_PINK}combineVideos:START${C_RESET}]\n"
  msg+="${C_CYAN}sources${C_RESET}: $@\n"
  msg+="${C_CYAN}outfile${C_RESET}: $outFile\n"
  msg+="${C_CYAN}command${C_RESET}: $cmd"
  echo -e $msg

  if read -q 'ok?[y/n]'; then
    echo ''
    # echo "cmd: $cmd"
    $cmd
    echo -e "\n[${C_PINK}combineVideos:DONE${C_RESET}]"
  else
    echo -e "\n[${C_PINK}combineVideos:ABORT${C_RESET}]"
    return
  fi
}


removeBom() {
  require ffmpeg || return
  local argCnt=$#
  [ $argCnt -ne 1 ] && return $(err 'usage: `remBom utf16_with_bom_file`')
  sed -i '1s/^\xEF\xBB\xBF//' $*
}

s2c() { # snake_case to camelCase
  local argCnt=$#
  [ $argCnt -ne 0 ] && return $(err 'usage: `echo snake_case | s2c`')
  awk -F '_' '{ printf $1; for(i=2; i<=NF; i++) {printf toupper(substr($i,1,1)) substr($i,2)}} END {print ""}'
}

c2s() { # camelCase to snake_case
  local argCnt=$#
  [ $argCnt -ne 0 ] && return $(err 'usage: `echo camelCase | c2s`')
  sed -E 's/(.)([A-Z])/\1_\2/g' | tr '[A-Z]' '[a-z]'
}
clearCache() {
  require sync tee || return
  sync && echo 3 | sudo tee /proc/sys/vm/drop_caches && swapoff -a && swapon -a
}

dl() {
  require yt-dlp ffmpeg || return
  before=(); while read f; do before+=("$f"); done< <($LS)
  yt-dlp -ci -f 'bestaudio[ext=m4a]' $*
  after=(); while read f; do after+=("$f"); done< <($LS)
  new_file=''
  for a in "${after[@]}"; do
    has_new=1
    for b in "${before[@]}"; do
      if [ "$b" = "$a" ]; then
        has_new=
        break
      fi
    done
    if [ "$has_new" ]; then
      new_file="$a"
      break
    fi
  done
  echo $new_file
  if [ "$new_file" ]; then
    wav="$(echo "$new_file" | sed -e 's|\([^\.]*\)\.\(.*\)|\1.wav|')"
    echo $wav
    ffmpeg -i "$new_file" "$wav"
  fi
}

chatgpt() {
  local api_key="${OPENAI_API_KEY}"
  local model="${OPENAI_DEFAULT_MODEL:-gpt-3.5-turbo}"
  local prompt_text tempfile resp error
  require jq || return
  prompt_text="$(/bin/cat)"
  prompt_text="$(printf '%s' "$prompt_text" | jq -Rs .)"

  if [ -z "$api_key" ]; then
    echo "Error: OPENAI_API_KEY is not set." >&2
    return 1
  fi
  data='{"model": "'"$model"'", "messages": [{"role": "user", "content": '"$prompt_text"'}]}'

  tempfile=$(mktemp /tmp/chatgpt-msg.XXXXXX)
  curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $api_key" \
    -d "$data" \
    > "$tempfile"

  error=$(/bin/cat "$tempfile" | jq -r '.error.message')
  if [ "$error" != 'null' ]; then
    echo "Error: $resp" >&2
    return 1
  fi
  /bin/cat "$tempfile" | jq -r '.choices[0].message.content'
}

commit() {
  local diff st
  st="$(git status)"
  diff="$(git diff --cached)"

  if [ -z "$diff" ]; then
    echo "No staged changes found. Please stage your changes first."
    return 1
  fi

  echo -n "Generating commit message..."

  local prompt_text message
  prompt_text="Please generate a commit message based on the diff below with conventional commit message format. "
  prompt_text+="Summarize the key points. "
  prompt_text+="Response must have only commit message without codeblocks. "
  prompt_text+="If commit message has multiple lines, the first line must be the summary. "
  prompt_text+="[status]\n$st\n"
  prompt_text+="[diff]\n$diff"

  message=$(echo $prompt_text | chatgpt)
  tmpfile="$(mktemp /tmp/ai-commit-msg.XXXXXX)"
  echo "$message" > "$tmpfile"
  git commit --edit -F "$tmpfile"
  rm -f "$tmpfile"
}

require scp && alias scp='scp -c aes256-ctr -pq'

if type bat &>/dev/null; then
  alias cat='bat'
else
  if type batcat &>/dev/null; then
    alias cat='batcat'
  else
  fi
fi

# Ruby
if [ -d ${HOME}/.rbenv ]; then
  eval "$(rbenv init -)"
fi

# nvm
if [ -f /usr/share/nvm/init-nvm.sh ]; then
  source /usr/share/nvm/init-nvm.sh
fi

# For Vimmer
bindkey -v
alias vi='vim'
alias v='vim'
alias ssh='TERM=xterm-256color ssh'
type dstat &>/dev/null && alias dstat="dstat -tlafm --tcp"

# Compile .zshrc
if [ -f "${HOME}/.zshrc" ] && ( [ ! -f "${HOME}/.zshrc.zwc" ] || [ "${HOME}/.zshrc" -nt "${HOME}/.zshrc.zwc" ] ); then
  zcompile ${HOME}/.zshrc
fi

# Xmodmap
if [[ -f "${HOME}/.zprofile" ]] && [[ ! $(cat "${HOME}/.zprofile"|grep -F 'type xmodmap&>/dev/null && xmodmap ${HOME}/.Xmodmap') ]]; then
  echo '[[ -f ${HOME}/.Xmodmap ]] && type xmodmap&>/dev/null && xmodmap ${HOME}/.Xmodmap' >> "${HOME}/.zprofile"
fi

if type xinput &>/dev/null; then
  while read id; do
    local prop='libinput Accel Speed'
    xinput set-prop $id $(xinput list-props $id | grep "$prop (" | head -n 1 | sed -e "s|$prop (\([0-9]*\)).*|\1|") 1.0
    prop='libinput Natural Scrolling Enabled'
    xinput set-prop $id $(xinput list-props $id | grep "$prop (" | head -n 1 | sed -e "s|$prop (\([0-9]*\)).*|\1|") 0.0
  done< <(xinput | grep 'Magic Trackpad' | sed -e 's|.*id=\([0-9]*\).*|\1|')
fi

# added by Nix installer
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
  . $HOME/.nix-profile/etc/profile.d/nix.sh;
fi

# OS settings
if [ $(uname) = 'Darwin' ]; then
  alias vim='/opt/homebrew/bin/vim'

  source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
  source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

  # export PATH=$HOME/.nodebrew/current/bin:$PATH
  export PATH=/opt/homebrew/var/nodebrew/current/bin:$PATH
fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion 

if [ -e /usr/lib/pkgconfig ]; then
  export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig
fi

export PATH=${PATH}:$HOME/gsutil

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin"

if [ -f "$HOME/.append.sh" ]; then
  source "$HOME/.append.sh"
fi

if [ -e /home/yuki/.nix-profile/etc/profile.d/nix.sh ]; then . /home/yuki/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# wsl
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  # APPDATA is sometimes empty
  if [ -d "$APPDATA" ]; then
    precmd() {
      pwd > "$APPDATA/lastpwd"
    }
  fi
fi

rmwsltrash() {
  rm -rf -- \(default\) -a -m -u -w Usage: WSL Windows a absolute force format from path path, result to translate with
}

# pnpm
export PNPM_HOME="/home/yuki/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

