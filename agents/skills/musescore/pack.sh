#!/bin/sh
# mscz と展開ディレクトリを往復する。mscx を手で直すときに使う。
# usage: pack.sh unpack <score.mscz> <dir>   (dir は無いか空のディレクトリ)
#        pack.sh pack <dir> <score.mscz>
set -e
case "$1" in
  unpack)
    [ -f "$2" ] || { echo "mscz が無い: $2" >&2; exit 1; }
    mkdir -p "$3"
    # 前の展開が残っていると mscx が 2 つになり、pack で両方が入る
    [ -z "$(ls -A "$3")" ] || { echo "ディレクトリが空でない: $3" >&2; exit 1; }
    unzip -o -q "$2" -d "$3"
    ;;
  pack)
    [ -d "$2" ] || { echo "ディレクトリが無い: $2" >&2; exit 1; }
    out=$(cd "$(dirname "$3")" && pwd)/$(basename "$3")
    tmp="$out.tmp.$$"
    rm -f "$tmp"
    (cd "$2" && zip -q -r -X "$tmp" .)
    mv -f "$tmp" "$out"
    ;;
  *)
    echo "usage: pack.sh unpack <score.mscz> <dir> | pack.sh pack <dir> <score.mscz>" >&2
    exit 1
    ;;
esac
