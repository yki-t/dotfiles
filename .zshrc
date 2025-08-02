#!/usr/bin/env zsh
# .zshrc - Interactive shell configuration
# This file is sourced for every interactive shell session

# ==============================================================================
# Prompt configuration
# ==============================================================================

set -o pipefail
autoload -Uz colors && colors

if [[ -n "$VIMSHELL" ]]; then
  PROMPT="%{${fg_bold[yellow]}%}%~%{${reset_color}%} $ "
elif [[ ${UID} -eq 0 ]]; then  # Root user
  PROMPT="${fg[red]}[%n:${HOST}] ${reset_color}@${fg[white]} %D{%Y-%m-%d %H:%M:%S}
%{${fg_bold[yellow]}%}%~%{${reset_color}%}
# "
else
  PROMPT="${fg[green]}[%n:${HOST}] ${reset_color}@${fg[white]} %D{%Y-%m-%d %H:%M:%S}
%{${fg_bold[yellow]}%}%~%{${reset_color}%}
$ "
fi

# ==============================================================================
# Zsh configuration
# ==============================================================================

autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${LS_COLORS}"

setopt magic_equal_subst
setopt list_types
unsetopt no_match
setopt IGNOREEOF
setopt AUTO_CD
setopt SH_WORD_SPLIT
unset zle_bracketed_paste  # Disable ^[[2004h

# Key bindings
bindkey -v  # Vi mode
bindkey -a '^[[3${HOME}' delete-char  # <DEL> to be {lower,upper}case

# Git completion
__git_files() { _files }

# ==============================================================================
# Aliases
# ==============================================================================

# Core utilities
local LS='ls'
if [[ ! "$(which ls | grep aliased)" ]]; then
  LS="$(which ls)"
fi

if type exa &>/dev/null; then
  alias ls="$(which exa) --long -m --time-style iso"
else
  alias ls="$LS --color=auto"
fi

# Enhanced commands
if type bat &>/dev/null; then
  alias cat='bat'
elif type batcat &>/dev/null; then
  alias cat='batcat'
fi

type scp &>/dev/null && alias scp='scp -c aes256-ctr -pq'
type dstat &>/dev/null && alias dstat='dstat -tlafm --tcp'
type claude &>/dev/null && alias cc='claude --dangerously-skip-permissions'

# Vim
alias vi='vim'
alias v='vim'
alias ssh='TERM=xterm-256color ssh'

# ==============================================================================
# Utility functions
# ==============================================================================

# Error printing to stderr
err() {
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

# Check required commands
require() {
  local is_ok=true
  for cmd in "$@"; do
    if ! type "$cmd" &>/dev/null; then
      err "command '$cmd' is required."
      is_ok=false
    fi
  done
  [[ "$is_ok" != true ]] && return 1
  return 0
}

# Cross-platform clipboard
CMD_COPY() {
  if [[ "$(uname)" = 'Darwin' ]]; then
    pbcopy
  else
    xsel -bi
  fi
}

# ==============================================================================
# Notification functions
# ==============================================================================

# LINE notify
rep() {
  require curl || return
  [[ -z "${LINE_NOTIFY_TOKEN}" ]] && return $(err "env_var 'LINE_NOTIFY_TOKEN' must be set.")
  local message="$1"
  if [[ $# -ne 1 ]] || [[ -z "${message}" ]]; then
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
  notify-send "$@"
}

# ==============================================================================
# File operations
# ==============================================================================

# rsync & rm -rf
rmSync() {
  require rsync notify-send rm ls || return
  while read f; do
    [[ "$f" = '.' ]] || [[ "$f" = '..' ]] && continue
    rsync -Pr "$1/$f" "$2"
    if [[ $? -eq 0 ]]; then
      rm -rf "$1/$f"
    else
      n 'rmSyncFailed'
      rm -rf "$2/$f"
      break
    fi
    n 'rmSyncDone'
  done < <($LS -a "$1")
}

# ==============================================================================
# Compression/Decompression
# ==============================================================================

# pixz compress
pxc() {
  require pixz tar pv du awk rm sed || return
  [[ $# -eq 0 ]] && return $(err 'Quests must be set like `pxc "folder_to_compress/"`')
  for f in "$@"; do
    f="$(echo "$f" | sed 's~/$~~')"
    [[ ! -e "$f" ]] && continue
    if [[ "$(uname)" = 'Darwin' ]]; then
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
    [[ $? -ne 0 ]] && rm -rf "$f.tar.xz"
  done
}

# pixz decompress
pxx() {
  require pixz tar || return
  [[ $# -eq 0 ]] && return $(err 'Quests must be set like `pxx "folder_to_decompress.tar.xz"`')
  for f in "$@"; do
    [[ ! -e "$f" ]] && continue
    echo "Expanding $f"
    tar --use-compress-program 'pixz -d' -x -f "$f"
  done
}

# ==============================================================================
# Encryption/Decryption
# ==============================================================================

encrypt() {
  require openssl || return
  local file="$1" pass
  if [[ $# -ne 1 ]] || [[ ! -e "$file" ]]; then
    return $(err 'usage: `encrypt file`')
  fi
  read -s "passwd?Enter passphrase: " && echo
  read -s "passwd2?Enter same passphrase again: " && echo
  if [[ "$passwd" != "$passwd2" ]]; then
    return $(err 'Passphrase does not match')
  fi

  echo -n "$passwd" \
    | openssl enc -aes-256-cbc -pbkdf2 -in "$file" -pass stdin \
    | pv -s $(($(du -sk "$file" | awk '{print $1}') * 1024)) \
    > "$file.enc"
}

decrypt() {
  require openssl || return
  local file="$1" pass
  if [[ $# -ne 1 ]] || [[ ! -e "$file" ]]; then
    return $(err 'usage: `decrypt file`')
  fi
  read -s "passwd?Enter passphrase: " && echo
  echo -n "$passwd" \
    | openssl enc -d -aes-256-cbc -pbkdf2 -in "$file" -pass stdin \
    | pv -s $(($(du -sk "$file" | awk '{print $1}') * 1024)) \
    > "${file%.enc}"
}

# ==============================================================================
# Development utilities
# ==============================================================================

# Search eternal history
histgrep() {
  if [[ $# -eq 0 ]]; then
    err "usage: histgrep <pattern>"
    return 1
  fi
  
  if [[ ! -f "$ETERNAL_HISTORY" ]]; then
    err "Eternal history file not found: $ETERNAL_HISTORY"
    return 1
  fi
  
  grep -E "$1" "$ETERNAL_HISTORY" | less
}

# Show recent eternal history
histtail() {
  local lines="${1:-50}"
  
  if [[ ! -f "$ETERNAL_HISTORY" ]]; then
    err "Eternal history file not found: $ETERNAL_HISTORY"
    return 1
  fi
  
  tail -n "$lines" "$ETERNAL_HISTORY"
}

# Random string generator
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

  local count=${1:-128}
  randstr="$(cat /dev/urandom | LC_CTYPE=C tr -dc $range | head -c $count | sed -e's|[\r\n]||g')"
  if [[ $to_clipboard -eq 1 ]]; then
    print "$randstr" | $CMD_COPY
  else
    print "$randstr"
  fi
}

# SSH key generation
keygen() {
  local comment path
  local -A opthash
  zparseopts -D -A opthash -- f: -file:
  path="${HOME}/.ssh/id_ed25519"
  if [[ -n "${opthash[(i)-f]}" ]]; then
    path="${opthash[-f]}"
  elif [[ -n "${opthash[(i)--file]}" ]]; then
    path="${opthash[--file]}"
  fi

  comment="${1:-$HOST}"
  /usr/bin/ssh-keygen -o -a 100 -t ed25519 -f "$path" -C "$comment"
}

# Rust development server
rust() {
  require cargo systemfd || return 1
  local port mode
  local -A opthash
  zparseopts -D -A opthash -- p: t v
  port="${opthash[-p]:-3000}"

  mode='run'
  [[ -n "${opthash[(i)-t]}" ]] && mode='test'
  [[ -n "${opthash[(i)-v]}" ]] && mode='vue'

  if [[ "${mode}" = 'vue' ]]; then
    systemfd --no-pid -s http::"${port}" -- cargo watch -i 'static/*' -s 'cd vue && yarn build && cd .. && cargo run'
  else
    systemfd --no-pid -s http::"${port}" -- cargo watch -x ${mode}
  fi
}

ssm() {
  local instanceName=$1
  if [[ -z "$instanceName" ]] || [[ -z "$AWS_PROFILE" ]]; then
    if [[ -z "$instanceName" ]]; then
      echo "Usage: ssm <instance_name>"
    fi
    if [[ -z "$AWS_PROFILE" ]]; then
      echo "Error: AWS_PROFILE is not set."
    fi
    return 1
  fi

  aws ssm start-session --target $(aws ec2 describe-instances --filters "Name=tag:Name,Values=*$instanceName*" "Name=instance-state-name,Values=running" --query 'Reservations[0].Instances[0].InstanceId' --output text)
}

# ==============================================================================
# Text processing
# ==============================================================================

# Convert encoding to UTF-8
cnv() {
  require cat nkf || return
  for inp in "$@"; do
    local temp="$(mktemp)"
    if [[ -z "$inp" ]] || [[ -z "$temp" ]]; then
      return $(err "Specify argument")
    fi
    cat "$inp" | nkf > "$temp" && mv "$temp" "$inp"
  done
}

# Remove BOM
removeBom() {
  require sed || return
  [[ $# -ne 1 ]] && return $(err 'usage: `removeBom utf16_with_bom_file`')
  sed -i '1s/^\xEF\xBB\xBF//' "$@"
}

# snake_case to camelCase
s2c() {
  [[ $# -ne 0 ]] && return $(err 'usage: `echo snake_case | s2c`')
  awk -F '_' '{ printf $1; for(i=2; i<=NF; i++) {printf toupper(substr($i,1,1)) substr($i,2)}} END {print ""}'
}

# camelCase to snake_case
c2s() {
  [[ $# -ne 0 ]] && return $(err 'usage: `echo camelCase | c2s`')
  sed -E 's/(.)([A-Z])/\1_\2/g' | tr '[A-Z]' '[a-z]'
}

# ==============================================================================
# Web utilities
# ==============================================================================

# wget configurations
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

# ==============================================================================
# System utilities
# ==============================================================================

# Unlock loginctl session
u() {
  require loginctl || return
  loginctl unlock-session "$@"
}

# Clear system cache
clearCache() {
  require sync tee || return
  sync && echo 3 | sudo tee /proc/sys/vm/drop_caches && swapoff -a && swapon -a
}

# Backup with tar and pixz
bakup() {
  require tar pv pixz du xargs awk realpath || return
  local args=() ignores=()
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
  
  [[ ${#args} -ne 2 ]] && return $(err 'usage: `backup srcDir dstDir [-i ignoreDir1 -i ignoreDir2]`')
  local srcDir="${args[1]}"
  local dstDir="${args[2]}"

  mkdir -p "$dstDir"

  local isIncomplete=''
  while read srcNode; do
    [[ "$srcNode" = '.' ]] || [[ "$srcNode" = '..' ]] && continue
    if [[ "$(find /tmp -name 'bakupLog-*' 2>/dev/null)" ]] && [[ ! -f "/tmp/bakupLog-$srcNode" ]]; then
      isIncomplete=1
      echo "restarting from previous operation. ignore $srcNode"
      continue
    else
      touch "/tmp/bakupLog-$srcNode"
    fi
    
    local src="$(realpath "$srcDir/$srcNode")"
    
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
    
    local srcSize="$(du -s "$src" | awk '{print $1}')"
    local srcHash="$(find "$src" | LC_ALL=C sort | md5sum | awk '{print $1}')"
    local dst="$(realpath "$dstDir/$srcNode")-$srcHash-$srcSize.tar.xz"
    
    if [[ -f "$dst" ]] && \
       [[ "$(du -s "$dst" | awk '{print $1}')" -ne 0 ]] && \
       [[ -z "$isIncomplete" ]]; then
      echo "Backup: '$src' is not changed. ignore"
      rm "/tmp/bakupLog-$srcNode"
      continue
    fi
    
    echo "Backing up: '$src' -> '$dst'"
    tar cf - "$src" -P \
      | pv -s $(du -sb "$src" | awk '{print $1}') \
      | pixz -9 -- \
      > "$dst"
    rm "/tmp/bakupLog-$srcNode"
    isIncomplete=''
  done < <($LS -a "$srcDir")
}

# ==============================================================================
# Media utilities
# ==============================================================================

# Combine videos using ffmpeg
combineVideos() {
  require ffmpeg || return
  local argCnt=$# cmd='ffmpeg' firstStr="$1" outFile='' avs='' msg=''
  [[ $argCnt -lt 2 ]] && return $(err 'usage: `combineVideos srcA.mp4 srcB.mp4` makes src.mp4')

  for arg in "$@"; do
    cmd+=" -i $arg"
    outFile=''
    for i in $(seq 0 ${#arg}); do
      if [[ "${arg:$i:1}" = "${firstStr:$i:1}" ]]; then
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
  echo -e "$msg"

  if read -q 'ok?[y/n]'; then
    echo ''
    $cmd
    echo -e "\n[${C_PINK}combineVideos:DONE${C_RESET}]"
  else
    echo -e "\n[${C_PINK}combineVideos:ABORT${C_RESET}]"
    return
  fi
}

# Download audio from YouTube
dl() {
  require yt-dlp ffmpeg || return
  local before=() after=() new_file=''
  while read f; do before+=("$f"); done < <($LS)
  yt-dlp -ci -f 'bestaudio[ext=m4a]' "$@"
  while read f; do after+=("$f"); done < <($LS)
  
  for a in "${after[@]}"; do
    local has_new=1
    for b in "${before[@]}"; do
      if [[ "$b" = "$a" ]]; then
        has_new=
        break
      fi
    done
    if [[ -n "$has_new" ]]; then
      new_file="$a"
      break
    fi
  done
  
  echo "$new_file"
  if [[ -n "$new_file" ]]; then
    local wav="$(echo "$new_file" | sed -e 's|\([^\.]*\)\.\(.*\)|\1.wav|')"
    echo "$wav"
    ffmpeg -i "$new_file" "$wav"
  fi
}

# ==============================================================================
# AI utilities
# ==============================================================================

# ChatGPT API
chatgpt() {
  local api_key="${OPENAI_API_KEY}"
  local model="${OPENAI_DEFAULT_MODEL:-gpt-3.5-turbo}"
  local prompt_text tempfile resp error
  require jq || return
  prompt_text="$(/bin/cat)"
  prompt_text="$(printf '%s' "$prompt_text" | jq -Rs .)"

  if [[ -z "$api_key" ]]; then
    echo "Error: OPENAI_API_KEY is not set." >&2
    return 1
  fi
  
  local data='{"model": "'"$model"'", "messages": [{"role": "user", "content": '"$prompt_text"'}]}'

  tempfile="$(mktemp /tmp/ai-commit-msg.XXXXXX)"
  curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $api_key" \
    -d "$data" \
    > "$tempfile"

  error="$(/bin/cat "$tempfile" | jq -r '.error.message')"
  if [[ "$error" != 'null' ]]; then
    echo "Error: $error" >&2
    return 1
  fi
  /bin/cat "$tempfile" | jq -r '.choices[0].message.content'
}

# AI-powered git commit
commit() {
  local diff st
  st="$(git status)"
  diff="$(git diff --cached)"

  if [[ -z "$diff" ]]; then
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

  message="$(echo "$prompt_text" | chatgpt)"
  local tmpfile="$(mktemp /tmp/ai-commit-msg.XXXXXX)"
  echo "$message" > "$tmpfile"
  git commit --edit -F "$tmpfile"
  rm -f "$tmpfile"
}

# ==============================================================================
# WSL-specific functions
# ==============================================================================

# Remove WSL trash
rmwsltrash() {
  rm -rf -- \(default\) -a -m -u -w Usage: WSL Windows a absolute force format from path path, result to translate with
}

# ==============================================================================
# Platform-specific configurations
# ==============================================================================

# macOS-specific settings
if [[ "$(uname)" = 'Darwin' ]]; then
  alias vim='/opt/homebrew/bin/vim'
  
  source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
  source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi

# Linux X11 - Reset input methods when IME has issues
if type xinput &>/dev/null; then
  while read id; do
    local prop='libinput Accel Speed'
    xinput set-prop "$id" "$(xinput list-props "$id" | grep "$prop (" | head -n 1 | sed -e "s|$prop (\([0-9]*\)).*|\1|")" 1.0
    prop='libinput Natural Scrolling Enabled'
    xinput set-prop "$id" "$(xinput list-props "$id" | grep "$prop (" | head -n 1 | sed -e "s|$prop (\([0-9]*\)).*|\1|")" 0.0
  done < <(xinput | grep 'Magic Trackpad' | sed -e 's|.*id=\([0-9]*\).*|\1|')
fi

# WSL working directory tracking
if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
  if [[ -d "$APPDATA" ]]; then
    precmd() {
      pwd > "$APPDATA/lastpwd"
    }
  fi
fi

# ==============================================================================
# Shell performance
# ==============================================================================

# Compile .zshrc for faster loading
if [[ -f "${HOME}/.zshrc" ]] && \
   ([[ ! -f "${HOME}/.zshrc.zwc" ]] || [[ "${HOME}/.zshrc" -nt "${HOME}/.zshrc.zwc" ]]); then
  zcompile "${HOME}/.zshrc"
fi

# Load NVM (deferred for performance)
if [[ -f /usr/share/nvm/init-nvm.sh ]]; then
  source /usr/share/nvm/init-nvm.sh
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Load additional user configuration
[[ -f "$HOME/.append.sh" ]] && source "$HOME/.append.sh"

