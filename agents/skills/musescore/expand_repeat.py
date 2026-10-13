#!/usr/bin/env python3
"""反復の中で回ごとに内容が違う区間を複製し、元の区間に 1 番括弧、複製に 2 番括弧を付ける。
usage: expand_repeat.py <in.mscz> <out.mscz> <first_bar> <last_bar>

- 小節番号は read_score.py の表示番号。複製は区間の直後に入り、以降の小節番号は区間の長さだけ後ろにずれる。
- 複製のコードと歌詞は元のままなので、2 回目の内容は edit_measures.py で書き換える。
- 反復開始、リハーサルマーク、Marker (Segno など)、Jump (D.S. など) は元の区間だけに残す。
  区間に反復終了があると括弧の終わりが決まらないので止める。区間が反復括弧に重なるとき (展開済み) も止める。
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
if i1 + 1 >= len(score.measures):
    raise SystemExit("区間の後に小節が無いので括弧を閉じられない")
span = score.measures[i0: i1 + 1]
if any("<endRepeat>" in m for m in span):
    raise SystemExit("区間に反復終了があるので展開できない")
# 括弧の終端 (<prev> だけの Spanner) は直前の括弧の次の小節に付くので、始点 (<Volta> を持つ) だけを見る
VOLTA_START = re.compile(r'<Spanner type="Volta">\s*<Volta>')
if any(VOLTA_START.search(m) for m in span):
    raise SystemExit("区間に反復括弧が既にあるので展開できない")
# 区間より前から始まる括弧が区間に重なっていても展開済みなので止める (括弧の長さは <next> の measures)
for j, m in enumerate(score.measures[:i0]):
    for sp in re.findall(r'<Spanner type="Volta">.*?</Spanner>', m, flags=re.S):
        n = re.search(r"<next>.*?<measures>(\d+)</measures>", sp, flags=re.S)
        if n and j + int(n.group(1)) > i0:
            raise SystemExit(f"小節 {first} は既にある反復括弧の中なので展開できない")
k = len(span)


def volta_start(n):
    return (f'<Spanner type="Volta"><Volta><endHookType>1</endHookType><beginText>{n}.</beginText>'
            f"<endings>{n}</endings></Volta><next><location><measures>{k}</measures></location></next></Spanner>")


VOLTA_END = f'<Spanner type="Volta"><prev><location><measures>-{k}</measures></location></prev></Spanner>'


def at_voice_start(xml, insert):
    return xml.replace("<voice>", "<voice>" + insert, 1)


# Marker (Segno など) と Jump (D.S. など) は複製すると同じ記号が 2 つになるので、複製には残さない。
# 区間の先頭に直前の括弧の終端 (<prev> だけの Spanner) があると、複製にも入って宙に浮いた終端になるので外す
copy = [re.sub(r"\s*(?:<RehearsalMark>.*?</RehearsalMark>|<Marker>.*?</Marker>|<Jump>.*?</Jump>"
               r'|<Spanner type="Volta">.*?</Spanner>)', "", strip_eid(m), flags=re.S)
        for m in span]
copy[0] = re.sub(r"\s*<startRepeat/>", "", copy[0])
copy[0] = at_voice_start(copy[0], VOLTA_END + volta_start(2))
measures = list(score.measures)
measures[i0] = at_voice_start(measures[i0], volta_start(1))
measures[i1 + 1] = at_voice_start(measures[i1 + 1], VOLTA_END)
measures[i1 + 1: i1 + 1] = copy
score.write(dst, score.rebuild(measures))
print(f"1 番括弧: 小節 {first}〜{last}, 2 番括弧: 小節 {last + 1}〜{last + k}。以降の小節番号は {k} ずれる")
print(dst)
