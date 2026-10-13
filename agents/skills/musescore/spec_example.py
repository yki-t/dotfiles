# gen_chart.py / append_chart.py に渡す spec の見本。
TITLE, SUBTITLE = "曲名", "Key: C, BPM 155"     # Subtitle にキーと BPM を書く (調号は入れない)
COMPOSER = ""                                   # アーティスト名。無ければ空

# 空白区切りで 1 小節。"." は半小節 (C.Em = C 2 拍 + Em 2 拍)。"|" は見やすさのためで無視される。
# 同じコードの小節が続くと自動で % (MeasureRepeat) になる。"N.C." は break 付き。
A = "F G C C | F G Am Am | F G Em Am | Dm G C C"
B = "Dm7 Dm7 G N.C."
C = "F G C.Em/B Am | Dm G C C.E7 | F G E.Am Am | Dm G C C"
SECTIONS = [
    ("", "G"),        # ピックアップ 1 小節 (mark 無し)
    ("A", A), ("B", B), ("C", C),
    ("2A", A), ("2B", B), ("2C", C),
]

def b(n):             # 譜面上の小節番号 → index (ピックアップがあるので -1 しない。index 0 がピックアップ)
    return n

IRREGULAR = {0}       # ピックアップ小節は番号に数えない
# 改行は「段の最後の小節」に付ける。ピックアップを 1 段、以後 4 小節ごと
BREAKS = {0} | {i for i in range(4, 73, 4)}
# 五線の上の StaffText。N.C. の自動 "break" を上書きする ("" で消す)
TEXTS = {b(44): "/ / キメ", b(57): "落ち", b(61): "Band In"}
# 五線の下の StaffText。4 小節 1 行が基本で、2 小節 1 行なら 2 小節ごと
LYRICS = {b(1): "いつからか　どうしようもなく気にしてしまうの", b(5): "間違えてしまう事　誰かが決めたルールブック"}
