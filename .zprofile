#!/usr/bin/env zsh
# .zprofile - Login shell initialization
# This file is sourced once when starting a login shell

# Timezone
export TZ='Asia/Tokyo'

# Initialize PATH additions
paths=''

# ==============================================================================
# Platform-specific settings
# ==============================================================================

# macOS settings
if [[ "$(uname)" = 'Darwin' ]]; then
  export LC_CTYPE='ja_JP.UTF-8'
  
  # Homebrew initialization
  if [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"  # Intel CPU
  fi
  if [[ -f /opt/homebrew/bin/brew ]] && [[ "$(uname -a)" = *ARM64* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon (M1) CPU
  fi
  
  # VS Code command
  paths+=":/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  
  # Python 2.7 (legacy)
  paths+=":/Library/Frameworks/Python.framework/Versions/2.7/bin"
  
  # Homebrew settings
  export HOMEBREW_NO_AUTO_UPDATE=1
  export HOMEBREW_NO_ANALYTICS=1
  
  # Python pip packages
  local pyver="$(/bin/ls -rv "$HOME/Library/Python/" 2>/dev/null | head -n 1)"
  if [[ -d "$HOME/Library/Python/${pyver}/bin" ]]; then
    paths+=":$HOME/Library/Python/${pyver}/bin"
  fi
fi

# ==============================================================================
# Development tools
# ==============================================================================

# Tor
[[ -f "${HOME}/.tor" ]] && paths+=":${HOME}/opt/tor"

# Rust
[[ -d "${HOME}/.cargo" ]] && paths+=":${HOME}/.cargo/bin"

# Ruby (rbenv)
if [[ -d "${HOME}/.rbenv/bin" ]]; then
  paths+=":${HOME}/.rbenv/bin"
  export PATH="${HOME}/.rbenv/bin:$PATH"
  eval "$(rbenv init --no-rehash -)"
fi

# Node.js - nvm
export NVM_DIR="$HOME/.config/nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Node.js - npm/yarn
if type npm &>/dev/null; then
  export NO_UPDATE_NOTIFIER=1
  [[ -f "${HOME}/.local/bin/npm" ]] && alias npm="${HOME}/.local/bin/npm"
fi

if type yarn &>/dev/null; then
  export NODE_PATH="${HOME}/.yarn/bin"
  paths+=":${HOME}/.local/bin"
  if [[ $UID -eq 0 ]]; then
    paths+=":/usr/local/share/.config/yarn/global/node_modules/.bin"
  else
    paths+=":${HOME}/.config/yarn/global/node_modules/.bin"
  fi
fi

# pnpm
export PNPM_HOME="/home/yuki/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# PHP Composer
if type composer &>/dev/null; then
  [[ -d "${HOME}/.config/composer/vendor/bin" ]] && paths+=":${HOME}/.config/composer/vendor/bin"
fi

# Java
if type java &>/dev/null && type update-alternatives &>/dev/null; then
  export JAVA_HOME=$(update-alternatives --query javac 2>/dev/null | sed -n -e 's/Value: *\(.*\)\/bin\/javac/\1/p')
  export DERBY_HOME="$JAVA_HOME/db"
  export J2SDKDIR="$JAVA_HOME"
  export J2REDIR="$JAVA_HOME/jre"
  paths+=":$JAVA_HOME/bin:$DERBY_HOME/bin:$J2REDIR/bin"
fi

# Android SDK
if [[ -d "${HOME}/Android" ]]; then
  export NDK_HOME="${HOME}/Android/android-ndk-r20"
  paths+=":${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin"
fi

# Flutter
[[ -d "${HOME}/.pub-cache/bin" ]] && paths+=":${HOME}/.pub-cache/bin"

# C/C++ compilers
if type gcc &>/dev/null; then
  export CC="$(which gcc)"
  export CMAKE_C_COMPILER="$(which gcc)"
fi

if type g++ &>/dev/null; then
  export CXX="$(which g++)"
  export CMAKE_CXX_COMPILER="$(which g++)"
fi

# Python (pyenv)
if [ -f "$HOME/.pyenv/bin/pyenv" ]; then
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# Bun
if type bun &>/dev/null; then
  export BUN_INSTALL="${HOME}/.bun"
  paths+=":${BUN_INSTALL}/bin"
fi

# PKG_CONFIG
if [[ -e /usr/lib/pkgconfig ]]; then
  export PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig"
fi

# Google Cloud SDK (gsutil)
paths+=":$HOME/gsutil"

# Nix package manager
if [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
  source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Claude Code bash timeout
export BASH_DEFAULT_TIMEOUT_MS=600000

# ==============================================================================
# Terminal and display settings
# ==============================================================================

# LS colors configuration
ls_colors='rs=0:di=0;95:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:'
ls_colors+='or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:'
ls_colors+='*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:'
ls_colors+='*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:'
ls_colors+='*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:'
ls_colors+='*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:'
ls_colors+='*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:'
ls_colors+='*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:'
ls_colors+='*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:'
ls_colors+='*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:'
ls_colors+='*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:'
ls_colors+='*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:'
ls_colors+='*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:'
ls_colors+='*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:'
ls_colors+='*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:'
ls_colors+='*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:'
export LS_COLORS="$ls_colors"

# exa colors
if type exa &>/dev/null; then
  local exaGen='da=1;30:di=1;35:uu=33:'
  local exaMov='*.mkv=1;32:*.mp4=1;32:*.mpeg4=1;32:'
  local exaImg='*.mp3=1;36:*.wav=1;36:*.flac=1;32:'
  export EXA_COLORS="${exaGen}${exaMov}${exaImg}"
fi

# ==============================================================================
# Shell configuration
# ==============================================================================

# History settings
if [ -d /opt/history ]; then
  export HISTFILE="/opt/history/.zsh_history_$$"
  export ETERNAL_HISTORY="/opt/history/.zsh_eternal_history"
else
  export HISTFILE="/tmp/.zsh_history"
  export ETERNAL_HISTORY="/tmp/.zsh_eternal_history"
fi
export HISTSIZE=10000
export SAVEHIST=10000

# Session-independent history options
setopt NO_SHARE_HISTORY        # Don't share history between sessions
setopt APPEND_HISTORY          # Append to history file
setopt INC_APPEND_HISTORY      # Write to history file immediately
setopt HIST_IGNORE_DUPS        # Don't record duplicates in session
setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicate entries
setopt HIST_FIND_NO_DUPS       # Don't display duplicates when searching
setopt HIST_REDUCE_BLANKS      # Remove extra blanks from commands
setopt HIST_VERIFY             # Show command before executing from history
setopt EXTENDED_HISTORY        # Add timestamps to history

# Save every command to eternal history using preexec hook
preexec() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$ETERNAL_HISTORY"
}

# Editor settings
export GIT_EDITOR='vim'
export EDITOR='vim'
export VISUAL='vim'
export XDG_CONFIG_HOME="${HOME}/.config"

# IME configuration (Mozc & fcitx)
export XIM_PROGRAM='fcitx'
export XIM='fcitx'
export GTK_IM_MODULE='fcitx'
export QT_IM_MODULE='fcitx'
export XMODIFIERS='@im=fcitx'

# Docker settings
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

# Terminal colors
export C_PINK='\033[35m'
export C_CYAN='\033[36m'
export C_RESET='\033[0m'

# ==============================================================================
# Database connections (local development)
# ==============================================================================

# MySQL/MariaDB
export MYSQL_PWD='password'
export MYSQL='mariadb -uusername -hlocalhost --protocol tcp --binary-as-hex -A database'
export MYSQLDUMP='mariadb-dump -uusername -hlocalhost --protocol tcp --no-tablespaces database'

# PostgreSQL
export PGPASSWORD='password'
export PSQL='psql -P pager=off -U username -h localhost database'

# SQLite
export SQL='sqlite3 -table -header'

# Cloud Spanner emulator
_SPANNER() {
  local q='' t='' h=''
  while getopts "e:th" opt; do
    case $opt in
      e) q="$OPTARG";;
      t) t=1;;
      h) h=1;;
    esac
  done
  
  local cmd=(docker exec -it $(docker ps --filter 'name=spanner-cli' --format '{{.Names}}') spanner-cli -p project -i instance -d database)
  
  if [[ -n "$h" ]]; then
    cmd+=('-h')
    "${cmd[@]}"
    return
  fi
  
  [[ -n "$t" ]] && cmd+=('-t')
  [[ -n "$q" ]] && cmd+=(-e "$q")
  
  echo "${cmd[@]}"
  "${cmd[@]}"
}
export SPANNER='_SPANNER'

# ==============================================================================
# Account settings
# ==============================================================================

export GITHUB_USER='yki-t'

# ==============================================================================
# Application settings
# ==============================================================================

# Disable Nuxt telemetry
export NUXT_TELEMETRY_DISABLED=1

# ==============================================================================
# Platform-specific initialization
# ==============================================================================

# Linux X11 configuration
if [[ -n "$DISPLAY" ]]; then
  # Load Xmodmap if available
  if type xmodmap &>/dev/null; then
    [[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
    [[ -f "${HOME}/.Xmodmap" ]] && xmodmap "${HOME}/.Xmodmap"
    
    if type realpath &>/dev/null; then
      [[ -f "$(realpath ~/.Xmodmap 2>/dev/null)" ]] && xmodmap ~/.Xmodmap
    fi
  fi
  
  # Load private settings if available
  if type realpath &>/dev/null; then
    local DIR="$(cd "$(dirname "$(realpath -- "$0" 2>/dev/null)")" &>/dev/null && pwd)"
    [[ -f "$DIR/.private.sh" ]] && source "$DIR/.private.sh"
  fi
fi

# WSL-specific settings
if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
  export APPDATA="$(wslpath "$(cmd.exe /c "echo %APPDATA%" 2>/dev/null | tr -d '\r')")"
  export STARTUP="$APPDATA/Microsoft/Windows/Start Menu/Programs/Startup"
  export WIN="$(echo "$APPDATA" | sed -e 's|/AppData/Roaming||')"
fi

# ==============================================================================
# PATH finalization
# ==============================================================================

# Add local bin directory
paths+=":${HOME}/.local/bin"

# Append accumulated paths to PATH if not already present
[[ "$PATH" != *$paths* ]] && export PATH="$PATH$paths"

# Load additional local settings if available
[[ -f "$HOME/.append.sh" ]] && source "$HOME/.append.sh"