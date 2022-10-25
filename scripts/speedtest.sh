#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"&>/dev/null &&pwd)" # SCRIPT_DIR
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $@" >&2
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
[ $ok ] && require speedtest-cli

dir="$DIR/../data"
dst="$dir/speedtests.csv"
mkdir -p "$dir"
if [ ! -f "$dst" ]; then
  echo "StartedAt,CompletedAt,$(speedtest-cli --csv-header)" | tee "$dst"
fi

started_at="$(date '+%Y-%m-%d %H:%M:%S')"
result=$(speedtest-cli --csv --secure)
completed_at=$(date '+%Y-%m-%d %H:%M:%S')
echo "$started_at,$completed_at,$result" | tee -a "$dst"

