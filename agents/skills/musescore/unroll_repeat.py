#!/usr/bin/env python3
"""反復 (反復開始〜反復終了) を展開し、回ごとに書き下す。expand_repeat.py (括弧を付ける) の逆。
usage: unroll_repeat.py <in.mscz> <out.mscz> <first_bar> <last_bar>

- first_bar に反復開始、last_bar に反復終了があること。小節番号は read_score.py の表示番号。
- 反復終了で終わる 1 番括弧があれば、2 回目はその手前までの複製。2 番括弧が last_bar の次にあれば、その括弧記号は外して本文に残す。
- 回数は反復終了の数 (通常 2)。複製は last_bar の直後に入り、以降の小節番号は複製の長さだけ後ろにずれる。
- 複製のリハーサルマークは `2A`、`2B` (3 回目は `3A`) にする。Marker (Segno など) と Jump (D.S. など) は複製に残さない。
- 歌詞 (StaffText) は `2) ` で始まるものを 2 回目、それ以外を 1 回目の歌詞とみなし、各回に分けて `2) ` を外す。
  1 つの StaffText に 1 番と 2 番が同居している場合は分けられないので、手で直す。
- 1 回目の最後と各複製の最後の小節に改行が無ければ付ける (次の回と次のセクションが段の先頭に来るように)。
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mscxlib import Score, strip_eid  # noqa: E402

if len(sys.argv) != 5:
    raise SystemExit(__doc__)
src, dst = sys.argv[1:3]
first, last = int(sys.argv[3]), int(sys.argv[4])
score = Score(src)
i0, i1 = score.index(first), score.index(last)
if i1 < i0:
    raise SystemExit("last_bar は first_bar 以上にする")
if "<startRepeat/>" not in score.measures[i0]:
    raise SystemExit(f"小節 {first} に反復開始が無い")
end = re.search(r"<endRepeat>(\d+)</endRepeat>", score.measures[i1])
if not end:
    raise SystemExit(f"小節 {last} に反復終了が無い")
times = int(end.group(1))
if any("<endRepeat>" in m or "<startRepeat/>" in m for m in score.measures[i0 + 1: i1]):
    raise SystemExit("区間の途中に反復記号があるので展開できない")

VOLTA = re.compile(r'\s*<Spanner type="Volta">.*?</Spanner>', re.S)
VOLTA_START = re.compile(r'<Spanner type="Volta">\s*(?:<eid>[^<]*</eid>\s*)?<Volta>.*?<measures>(\d+)</measures>', re.S)
STAFF_TEXT = re.compile(r"\s*<StaffText>.*?</StaffText>", re.S)
VERSE = re.compile(r"<text>(\d)\)\s*")

measures = list(score.measures)


def volta_len(i):
    m = VOLTA_START.search(measures[i])
    return int(m.group(1)) if m else 0


# 1 番括弧: 区間の中で始まり反復終了で終わるもの。2 回目の複製はその手前まで
copy_end = i1
k1 = next((volta_len(i) for i in range(i0, i1 + 1) if volta_len(i) and i + volta_len(i) - 1 == i1), 0)
if k1:
    copy_end = i1 - k1
for i in range(i0, i1 + 1):
    if volta_len(i) and i + volta_len(i) - 1 != i1:
        raise SystemExit(f"小節 {score.numbers()[i]} の反復括弧が反復終了で終わらないので展開できない")
# 外す括弧: 1 番括弧と、last_bar の次から始まる 2 番括弧。終点は括弧の次の小節にある
remove = set()
if k1:
    remove.update(range(i1 - k1 + 1, i1 + 2))
k2 = volta_len(i1 + 1) if i1 + 1 < len(measures) else 0
if k2:
    remove.update(range(i1 + 1, i1 + 2 + k2))
for i in remove:
    if i < len(measures):
        measures[i] = VOLTA.sub("", measures[i])
measures[i0] = re.sub(r"\s*<startRepeat/>", "", measures[i0])
measures[i1] = re.sub(r"\s*<endRepeat>\d+</endRepeat>", "", measures[i1])


def verse_of(st):
    m = VERSE.search(st)
    return int(m.group(1)) if m else 1


def keep_verse(xml, v):
    """StaffText のうち v 番の歌詞だけ残し、番号の接頭辞を外す。"""
    def sub(m):
        st = m.group(0)
        if verse_of(st) != v:
            return ""
        return VERSE.sub("<text>", st)
    return STAFF_TEXT.sub(sub, xml)


def add_break(xml):
    if "<subtype>line</subtype>" in xml:
        return xml
    return re.sub(r"(<Measure(?: [^>]*)?>)", r"\1<LayoutBreak><subtype>line</subtype></LayoutBreak>", xml, count=1)


span = measures[i0: copy_end + 1]
copies = []
for v in range(2, times + 1):
    copy = []
    for m in span:
        x = re.sub(r"\s*(?:<Marker>.*?</Marker>|<Jump>.*?</Jump>)", "", strip_eid(m), flags=re.S)
        x = re.sub(r"(<RehearsalMark>\s*<text>)([^<]*)", lambda mm: f"{mm.group(1)}{v}{mm.group(2)}", x)
        copy.append(keep_verse(x, v))
    copy[-1] = add_break(copy[-1])
    copies.extend(copy)
for i in range(i0, i1 + 1):
    measures[i] = keep_verse(measures[i], 1)
measures[i1] = add_break(measures[i1])
measures[i1 + 1: i1 + 1] = copies
score.write(dst, score.rebuild(measures))
n = len(span)
print(f"{times} 回に展開: 1 回目 小節 {first}〜{last}、"
      + "、".join(f"{v} 回目 小節 {last + 1 + n * (v - 2)}〜{last + n * (v - 1)}" for v in range(2, times + 1))
      + f"。以降の小節番号は {n * (times - 1)} ずれる")
print(dst)
