#!/usr/bin/env python3
"""既存の mscz の末尾に spec の小節を追記する。MuseScore で保存し直した (eid 付きの) ファイルにも使える。
usage: append_chart.py <spec.py> <in.mscz> <out.mscz>
spec の TITLE/SUBTITLE は不要。index 0 が追記する最初の小節。"""
import re, sys, zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from chartlib import build, load_spec

SPEC = load_spec(sys.argv[1])
src, dst = sys.argv[2], sys.argv[3]
zin = zipfile.ZipFile(src)
names = zin.namelist()
mscx_name = [n for n in names if n.endswith(".mscx")][0]
x = zin.read(mscx_name).decode()

# 最後の小節: 終止線を外し、追記部を新しい段から始めるため改行を入れる
last = x.rindex("<Measure>")
tail = x[last:]
tail, n = re.subn(r"\s*<BarLine>.*?</BarLine>", "", tail, count=1, flags=re.S)
if n != 1:
    raise SystemExit("最後の小節に終止線が無い")
if "<LayoutBreak>" not in tail:
    tail = tail.replace("<Measure>", "<Measure><LayoutBreak><subtype>line</subtype></LayoutBreak>", 1)
x = x[:last] + tail

new = build(SPEC, first=False)
i = x.rindex("</Staff>")
x = x[:i] + "\n".join(new) + "\n" + x[i:]
with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zout:
    for name in names:
        zout.writestr(name, x.encode() if name == mscx_name else zin.read(name))
print(dst, "appended", len(new), "measures")
