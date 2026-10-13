#!/usr/bin/env python3
"""区間の改行 (LayoutBreak line) を n 小節ごとに付け直す。
usage: breaks.py <in.mscz> <out.mscz> <first-last:n> ...   例: breaks.py in.mscz out.mscz 1-36:4 37-44:2

- 小節番号は read_score.py の表示番号。区間の中の line の改行をすべて外し、区間の先頭から n 小節ごとと区間の最後の小節に付ける。
- page、section、nobreak の LayoutBreak は触らない。区間の外も触らない。
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mscxlib import Score  # noqa: E402

if len(sys.argv) < 4:
    raise SystemExit(__doc__)
src, dst = sys.argv[1:3]
score = Score(src)
LINE_BREAK = re.compile(r"\s*<LayoutBreak>\s*(?:<eid>[^<]*</eid>\s*)?<subtype>line</subtype>\s*</LayoutBreak>", re.S)


def add_break(xml):
    return re.sub(r"(<Measure(?: [^>]*)?>)", r"\1<LayoutBreak><subtype>line</subtype></LayoutBreak>", xml, count=1)


for arg in sys.argv[3:]:
    m = re.fullmatch(r"(\d+)-(\d+):(\d+)", arg)
    if not m:
        raise SystemExit(f"区間の書式は first-last:n: {arg!r}")
    first, last, n = map(int, m.groups())
    if last < first or n < 1:
        raise SystemExit(f"区間が不正: {arg!r}")
    i0, i1 = score.index(first), score.index(last)
    for i in range(i0, i1 + 1):
        xml = LINE_BREAK.sub("", score.measures[i])
        if (i - i0 + 1) % n == 0 or i == i1:
            xml = add_break(xml)
        score.replace(i, xml)
    print(f"小節 {first}〜{last}: {n} 小節ごとに改行")
score.write(dst)
print(dst)
