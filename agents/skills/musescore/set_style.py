#!/usr/bin/env python3
"""score_style.mss の値を書き換える。
usage: set_style.py <in.mscz> <out.mscz> key=value ...   (例: spatium=1.6 showMeasureNumber=1)
キーは mss にあるものだけ (無いキーは止まる)。他のファイルはそのまま。"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mscxlib import set_style  # noqa: E402

if len(sys.argv) < 4 or any("=" not in a for a in sys.argv[3:]):
    raise SystemExit(__doc__)
set_style(sys.argv[1], sys.argv[2], **dict(a.split("=", 1) for a in sys.argv[3:]))
print(sys.argv[2])
