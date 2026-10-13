#!/usr/bin/env python3
"""spec からコード譜の mscz を新規に作る。
usage: gen_chart.py <spec.py> <out.mscz> [style.mss]
style.mss を省略するとこのスクリプトと同じ場所の score_style.mss を使う。"""
import sys, zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from chartlib import build, load_spec

SPEC = load_spec(sys.argv[1])
OUT = Path(sys.argv[2])
STYLE = Path(sys.argv[3]) if len(sys.argv) > 3 else Path(__file__).resolve().parent / "score_style.mss"
TITLE, SUBTITLE, COMPOSER = SPEC.TITLE, SPEC.SUBTITLE, getattr(SPEC, "COMPOSER", "")
xml = build(SPEC)

mscx = f"""<?xml version="1.0" encoding="UTF-8"?>
<museScore version="4.70">
  <programVersion>4.7.5</programVersion>
  <Score>
    <Division>480</Division>
    <showInvisible>1</showInvisible>
    <showUnprintable>1</showUnprintable>
    <showFrames>1</showFrames>
    <showMargins>0</showMargins>
    <open>1</open>
    <metaTag name="composer">{COMPOSER}</metaTag>
    <metaTag name="subtitle">{SUBTITLE}</metaTag>
    <metaTag name="workTitle">{TITLE}</metaTag>
    <Part id="1">
      <Staff><StaffType group="pitched"><name>stdNormal</name></StaffType></Staff>
      <trackName>Piano</trackName>
      <Instrument id="piano">
        <longName>Piano</longName><shortName>Pno.</shortName><trackName>Piano</trackName>
        <minPitchP>21</minPitchP><maxPitchP>108</maxPitchP><minPitchA>21</minPitchA><maxPitchA>108</maxPitchA>
        <instrumentId>keyboard.piano</instrumentId>
        <Channel><program value="0"/><synti>Fluid</synti></Channel>
        <Channel name="harmony"><program value="0"/><synti>Fluid</synti></Channel>
      </Instrument>
    </Part>
    <Staff id="1">
      <VBox><height>10</height>
        <Text><style>title</style><text>{TITLE}</text></Text>
        <Text><style>subtitle</style><text>{SUBTITLE}</text></Text>
        <Text><style>composer</style><text>{COMPOSER}</text></Text>
      </VBox>
      {''.join(xml)}
    </Staff>
  </Score>
</museScore>
"""
name = OUT.stem
container = f"""<?xml version="1.0" encoding="UTF-8"?>
<container><rootfiles><rootfile full-path="score_style.mss"/><rootfile full-path="{name}.mscx"/></rootfiles></container>
"""
with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("META-INF/container.xml", container)
    z.writestr("score_style.mss", STYLE.read_text())
    z.writestr(f"{name}.mscx", mscx)
print(OUT, len(xml), "measures")
