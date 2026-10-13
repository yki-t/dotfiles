#!/usr/bin/env python3
"""mscz の小節ごとのコード・テキスト・反復記号を一覧する。ユーザーが MuseScore で編集した内容を読むときに使う。
usage: read_score.py <score.mscz>
表示: 小節番号 (irregular は pickup)、Re:=RehearsalMark、St:=StaffText (above は五線上、below は五線下、無印はスタイルのデフォルト)、
      H:=Harmony (root|name|bass の tpc)、休符と音符は記法 (n2=2 分休符、g8=G の 8 分音符、c#5/8=オクターブ 4 以外の音符、x8=×符頭、~=タイ)、
      Vo:=反復括弧の始点、T3( )=連符、<=アクセント、%=MeasureRepeat、LB=LayoutBreak、BL=BarLine、start/endRepeat"""
import sys, zipfile, io
import xml.etree.ElementTree as ET
from fractions import Fraction
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mscxlib import event_token  # noqa: E402

z = zipfile.ZipFile(sys.argv[1])
mscx = [n for n in z.namelist() if n.endswith(".mscx")][0]
root = ET.parse(io.BytesIO(z.read(mscx))).getroot()
print("programVersion", root.findtext("programVersion"))
for t in root.iter("metaTag"):
    if t.text:
        print("meta", t.get("name"), "=", t.text)
staff = root.find("Score").find("Staff")
vb = staff.find("VBox")
if vb is not None:
    for tx in vb.findall("Text"):
        print("VBox", tx.findtext("style"), "=", "".join(tx.find("text").itertext()))
NAMES = {13: "F", 14: "C", 15: "G", 16: "D", 17: "A", 18: "E", 19: "B"}


def name(tpc):
    if tpc is None:
        return ""
    t = int(tpc)
    base = NAMES[(t - 13) % 7 + 13]
    acc = (t - 13) // 7
    return base + ("#" * acc if acc > 0 else "b" * -acc)


n = 0
bar_len = Fraction(4, 4)
for m in staff.findall("Measure"):
    ts = m.find("voice/TimeSig")
    if ts is not None:
        bar_len = Fraction(int(ts.findtext("sigN")), int(ts.findtext("sigD")))
    irregular = m.find("irregular") is not None
    if not irregular:
        n += 1
    label = f"bar {n}" if not irregular else "pickup"
    items = []
    for el in m.iter():
        tag = el.tag
        if tag in ("StaffText", "RehearsalMark", "Lyrics", "SystemText", "Tempo", "Marker", "Jump"):
            txt = "".join(el.find("text").itertext()) if el.find("text") is not None else ""
            pl = el.findtext("placement")
            items.append(f"{tag[:2]}:{txt!r}" + (f" {pl}" if pl in ("above", "below") else ""))
        elif tag == "Spanner" and el.get("type") == "Volta" and el.find("Volta") is not None:
            items.append(f"Vo:{el.find('Volta').findtext('beginText', '')!r}")
        elif tag == "Harmony":
            hi = el.find("harmonyInfo")
            if hi is None:
                items.append("H:?")
            else:
                sym = name(hi.findtext("root")) + hi.findtext("name", "")
                if hi.find("bass") is not None:
                    sym += "/" + name(hi.findtext("bass"))
                items.append("H:" + sym)
        elif tag in ("MeasureRepeat", "Rest", "Chord"):
            items.append(event_token(el, bar_len))
        elif tag == "TimeSig":
            items.append(f"TS {el.findtext('sigN')}/{el.findtext('sigD')}")
        elif tag == "BarLine":
            items.append("BL:" + el.findtext("subtype", ""))
        elif tag == "LayoutBreak":
            items.append("LB:" + el.findtext("subtype", ""))
        elif tag in ("startRepeat", "endRepeat"):
            items.append(tag)
        elif tag == "Tuplet":
            items.append(f"T{el.findtext('actualNotes')}(")
        elif tag == "endTuplet":
            items.append(")")
    print(label, " ".join(items))
