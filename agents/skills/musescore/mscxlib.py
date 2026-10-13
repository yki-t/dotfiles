"""mscz を小節単位で読み書きする共通部品。edit_measures.py、halftime.py、expand_repeat.py、read_score.py が使う。

- 小節番号は read_score.py と同じ (irregular は数えない、1 始まり)。
- 編集した小節だけ voice を書き直し、他の小節と score_style.mss などの同梱ファイルはそのまま残す。
- 音符の記法 (ユーザーの指示に合わせる): `g8` = G の 8 分音符、`g#8`、`c#5/8` = C#5 の 8 分音符 (オクターブ省略時は --octave)、
  `n4` = 4 分休符、`x8` = ゴースト (×符頭)、`o8` = デフォルト音高の 8 分音符、`a8~a2` = タイ、
  行末の `~` = 次の小節の最初の音符へのタイ (sync_cross_ties で付け直す)、`4.` = 付点、`d#8<` = アクセント、`T3(b8 b8 b8)` = 3 連符。
  コードは `F:` を前に置く (`F:f8`、`"C (x2 Am)":n2`、`N.C.:n1`、`B:T3(b8 b8 b8)`)。メモは `^break` (五線の上)、`_メモ` (五線の下)。
"""
import html
import os
import re
import shlex
import sys
import tempfile
import zipfile
import xml.etree.ElementTree as ET
from fractions import Fraction
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from chartlib import harmony as harmony_xml, tpc  # noqa: E402

MEASURE_RE = re.compile(r"<Measure(?: [^>]*)?>.*?</Measure>", re.S)
VOICE_RE = re.compile(r"<voice>.*?</voice>", re.S)
DUR_NAME = {1: "whole", 2: "half", 4: "quarter", 8: "eighth", 16: "16th", 32: "32nd"}
DUR_NUM = {v: k for k, v in DUR_NAME.items()}
DUR_NUM["measure"] = 1
TPC_LETTER = {13: "F", 14: "C", 15: "G", 16: "D", 17: "A", 18: "E", 19: "B"}
SEMI = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
DEFAULT_OCTAVE = 4


# ---------- mscz の入出力 ----------

class Score:
    def __init__(self, path):
        self.zin = zipfile.ZipFile(path)
        self.names = self.zin.namelist()
        self.mscx = [n for n in self.names if n.endswith(".mscx")][0]
        self.text = self.zin.read(self.mscx).decode()
        self.measures = [m.group(0) for m in MEASURE_RE.finditer(self.text)]
        self._spans = [(m.start(), m.end()) for m in MEASURE_RE.finditer(self.text)]
        # 小節の間にある文字列 (途中の VBox、Staff の区切りなど)。小節数が変わらない編集ではそのまま戻す
        self._gaps = [self.text[a[1]:b[0]] for a, b in zip(self._spans, self._spans[1:])]
        self._count = len(self.measures)

    def numbers(self):
        """index -> 表示上の小節番号 (irregular は None)"""
        out, n = [], 0
        for m in self.measures:
            if "<irregular>" in m:
                out.append(None)
            else:
                n += 1
                out.append(n)
        return out

    def index(self, bar):
        nums = self.numbers()
        if bar not in nums:
            raise SystemExit(f"小節 {bar} が無い (1〜{max(x for x in nums if x)})")
        return nums.index(bar)

    def timesig_at(self, i):
        """index i の小節の拍子 (Fraction)。手前の TimeSig を引き継ぐ。"""
        sig = Fraction(4, 4)
        for m in self.measures[: i + 1]:
            t = re.search(r"<TimeSig>.*?<sigN>(\d+)</sigN>\s*<sigD>(\d+)</sigD>", m, re.S)
            if t:
                sig = Fraction(int(t.group(1)), int(t.group(2)))
        return sig

    def replace(self, i, xml):
        self.measures[i] = xml

    def rebuild(self, measures=None):
        """measures (省略時は self.measures) で小節列を差し替えた mscx 文字列を返す。
        小節数が変わるときは、小節の間に小節以外の要素があると位置を決められないので止める。"""
        ms = self.measures if measures is None else measures
        head = self.text[: self._spans[0][0]]
        tail = self.text[self._spans[-1][1]:]
        if len(ms) == self._count:
            gaps = self._gaps
        else:
            if any(g.strip() for g in self._gaps):
                raise SystemExit("小節の間に小節以外の要素があるので、小節数を変える操作はできない")
            gaps = ["\n      "] * (len(ms) - 1)
        return head + "".join(m + g for m, g in zip(ms, gaps)) + ms[-1] + tail

    def write(self, dst, text=None):
        text = self.rebuild() if text is None else text
        write_zip(dst, self.names, lambda name: text.encode() if name == self.mscx else self.zin.read(name))

    def style(self, key):
        m = re.search(rf"<{key}>([^<]*)</{key}>", self.zin.read("score_style.mss").decode())
        return m.group(1) if m else None


def write_zip(dst, names, content):
    """同じディレクトリの一時ファイルに書いてから置き換える。入力と出力が同じパスでも入力を壊さない。"""
    d = os.path.dirname(os.path.abspath(dst))
    fd, tmp = tempfile.mkstemp(prefix=".mscz-", dir=d)
    os.close(fd)
    # mkstemp は 0600 で作るので、置き換え後も元のファイルと同じ権限にする
    if os.path.exists(dst):
        mode = os.stat(dst).st_mode & 0o777
    else:
        umask = os.umask(0)
        os.umask(umask)
        mode = 0o666 & ~umask
    try:
        with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
            for name in names:
                zout.writestr(name, content(name))
        os.chmod(tmp, mode)
        os.replace(tmp, dst)
    finally:
        if os.path.exists(tmp):
            os.remove(tmp)


def set_style(src, dst, **values):
    """score_style.mss の値を書き換えて dst に保存する (他のファイルはそのまま)。"""
    zin = zipfile.ZipFile(src)
    mss = zin.read("score_style.mss").decode()
    for k, v in values.items():
        mss, n = re.subn(rf"<{k}>[^<]*</{k}>", f"<{k}>{v}</{k}>", mss)
        if n != 1:
            raise SystemExit(f"score_style.mss に {k} が無い")
    write_zip(dst, zin.namelist(), lambda name: mss.encode() if name == "score_style.mss" else zin.read(name))


# ---------- 小節の分解 ----------

def strip_eid(xml):
    return re.sub(r"\s*<eid>[^<]*</eid>", "", xml)


def attrs(measure_xml):
    """<voice> の外にある要素 (startRepeat、endRepeat、LayoutBreak、irregular、measureRepeatCount)"""
    head = measure_xml[: measure_xml.index("<voice>")]
    body = re.sub(r"^<Measure(?: [^>]*)?>", "", head).strip()
    return strip_eid(body)


def measure_open_tag(measure_xml):
    return re.match(r"<Measure(?: [^>]*)?>", measure_xml).group(0)


def duration_of(el, bar_len):
    dt = el.findtext("durationType")
    if dt == "measure":
        d = el.findtext("duration")
        return Fraction(d) if d else bar_len
    frac = Fraction(1, DUR_NUM[dt])
    dots = int(el.findtext("dots") or 0)
    return frac * (2 - Fraction(1, 2 ** dots))


def parse_voice(measure_xml, bar_len):
    """voice の子要素を (tick, 種別, Element) の列にする。
    種別: head / mark / spanner / harmony / text (StaffText) / other (Tempo、Dynamic など) / event / barline /
          tuplet (連符の始まり) / tuplet_end
    Marker (Segno など) と Jump (D.S. など) は voice ではなく Measure の直下にあるので、ここには出ない (attrs() に入る)。"""
    v = VOICE_RE.search(measure_xml)
    root = ET.fromstring(v.group(0))
    tick = Fraction(0)
    ratio = Fraction(1)
    items = []
    for el in root:
        tag = el.tag
        if tag == "Tuplet":
            # 連符の中の音符は名目の音価のまま書かれ、実長は normalNotes/actualNotes 倍
            ratio = Fraction(int(el.findtext("normalNotes")), int(el.findtext("actualNotes")))
            items.append((tick, "tuplet", el))
        elif tag == "endTuplet":
            ratio = Fraction(1)
            items.append((tick, "tuplet_end", el))
        elif tag in ("KeySig", "TimeSig", "Clef"):
            items.append((tick, "head", el))
        elif tag == "location":
            tick += Fraction(el.findtext("fractions"))
        elif tag == "RehearsalMark":
            items.append((tick, "mark", el))
        elif tag == "Spanner":
            items.append((tick, "spanner", el))
        elif tag == "Harmony":
            items.append((tick, "harmony", el))
        elif tag == "StaffText":
            items.append((tick, "text", el))
        elif tag in ("Rest", "Chord"):
            items.append((tick, "event", el))
            tick += duration_of(el, bar_len) * ratio
        elif tag == "MeasureRepeat":
            items.append((tick, "event", el))
            tick += bar_len
        elif tag == "BarLine":
            items.append((tick, "barline", el))
        else:
            items.append((tick, "other", el))
    return items


def harmony_name(el):
    hi = el.find("harmonyInfo")
    if hi is None:
        return "?"
    root = hi.findtext("root")
    sym = (tpc_name(root) if root else "") + (hi.findtext("name") or "")
    if hi.find("bass") is not None:
        sym += "/" + tpc_name(hi.findtext("bass"))
    return sym


def tpc_name(t):
    t = int(t)
    base = TPC_LETTER[(t - 13) % 7 + 13]
    acc = (t - 13) // 7
    return base + ("#" * acc if acc > 0 else "b" * -acc)


def duration_token(d):
    for k in (1, 2, 4, 8, 16, 32):
        if Fraction(1, k) == d:
            return str(k)
        if Fraction(1, k) * Fraction(3, 2) == d:
            return f"{k}."
    return f"({d})"


def event_token(el, bar_len):
    """Rest/Chord/MeasureRepeat を記法の 1 トークンにする (read_score の表示用)。"""
    if el.tag == "MeasureRepeat":
        return "%"
    dur = duration_token(duration_of(el, bar_len))
    if el.tag == "Rest":
        return "n" + dur
    note = el.find("Note")
    name = tpc_name(note.findtext("tpc")).lower()
    if note.findtext("head") == "cross":
        name = "x"
    tie = "~" if any(sp.get("type") == "Tie" and sp.find("next") is not None for sp in note.findall("Spanner")) else ""
    acc = "<" if any("Accent" in (a.findtext("subtype") or "") for a in el.findall("Articulation")) else ""
    octave = octave_of(int(note.findtext("pitch")), int(note.findtext("tpc")))
    oct_tok = f"{octave}/" if octave != DEFAULT_OCTAVE else ""
    return name + oct_tok + dur + tie + acc


def octave_of(midi, tpc_val):
    """綴りどおりのオクターブ (B#3 = midi 60 は 3、Cb4 = 59 は 4)"""
    spelled = tpc_name(tpc_val)
    semi = SEMI[spelled[0]] + spelled.count("#") - spelled.count("b")
    return (midi - semi) // 12 - 1


# ---------- 記法 → XML ----------

def pitch_of(name, octave):
    m = re.fullmatch(r"([a-g])([#b]?)", name)
    letter, acc = m.group(1).upper(), m.group(2)
    midi = 12 * (octave + 1) + SEMI[letter] + {"": 0, "#": 1, "b": -1}[acc]
    return midi, tpc(letter + acc)


def rest_xml(num, dots, bar_len):
    if num == 1 and not dots:
        # Fraction は 4/4 を 1/1 に約分するので、既存ファイルと同じ表記に戻す
        d = "4/4" if bar_len == 1 else f"{bar_len.numerator}/{bar_len.denominator}"
        return f"<Rest><durationType>measure</durationType><duration>{d}</duration></Rest>"
    # MuseScore は <durationType> を読むと dots を 0 に戻すので、<dots> は先に置く
    d = f"<dots>{dots}</dots>" if dots else ""
    return f"<Rest>{d}<durationType>{DUR_NAME[num]}</durationType></Rest>"


def tie_xml(kind, fractions, measures=0):
    """kind は next (始点) か prev (終点)。fractions は相手の音符との小節内の位置の差、measures は小節の差 (小節線をまたぐときだけ)。"""
    loc = (f"<measures>{measures}</measures>" if measures else "") + (f"<fractions>{fractions}</fractions>" if fractions else "")
    if kind == "next":
        return f'<Spanner type="Tie"><Tie></Tie><next><location>{loc}</location></next></Spanner>'
    return f'<Spanner type="Tie"><prev><location>{loc}</location></prev></Spanner>'


def note_xml(num, dots, midi, tpc_val, cross=False, ties="", accent=False):
    d = f"<dots>{dots}</dots>" if dots else ""
    head = "<head>cross</head>" if cross else ""
    # 上下は MuseScore が符尾の向きで決め直す (保存すると articAccentBelow になることもある)
    art = "<Articulation><subtype>articAccentAbove</subtype></Articulation>" if accent else ""
    return (f"<Chord>{d}<durationType>{DUR_NAME[num]}</durationType>{art}"
            f"<Note><pitch>{midi}</pitch><tpc>{tpc_val}</tpc>{head}{ties}</Note></Chord>")


def tuplet_xml(actual, num):
    """actual 個の num 分音符を normal 個分の長さに入れる連符 (3 → 2、5〜7 → 4)。"""
    normal = 1 << (actual.bit_length() - 1)
    return (f"<Tuplet><normalNotes>{normal}</normalNotes><actualNotes>{actual}</actualNotes>"
            f"<baseNote>{DUR_NAME[num]}</baseNote><Number><style>tuplet</style><text>{actual}</text></Number></Tuplet>")


def text_xml(text, above=False):
    pl = "<placement>above</placement>" if above else ""
    # `<` や `&` を含むメモ (食いの `<` など) で XML が壊れないようにする。改行の <br/> だけは通す
    body = html.escape(text, quote=False).replace("&lt;br/&gt;", "<br/>")
    return f"<StaffText>{pl}<text>{body}</text></StaffText>"


TOKEN_RE = re.compile(r"(x|o|[a-g][#b]?|n)(?:(\d)/)?(\d+)(\.?)")
TIE_SPANNER_RE = re.compile(r'<Spanner type="Tie">.*?</Spanner>', re.S)
TUPLET_OPEN_RE = re.compile(r"T(\d+)\((.*)$")


def parse_tokens(tokens, bar_len, default_pitch="g", octave=4):
    """記法トークン列 → (events, chords, texts)。
    events: [(tick, kind, dict)] kind は rest/note。chords: [(tick, sym)]。texts: [(tick, text, above)]"""
    events, chords, texts = [], [], []
    tick = Fraction(0)
    pending_chord = None
    pending_texts = []
    tuplet = None  # (actual, 残り音符数) 連符の中にいるとき
    for tok in tokens:
        # メモはコロンを含んでもよい (`_Vo:only`) ので、コードの判定より先に見る
        if tok.startswith("^") or tok.startswith("_"):
            pending_texts.append((tok[1:], tok.startswith("^")))
            continue
        if ":" in tok and not TOKEN_RE.fullmatch(tok.split("~")[0]):
            sym, tok = tok.split(":", 1)
            pending_chord = sym
            if not tok:
                continue
            if tok.startswith("^") or tok.startswith("_"):  # `N.C.:^break`
                pending_texts.append((tok[1:], tok.startswith("^")))
                continue
        t_open = TUPLET_OPEN_RE.fullmatch(tok)
        if t_open:
            if tuplet is not None:
                raise SystemExit(f"連符の中に連符がある: {tok!r}")
            tuplet = {"actual": int(t_open.group(1)), "count": 0, "num": None}
            tok = t_open.group(2)
        t_close = tok.endswith(")")
        if t_close:
            if tuplet is None:
                raise SystemExit(f"連符の始まり T3( が無い: {tok!r}")
            tok = tok[:-1]
        accent = tok.endswith("<")
        if accent:
            tok = tok[:-1]
        trailing_tie = tok.endswith("~")
        if tok.startswith("~") or "~~" in tok or tok == "~":
            raise SystemExit(f"タイの前に音符が無い: {tok!r}")
        parts = [p for p in tok.split("~") if p]
        for k, part in enumerate(parts):
            m = TOKEN_RE.fullmatch(part)
            if not m:
                raise SystemExit(f"トークンを読めない: {part!r} (in {tok!r})")
            name, oct_str, num, dot = m.group(1), m.group(2), int(m.group(3)), m.group(4)
            if name == "n" and oct_str:
                raise SystemExit(f"休符にオクターブは付けられない: {part!r}")
            dots = 1 if dot else 0
            length = Fraction(1, num) * (Fraction(3, 2) if dots else 1)
            extra = {}
            if tuplet is not None:
                if dots:
                    raise SystemExit("連符の中の付点は扱えない")
                if tuplet["num"] is None:
                    tuplet["num"] = num
                    extra["tuplet_start"] = (tuplet["actual"], num)
                elif tuplet["num"] != num:
                    raise SystemExit("連符の中の音価は揃える")
                tuplet["count"] += 1
                normal = 1 << (tuplet["actual"].bit_length() - 1)
                length = length * normal / tuplet["actual"]
            if pending_chord is not None:
                chords.append((tick, pending_chord))
                pending_chord = None
            for t, above in pending_texts:
                texts.append((tick, t, above))
            pending_texts = []
            if name == "n":
                events.append((tick, "rest", {"num": num, "dots": dots, **extra}))
            else:
                pname = default_pitch if name in ("x", "o") else name
                midi, tpc_val = pitch_of(pname, int(oct_str) if oct_str else octave)
                tie_out = (k < len(parts) - 1) or trailing_tie
                events.append((tick, "note", {"num": num, "dots": dots, "midi": midi, "tpc": tpc_val,
                                              "cross": name == "x", "tie_in": False, "tie_out": tie_out, "len": length,
                                              "accent": accent and k == len(parts) - 1, **extra}))
            tick += length
        if t_close:
            if tuplet["count"] != tuplet["actual"]:
                raise SystemExit(f"T{tuplet['actual']}( ) の中の音符が {tuplet['count']} 個")
            events[-1][2]["tuplet_end"] = True
            tuplet = None
    if tuplet is not None:
        raise SystemExit("連符が ) で閉じていない")
    if pending_chord is not None or pending_texts:
        raise SystemExit("コードやメモの後に音符か休符が無い")
    if tick != bar_len:
        raise SystemExit(f"拍数が合わない: {tick} / {bar_len}")
    for i, (t, kind, d) in enumerate(events):
        if kind != "note" or not d["tie_out"]:
            continue
        if i + 1 >= len(events):
            # 次の小節の最初の音符につなぐ。相手側の prev は sync_cross_ties() が付ける
            d["tie_cross"] = True
            continue
        nxt = events[i + 1][2]
        if events[i + 1][1] != "note":
            raise SystemExit("タイの次が休符になっている")
        if nxt["midi"] != d["midi"]:
            raise SystemExit("タイの前後で音高が違う")
        nxt["tie_in"] = True
    return events, chords, texts


def events_xml(events, bar_len):
    """events → [(tick, xml)]。タイの fractions は前後の音符の長さから決める。"""
    out = []
    for i, (tick, kind, d) in enumerate(events):
        if kind == "rest":
            xml = rest_xml(d["num"], d["dots"], bar_len)
        else:
            ties = ""
            if d["tie_in"]:
                ties += tie_xml("prev", -events[i - 1][2]["len"])
            if d.get("tie_cross"):
                ties += tie_xml("next", -tick, measures=1)
            elif d["tie_out"]:
                ties += tie_xml("next", d["len"])
            xml = note_xml(d["num"], d["dots"], d["midi"], d["tpc"], d["cross"], ties, d.get("accent"))
        if "tuplet_start" in d:
            xml = tuplet_xml(*d["tuplet_start"]) + xml
        if d.get("tuplet_end"):
            xml += "<endTuplet/>"
        out.append((tick, xml))
    return out


def tostr(el):
    return strip_eid(ET.tostring(el, encoding="unicode"))


def is_cross_tie(sp, kind):
    return sp.get("type") == "Tie" and sp.find(f"{kind}/location/measures") is not None


def sync_cross_ties(score):
    """小節線をまたぐタイの終点を始点に合わせる。
    小節の最後の音符に next (measures 1) のタイがあれば次の小節の最初の音符に prev を付け直し、無ければ残っている prev を消す。
    編集で小節の voice を書き直すと Note の中の Spanner も消えるので、全小節を編集した後に 1 回呼ぶ。"""
    nums = score.numbers()
    for i, a in enumerate(score.measures):
        events = [(t, el) for t, k, el in parse_voice(a, score.timesig_at(i)) if k == "event"]
        start = None
        if events and events[-1][1].tag == "Chord":
            note = events[-1][1].find("Note")
            if any(is_cross_tie(sp, "next") for sp in note.findall("Spanner")):
                start = (events[-1][0], note.findtext("pitch"))
        if i + 1 == len(score.measures):
            if start:
                raise SystemExit("最後の小節の音符に次の小節へのタイがある")
            break
        b = score.measures[i + 1]
        vm = VOICE_RE.search(b)
        nxt = [(t, el) for t, k, el in parse_voice(b, score.timesig_at(i + 1)) if k == "event"]
        first_is_note = bool(nxt) and nxt[0][1].tag == "Chord"
        if start and not (first_is_note and nxt[0][1].find("Note").findtext("pitch") == start[1]):
            raise SystemExit(f"小節 {nums[i]} の最後の音符のタイの先が小節 {nums[i + 1]} の頭の同じ音高の音符でない")
        if not first_is_note:
            continue
        nm = re.search(r"<Note>.*?</Note>", vm.group(0), re.S)
        old = nm.group(0)
        new = TIE_SPANNER_RE.sub(lambda s: "" if "<prev>" in s.group(0) and "<measures>" in s.group(0) else s.group(0), old)
        if start:
            new = new[:-len("</Note>")] + tie_xml("prev", start[0], measures=-1) + "</Note>"
        if new != old:
            pos = vm.start() + nm.start()
            score.measures[i + 1] = b[:pos] + new + b[pos + len(old):]


def assemble(measure_xml, bar_len, new_events, chords=None, texts=(), keep_texts=True, keep_marks=True):
    """小節の voice を new_events で書き直す。
    chords: [(tick, sym)]。None なら元の Harmony を tick ごとに残す。
    texts: 追加するメモ [(tick, text, above)]。keep_texts: 元の StaffText を tick ごとに残す。
    Tempo、Marker、Jump などの StaffText 以外は常に残す (消すと反復の構造が変わる)。
    元の要素は、同じ tick の event が無ければ直前の event に付ける。"""
    items = parse_voice(measure_xml, bar_len)
    heads = [tostr(el) for t, k, el in items if k == "head"]
    barlines = [tostr(el) for t, k, el in items if k == "barline"]
    ann = {}  # tick -> [(order, xml)]  order: spanner, mark, harmony, text

    def put(tick, xml, order):
        ann.setdefault(tick, []).append((order, xml))

    ticks = [t for t, _ in new_events]

    def snap(t):
        cands = [x for x in ticks if x <= t]
        return cands[-1] if cands else ticks[0]

    for t, k, el in items:
        if k == "spanner":
            put(snap(t), tostr(el), 0)
        elif k == "mark" and keep_marks:
            put(snap(t), tostr(el), 1)
        elif k == "harmony" and chords is None:
            put(snap(t), tostr(el), 2)
        elif k == "text" and keep_texts:
            put(snap(t), tostr(el), 3)
        elif k == "other":
            put(snap(t), tostr(el), 3)
    for t, sym in chords or []:
        put(snap(t), harmony_xml(sym), 2)
    for t, text, above in texts:
        put(snap(t), text_xml(text, above), 3)
    body = "".join(heads)
    for t, xml in new_events:
        body += "".join(x for _, x in sorted(ann.get(t, []), key=lambda p: p[0]))
        body += xml
    body += "".join(barlines)
    out = VOICE_RE.sub(lambda _: f"<voice>{body}</voice>", measure_xml, count=1)
    # measureRepeatCount は voice の MeasureRepeat と対で、片方だけ残ると MuseScore が小節を % として扱う
    if "<MeasureRepeat>" not in body:
        out = re.sub(r"\s*<measureRepeatCount>[^<]*</measureRepeatCount>", "", out)
    return out


def parse_line(line):
    """'7: F:f8 f8 n2 G:g4' → (7, tokens)"""
    m = re.match(r"\s*(\d+)\s*:\s*(.*)$", line)
    if not m:
        raise SystemExit(f"行を読めない: {line!r}")
    return int(m.group(1)), shlex.split(m.group(2))
