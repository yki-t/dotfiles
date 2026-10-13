"""コード譜 (リードシート) の <Measure> 列を作る。gen_chart.py と append_chart.py が使う。

spec は次の属性を持つ Python モジュール (spec_example.py を参照)。
  SECTIONS: [(mark, "F G C.Em | ..."), ...]
            空白区切りで 1 小節。"." で半小節に分ける (3 つなら 4 分 + 4 分 + 2 分ではなく 1 拍ずつ)。
            "N.C." は StaffText "break" 付きの N.C.、"|" は読みやすさのためで無視する。
            mark はセクション先頭の RehearsalMark ("" なら無し)。
  LYRICS:   {小節 index: 歌詞}  五線の下の StaffText として置く
  BREAKS:   改行を入れる小節 index の集合。改行はその小節の後に入る (段の最後の小節に付ける)。
            省略時は 4 小節ごと
  TEXTS:    {index: StaffText}  N.C. の自動 "break" を含めて置き換える ("" で消す)
  IRREGULAR: 小節番号に数えない index の集合 (ピックアップ小節)
index は 0 始まりで、SECTIONS を平らに並べた順。
"""
import re

TPC = {"F": 13, "C": 14, "G": 15, "D": 16, "A": 17, "E": 18, "B": 19}


def tpc(root):
    m = re.fullmatch(r"([A-G])([#b]?)", root)
    return TPC[m.group(1)] + {"": 0, "#": 7, "b": -7}[m.group(2)]


def harmony(sym):
    if sym == "N.C.":
        return "<Harmony><harmonyInfo><name>N.C.</name></harmonyInfo></Harmony>"
    m = re.fullmatch(r"([A-G][#b]?)([^/]*)(?:/([A-G][#b]?))?", sym)
    if m is None:
        raise ValueError(f"コード記号を読めない: {sym!r}")
    root, name, bass = m.groups()
    s = f"<harmonyInfo><root>{tpc(root)}</root>"
    if name:
        s += f"<name>{name}</name>"
    if bass:
        s += f"<bass>{tpc(bass)}</bass>"
    return f"<Harmony>{s}</harmonyInfo></Harmony>"


DUR = {4: ("measure", "<duration>4/4</duration>"), 2: ("half", ""), 1: ("quarter", "")}


def rest(beats):
    t, extra = DUR[beats]
    return f"<Rest><durationType>{t}</durationType>{extra}</Rest>"


def bars(spec):
    return spec.replace("|", " ").split()


def build(SPEC, first=True, end=True):
    """<Measure> 文字列の列を返す。first=False は追記用で調号・拍子を書かない。end=False は終止線を付けない。"""
    measures = []
    for mark, spec_str in SPEC.SECTIONS:
        prev = None
        for i, b in enumerate(bars(spec_str)):
            syms = [b] if b == "N.C." else b.split(".")
            chords = [(s, 4 // len(syms)) for s in syms]
            # 同じ 1 コードの小節が続いたら % (MeasureRepeat) にする
            same = (len(syms) == 1 and prev == b and b != "N.C.")
            measures.append({"chords": chords, "mark": mark if i == 0 else "",
                             "text": "break" if b == "N.C." else "", "repeat": same})
            prev = b
    breaks = getattr(SPEC, "BREAKS", None)
    for i, m in enumerate(measures):
        m["brk"] = (i in breaks) if breaks is not None else (i > 0 and i % 4 == 3)
        m["lyric"] = getattr(SPEC, "LYRICS", {}).get(i, "")
        m["irregular"] = i in getattr(SPEC, "IRREGULAR", set())
        if i in getattr(SPEC, "TEXTS", {}):
            m["text"] = SPEC.TEXTS[i]
    measures[-1]["brk"] = False

    xml = []
    for i, m in enumerate(measures):
        body = []
        if i == 0 and first:
            body.append("<KeySig><concertKey>0</concertKey></KeySig>"
                        "<TimeSig><sigN>4</sigN><sigD>4</sigD></TimeSig>")
        if m["mark"]:
            body.append(f"<RehearsalMark><text>{m['mark']}</text></RehearsalMark>")
        if m["text"]:
            body.append(f"<StaffText><text>{m['text']}</text></StaffText>")
        if m["lyric"]:
            body.append(f"<StaffText><placement>below</placement><text>{m['lyric']}</text></StaffText>")
        head = ""
        if m["irregular"]:
            head += "<irregular>1</irregular>"
        if m["repeat"]:
            head += "<measureRepeatCount>1</measureRepeatCount>"
            body.append("<MeasureRepeat><subtype>1</subtype><durationType>measure</durationType>"
                        "<duration>4/4</duration></MeasureRepeat>")
        else:
            for sym, beats in m["chords"]:
                body.append(harmony(sym) + rest(beats))
        if m["brk"]:
            head += "<LayoutBreak><subtype>line</subtype></LayoutBreak>"
        if i == len(measures) - 1 and end:
            body.append("<BarLine><subtype>end</subtype></BarLine>")
        xml.append(f"<Measure>{head}<voice>{''.join(body)}</voice></Measure>")
    return xml


def load_spec(path):
    import importlib.util
    spec = importlib.util.spec_from_file_location("spec", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module
