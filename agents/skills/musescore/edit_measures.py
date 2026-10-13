#!/usr/bin/env python3
"""既存の mscz の小節を記法で書き直す。MuseScore で保存し直した (eid 付きの) ファイルにも使える。
usage: edit_measures.py <in.mscz> <out.mscz> <edits.txt> [--pitch g] [--octave 4]

edits.txt は 1 行 1 小節: `7: F:f8 f8 n2 G:g4` (小節番号は read_score.py の表示番号。# 行と空行は無視)。
  g8 = G の 8 分音符、g#8、c#5/8 = C#5 の 8 分音符 (オクターブ省略時は --octave)、n4 = 4 分休符、n1 = 全休符、
  x8 = ゴースト (×符頭)、o8 = デフォルト音高の音符、a8~a2 = タイ、4. = 付点、d#8< = アクセント、
  T3(b8 b8 b8) = 3 連符 (括弧の中は同じ音価)。
  コードは `F:` を前に置く (`"C (x2 Am)":n2`、`N.C.:n1`、`B:T3(b8 b8 b8)`)。
  メモは ^break (五線の上)、_文字 (五線の下)。`<` や `&` はそのまま書く (XML エスケープはスクリプトが行う)。
行末の `~` (`n4 n8 e8~`) は次の小節の最初の音符へのタイ。次の小節の頭は同じ音高の音符にする (同じ edits.txt で書いてもよい)。
行にコードが 1 つも無ければ元のコード記号を位置ごとに残す。StaffText、RehearsalMark、反復括弧、拍子、終止線は残る。
元の StaffText を消すには行に `-text`、RehearsalMark を消すには `-mark` を置く (`41: -text -mark N.C.:^break n1`)。
"""
import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mscxlib import Score, assemble, event_token, events_xml, parse_line, parse_tokens, parse_voice, harmony_name, sync_cross_ties  # noqa: E402

ap = argparse.ArgumentParser(usage=__doc__, add_help=False)
ap.add_argument("src")
ap.add_argument("dst")
ap.add_argument("edits")
ap.add_argument("--pitch", default="g")
ap.add_argument("--octave", type=int, default=4)
ns = ap.parse_args()
src, dst, edits, pitch, octave = ns.src, ns.dst, ns.edits, ns.pitch, ns.octave

score = Score(src)
for line in Path(edits).read_text(encoding="utf-8").splitlines():
    if not line.strip() or line.lstrip().startswith("#"):
        continue
    bar, tokens = parse_line(line)
    i = score.index(bar)
    bar_len = score.timesig_at(i)
    keep_texts, keep_marks = "-text" not in tokens, "-mark" not in tokens
    tokens = [t for t in tokens if t not in ("-text", "-mark")]
    events, chords, texts = parse_tokens(tokens, bar_len, pitch, octave)
    xml = assemble(score.measures[i], bar_len, events_xml(events, bar_len), chords or None, texts,
                   keep_texts=keep_texts, keep_marks=keep_marks)
    score.replace(i, xml)
    shown = []
    for _, kind, el in parse_voice(xml, bar_len):
        if kind == "harmony":
            shown.append(harmony_name(el))
        elif kind == "event":
            shown.append(event_token(el, bar_len))
        elif kind == "tuplet":
            shown.append(f"T{el.findtext('actualNotes')}(")
        elif kind == "tuplet_end":
            shown.append(")")
    print(f"bar {bar}:", " ".join(shown))
sync_cross_ties(score)
score.write(dst)
print(dst)
