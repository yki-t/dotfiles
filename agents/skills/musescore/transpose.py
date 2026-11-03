#!/usr/bin/env python3
"""コード記号と音符を半音単位で移調する。
usage: transpose.py <in.mscz> <out.mscz> <semitones> [sharp|flat]   (例: -1 で半音下げ)

- Harmony の root と bass、Note の pitch と tpc を動かす。Harmony の name の括弧内にある音名 (`m (x2 E)`) も動かす。
- 綴りは第 4 引数で決める。省略時はサブタイトル `Key: X` を移調した先のキーで決める (C と # 系なら sharp、b 系なら flat)。
  Fb、B# のような綴りになるときだけ逆側の綴りにする。
- サブタイトルの `Key: X` (VBox と metaTag) を書き換える。調号 (KeySig) は変えない。
- Note の Accidental は消す (MuseScore が読み込み時に tpc から付け直す)。
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from chartlib import tpc as tpc_of  # noqa: E402
from mscxlib import Score, tpc_name  # noqa: E402

if len(sys.argv) not in (4, 5):
    raise SystemExit(__doc__)
src, dst, semis = sys.argv[1], sys.argv[2], int(sys.argv[3])
spell = sys.argv[4] if len(sys.argv) == 5 else None
if spell not in (None, "sharp", "flat"):
    raise SystemExit(__doc__)

score = Score(src)
text = score.text

KEY_RE = re.compile(r"(Key: )([A-G][#b]?)")
NOTE_RE = re.compile(r"[A-G][#b]?")


def shift_tpc(t, spell):
    """半音 semis の移調で tpc をどちらの綴りに動かすか。5 度圏で 7*semis だけ回す。"""
    up = (7 * semis) % 12
    cands = [up, up - 12] if spell == "sharp" else [up - 12, up]
    for d in cands:
        if 8 <= t + d <= 24:  # Gb〜A# に収まる綴りを優先
            return t + d
    return t + cands[0]


if spell is None:
    m = KEY_RE.search(text)
    if not m:
        raise SystemExit("サブタイトルに Key: が無いので、綴り (sharp|flat) を指定する")
    # 移調先のキーは調号の少ない綴りにする (B → Bb、C → B)。同数なら # 側
    new_key = min((shift_tpc(tpc_of(m.group(2)), s) for s in ("sharp", "flat")), key=lambda t: (abs(t - 14), -t))
    spell = "sharp" if new_key >= 14 else "flat"


def shift_name(name):
    return tpc_name(shift_tpc(tpc_of(name), spell))


def harmony(m):
    h = m.group(0)
    h = re.sub(r"<(root|bass|base)>(\d+)</\1>", lambda x: f"<{x.group(1)}>{shift_tpc(int(x.group(2)), spell)}</{x.group(1)}>", h)
    # name の括弧内は別の回のコードなど (`(x2 E)`)。括弧の外は maj7、N.C. などで音名ではない
    h = re.sub(r"\([^)]*\)", lambda x: NOTE_RE.sub(lambda n: shift_name(n.group(0)), x.group(0)), h)
    return h


def note(m):
    n = m.group(0)
    n = re.sub(r"<pitch>(\d+)</pitch>", lambda x: f"<pitch>{int(x.group(1)) + semis}</pitch>", n)
    n = re.sub(r"<(tpc2?)>(\d+)</\1>", lambda x: f"<{x.group(1)}>{shift_tpc(int(x.group(2)), spell)}</{x.group(1)}>", n)
    n = re.sub(r"\s*<Accidental>.*?</Accidental>", "", n, flags=re.S)
    return n


text, nh = re.subn(r"<Harmony>.*?</Harmony>", harmony, text, flags=re.S)
text, nn = re.subn(r"<Note>.*?</Note>", note, text, flags=re.S)
text, nk = KEY_RE.subn(lambda x: x.group(1) + shift_name(x.group(2)), text)
score.write(dst, text)
print(f"{semis:+d} 半音 ({spell}): Harmony {nh}, Note {nn}, Key {nk}")
print(dst)
