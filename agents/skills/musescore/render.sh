#!/bin/sh
# flatpak の MuseScore で mscz を PNG/PDF に変換する。
# usage: render.sh <score.mscz> <out.png|out.pdf>
# PNG はページごとに out-1.png, out-2.png ... になる。
# このセッションには DISPLAY が無いので xvfb-run を使う (QT_QPA_PLATFORM=offscreen は MuseScore が無視する)。
# flatpak は home 以外に書けないので、出力先を --filesystem で許可する。
set -e
out_dir=$(cd "$(dirname "$2")" && pwd)
xvfb-run -a -s "-screen 0 1280x1024x24" \
  flatpak run --filesystem="$out_dir" org.musescore.MuseScore "$1" -o "$2" 2>&1 \
  | grep -viE 'session management|^$' || true
ls "${2%.*}"*
