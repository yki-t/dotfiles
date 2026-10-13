#!/usr/bin/env python3
"""4/4 のコード譜を 2 小節 → 1 小節に結合し、BPM を半分にする (倍テンポで書いた譜面を半分のテンポの表記に直す)。
usage: halftime.py <in.mscz> <out.mscz>

- 2 小節目が % か、1 小節目と同じ 1 コードなら、2 分休符 2 つにして後半はコード記号なし。
- それ以外は各小節の休符を半分の長さにして前半、後半に並べる (1 コード → 2 分休符、2 コード → 4 分休符 2 つ)。
  % の小節は直前の小節のコードと休符の並びを引き継ぐ。
- StaffText などは元の位置に合わせて前半か後半に付く。反復開始は 1 小節目、反復終了と改行は 2 小節目から引き継ぐ。
  小節の頭に付く記号 (Segno、Coda) は 1 小節目、終わりに付く記号 (To Coda、Fine、D.S. などの Jump) は 2 小節目から引き継ぐ。
  どちらに付くかは Marker の <style> (repeat_left / repeat_right) で決め、<style> が無いときは止める。
  逆側にあるとき、1 小節目に反復終了、2 小節目に反復開始かリハーサルマークがあるときは結合できないので止める。
  テンポ記号 (Tempo) の BPM は変えない。
- 小節数が奇数なら最後の小節は 2/4 になる。ピックアップ (irregular) は 1 小節目と対にせず単独にする:
  `len` 付きの短い小節は `len` を半分にし、4/4 の長さの小節は 2/4 にする。最終段は幅いっぱいに広げる (lastSystemFillLimit 0)。
- BPM はサブタイトル (VBox と metaTag) だけを書き換え、奇数は切り捨てる (155 → 77)。
- 反復括弧は始点と終点が奇数番目の小節にあり、長さが偶数なら半分の長さで引き継ぐ。それ以外は止める。
- 音符、連符のある譜面は扱えない (結合の前に書き換える)。
"""
import re
import sys
from fractions import Fraction
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mscxlib import (Score, attrs, duration_of, harmony_name, measure_open_tag, parse_voice, rest_xml,  # noqa: E402
                     set_style, tostr)

if len(sys.argv) != 3:
    raise SystemExit(__doc__)
src, dst = sys.argv[1:3]
score = Score(src)
numbers = score.numbers()
ONE = Fraction(1)
HALF = Fraction(1, 2)
TS_24 = "<TimeSig><sigN>2</sigN><sigD>4</sigD></TimeSig>"
TS_44 = "<TimeSig><sigN>4</sigN><sigD>4</sigD></TimeSig>"
ORDER = {"spanner": 0, "mark": 1, "harmony": 2, "text": 3, "other": 3}


def label(i):
    return f"小節 {numbers[i]}" if numbers[i] else f"index {i}"


class Bar:
    """小節 1 つの内容。% は直前の小節のコードと休符を引き継いだ形で持つ。"""

    def __init__(self, i, prev):
        self.i = i
        if score.timesig_at(i) != ONE:
            raise SystemExit(f"{label(i)}: 4/4 以外の小節は結合できない")
        items = parse_voice(score.measures[i], ONE)
        for t, k, el in items:
            if k == "event" and el.tag == "Chord":
                raise SystemExit(f"{label(i)}: 音符のある小節は結合できない")
            if k == "tuplet":
                raise SystemExit(f"{label(i)}: 連符のある小節は結合できない")
            if k == "spanner" and el.get("type") == "Volta":
                # 括弧の始点と終点は小節数で位置を持つので半分にする。奇数小節の括弧は 2 小節単位に収まらない
                self.has_volta = True
                for loc in el.iter("measures"):
                    n = int(loc.text)
                    if n % 2:
                        raise SystemExit(f"{label(i)}: 反復括弧の長さ {abs(n)} が奇数なので結合できない")
                    loc.text = str(n // 2)
        self.heads = [tostr(el) for t, k, el in items if k == "head" and el.tag != "TimeSig"]
        self.timesig = next((tostr(el) for t, k, el in items if el.tag == "TimeSig"), "")
        self.barlines = [tostr(el) for t, k, el in items if k == "barline"]
        self.anns = [(t, ORDER[k], tostr(el)) for t, k, el in items if k in ("spanner", "mark", "text", "other")]
        self.has_mark = any(k == "mark" for t, k, el in items)
        self.has_volta = getattr(self, "has_volta", False)
        self.is_repeat = any(k == "event" and el.tag == "MeasureRepeat" for t, k, el in items)
        if self.is_repeat:
            if prev is None:
                raise SystemExit(f"{label(i)}: 先頭の % は引き継ぐコードが無い")
            self.harms, self.rests = prev.harms, prev.rests
        else:
            self.harms = [(t, el) for t, k, el in items if k == "harmony"]
            self.rests = [(t, el) for t, k, el in items if k == "event"]
        self.a = attrs(score.measures[i])
        self.open_tag = measure_open_tag(score.measures[i])

    def single_chord(self):
        return len(self.harms) == 1 and self.harms[0][0] == 0

    def halved_rests(self, offset):
        """休符を半分の長さにして offset からの位置に並べる。"""
        out = []
        for t, el in self.rests:
            # `len` 付き小節の全休符は <duration> が実長なので、durationType ではなく実長から半分を決める
            if el.findtext("durationType") == "measure" and el.find("duration") is None:
                raise SystemExit(f"{label(self.i)}: 全休符に <duration> が無いので長さが分からない")
            num, dots = rest_shape(duration_of(el, ONE) / 2, self.i)
            out.append((offset + t / 2, rest_xml(num, dots, ONE)))
        return out or [(offset, rest_xml(2, 0, ONE))]

    def halved_harms(self, offset):
        return [(offset + t / 2, 2, tostr(el)) for t, el in self.harms]

    def halved_anns(self, offset):
        return [(offset + t / 2, o, xml) for t, o, xml in self.anns]


def voice(heads, events, anns, barlines):
    """events [(tick, xml)] の間に anns [(tick, order, xml)] を挟んで voice にする。
    event の無い tick の注釈は直前の event に付ける。"""
    ticks = [t for t, _ in events]
    by_tick = {}
    for t, o, xml in anns:
        cands = [x for x in ticks if x <= t]
        by_tick.setdefault(cands[-1] if cands else ticks[0], []).append((o, xml))
    body = "".join(heads)
    for t, xml in events:
        body += "".join(x for _, x in sorted(by_tick.get(t, []), key=lambda p: p[0])) + xml
    return "<voice>" + body + "".join(barlines) + "</voice>"


def rest_shape(length, i):
    """半分にした長さ → (音価の分母, 付点の数)。"""
    for k in (2, 4, 8, 16, 32):
        if Fraction(1, k) == length:
            return k, 0
        if Fraction(1, k) * Fraction(3, 2) == length:
            return k, 1
    raise SystemExit(f"{label(i)}: 半分にした休符の長さ {length} を音価で表せない")


def keep_attrs(a, pattern):
    return "".join(re.findall(pattern, a, flags=re.S))


MARKER = r"<Marker>.*?</Marker>"
JUMP = r"<Jump>.*?</Jump>"


def marker_side(xml, i):
    """Marker が小節の頭 (Segno、Coda) か終わり (To Coda、Fine) のどちらに付くかを返す ("start" / "end")。
    label は Coda の飛び先が "codab" のように自由に付くので当てにならず、MuseScore が書く <style> で決める。"""
    style = re.search(r"<style>(repeat_left|repeat_right)</style>", xml)
    if style:
        return "start" if style.group(1) == "repeat_left" else "end"
    raise SystemExit(f"{label(i)}: Marker に <style> が無いので頭と終わりのどちらに付くか分からない")


def markers(a, i):
    """attrs の Marker を (頭に付くもの, 終わりに付くもの) に分ける。"""
    start, end = [], []
    for xml in re.findall(MARKER, a, flags=re.S):
        (start if marker_side(xml, i) == "start" else end).append(xml)
    return "".join(start), "".join(end)


def alone(bar, last):
    """小節を単独で半分の長さにする (ピックアップと、奇数番目で余る最後の小節)。
    返り値は (xml, 次の小節に 4/4 の拍子が要るか)。"""
    m = re.search(r'len="(\d+)/(\d+)"', bar.open_tag)
    if m:
        # `len` 付きの短い小節は名目の拍子を変えずに実長だけ半分にする
        length = Fraction(int(m.group(1)), int(m.group(2))) / 2
        open_tag = f'<Measure len="{length.numerator}/{length.denominator}">'
        heads = bar.heads + ([bar.timesig] if bar.timesig else [])
        needs_44 = False
    else:
        open_tag = "<Measure>"
        heads = bar.heads + [TS_24]
        needs_44 = True
    pattern = rf"<startRepeat/>|<irregular>1</irregular>|<endRepeat>.*?</endRepeat>|{MARKER}|{JUMP}"
    if not last:
        pattern += r"|<LayoutBreak>.*?</LayoutBreak>"
    v = voice(heads, bar.halved_rests(Fraction(0)), bar.halved_harms(Fraction(0)) + bar.halved_anns(Fraction(0)),
              bar.barlines)
    return f"{open_tag}{keep_attrs(bar.a, pattern)}{v}</Measure>", needs_44


merged = []
prev = None
needs_44 = False
i = 0
while i < len(score.measures):
    a = Bar(i, prev)
    prev = a
    last = i + 1 >= len(score.measures)
    if last or (i == 0 and "<irregular>" in a.a):
        xml, needs_44 = alone(a, last)
        merged.append(xml)
        i += 1
        continue
    b = Bar(i + 1, prev)
    prev = b
    if b.has_mark:
        raise SystemExit(f"{label(i + 1)}: 2 小節目にリハーサルマークがあるので結合できない")
    if b.has_volta:
        raise SystemExit(f"{label(i + 1)}: 2 小節目に反復括弧の始点か終点があるので結合できない")
    if "<endRepeat>" in a.a:
        raise SystemExit(f"{label(i)}: 1 小節目に反復終了があるので結合できない")
    if "<startRepeat/>" in b.a:
        raise SystemExit(f"{label(i + 1)}: 2 小節目に反復開始があるので結合できない")
    # 小節の頭に付く記号 (Segno、Coda) は 1 小節目、終わりに付く記号 (To Coda、Fine、D.S. などの Jump) は
    # 2 小節目からしか引き継げない。逆側にあると位置を保てないので止める
    a_start, a_end = markers(a.a, i)
    b_start, b_end = markers(b.a, i + 1)
    if "<Jump>" in a.a or a_end:
        raise SystemExit(f"{label(i)}: 1 小節目に小節の終わりに付く記号 (Jump、To Coda、Fine) があるので結合できない")
    if b_start:
        raise SystemExit(f"{label(i + 1)}: 2 小節目に小節の頭に付く記号 (Segno、Coda) があるので結合できない")
    same = a.single_chord() and (b.is_repeat or (b.single_chord()
                                                 and harmony_name(a.harms[0][1]) == harmony_name(b.harms[0][1])))
    if same:
        events = [(Fraction(0), rest_xml(2, 0, ONE)), (HALF, rest_xml(2, 0, ONE))]
        harms = a.halved_harms(Fraction(0))
    else:
        events = a.halved_rests(Fraction(0)) + b.halved_rests(HALF)
        harms = a.halved_harms(Fraction(0)) + b.halved_harms(HALF)
    heads = a.heads + ([a.timesig] if a.timesig else [])
    if needs_44:
        # ピックアップを 2/4 にしたので、ここで 4/4 に戻す
        heads.append(TS_44)
        needs_44 = False
    v = voice(heads, events, harms + a.halved_anns(Fraction(0)) + b.halved_anns(HALF), b.barlines)
    extra = keep_attrs(a.a, r"<startRepeat/>|<irregular>1</irregular>") + a_start
    extra += keep_attrs(b.a, rf"<endRepeat>.*?</endRepeat>|<LayoutBreak>.*?</LayoutBreak>|{JUMP}") + b_end
    merged.append(f"<Measure>{extra}{v}</Measure>")
    i += 2

text = score.rebuild(merged)


def half_bpm(m):
    return f"{m.group(1)}BPM {int(m.group(2)) // 2}"


text, n1 = re.subn(r'(<metaTag name="subtitle">[^<]*?)BPM (\d+)', half_bpm, text)
text, n2 = re.subn(r"(<style>subtitle</style>\s*<text>[^<]*?)BPM (\d+)", half_bpm, text)
if n1 + n2 == 0:
    raise SystemExit("サブタイトルに BPM が無い")
score.write(dst, text)
set_style(dst, dst, lastSystemFillLimit=0)
bpm = re.search(r"BPM (\d+)", text).group(1)
print(f"{len(score.measures)} 小節 → {len(merged)} 小節, BPM {bpm}")
if "<Tempo>" in text:
    print("注意: テンポ記号 (Tempo) の BPM は変えていない")
print(dst)
