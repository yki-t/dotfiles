# mscx の書式 (MuseScore 4.7)

mscz は zip。中身は `META-INF/container.xml`、`score_style.mss`、`<name>.mscx`。MuseScore で保存し直すと `Thumbnails/`、`audiosettings.json` などと各要素の `<eid>` が加わる。生成側は eid を書かなくてよい (読み込み時に付く)。

## 小節

```xml
<Measure>
  <irregular>1</irregular>                 <!-- 小節番号に数えない (ピックアップ) -->
  <measureRepeatCount>1</measureRepeatCount><!-- % の小節に付ける -->
  <LayoutBreak><subtype>line</subtype></LayoutBreak>   <!-- この小節の後で改行。nobreak もある -->
  <startRepeat/>                            <!-- 反復の始まり -->
  <endRepeat>2</endRepeat>                  <!-- 反復の終わり (回数) -->
  <voice>
    <KeySig><concertKey>0</concertKey></KeySig>        <!-- 先頭小節のみ。0 = 調号なし -->
    <TimeSig><sigN>4</sigN><sigD>4</sigD></TimeSig>    <!-- 先頭小節と拍子が変わる小節 -->
    <RehearsalMark><text>A</text></RehearsalMark>
    <StaffText><placement>above</placement><text>break</text></StaffText>   <!-- 五線の上 -->
    <StaffText><text>歌詞</text></StaffText>                                   <!-- 五線の下 (スタイルのデフォルト) -->
    <Harmony><harmonyInfo><root>13</root><name>maj7</name><bass>12</bass></harmonyInfo></Harmony>
    <Rest><durationType>measure</durationType><duration>4/4</duration></Rest>
    <BarLine><subtype>end</subtype></BarLine>   <!-- 終止線。最後の小節のみ -->
  </voice>
</Measure>
```

- Harmony は直後の Rest/Chord の位置に付く。1 小節 2 コードは `half` の Rest を 2 つ、それぞれの前に Harmony を置く。
- 1 小節 1 コードは `measure` の Rest (`<duration>4/4</duration>` も書く)。MuseScore が保存し直すと `measure` は `whole` になる。読む側は両方を受け付ける。
- `N.C.` は `<harmonyInfo><name>N.C.</name></harmonyInfo>` (root 無し)。
- `%` は `<MeasureRepeat><subtype>1</subtype><durationType>measure</durationType><duration>4/4</duration></MeasureRepeat>` を voice に置き、Measure に `<measureRepeatCount>1</measureRepeatCount>` を付ける。2 小節の % は subtype 2。
- Rest に `<Lyrics><text>…</text></Lyrics>` を入れると五線下に歌詞として出るが、小節幅が伸びる。長い文は StaffText のほうが段組みを崩さない。
- コード記号は中央揃え (`chordSymbolAAlign` center) なので、`(x2 Am)` のような長い名前は Harmony に `<offset x="…" y="0"/>` を付けてルートを拍に合わせる。目安は添え字の幅の半分。

## 音符

```xml
<Chord>
  <durationType>eighth</durationType>      <!-- whole / half / quarter / eighth / 16th。付点は <dots>1</dots> を durationType より前に置く (後だと無視される) -->
  <Note>
    <pitch>67</pitch>                      <!-- MIDI ノート番号 (G4 = 67) -->
    <tpc>15</tpc>                          <!-- tpc 表を参照 -->
    <head>cross</head>                     <!-- ×符頭 (ゴースト)。通常の符頭なら書かない -->
  </Note>
</Chord>
```

- 音符の後ろの休符は `<Rest><durationType>eighth</durationType></Rest>` のように音価だけ書く。
- アクセントは Chord の `<durationType>` の後、`<Note>` の前に `<Articulation><subtype>articAccentAbove</subtype></Articulation>`。MuseScore は保存時に符尾の向きで `articAccentBelow` に変えることがある。
- 連符は `<Tuplet><normalNotes>2</normalNotes><actualNotes>3</actualNotes><baseNote>eighth</baseNote><Number><style>tuplet</style><text>3</text></Number></Tuplet>` を置き、名目の音価のままの Chord/Rest を actualNotes 個並べ、`<endTuplet/>` で閉じる。
- タイは始点の Note に `<Spanner type="Tie"><Tie/><next><location><fractions>1/8</fractions></location></next></Spanner>`、終点の Note に `<Spanner type="Tie"><prev><location><fractions>-1/8</fractions></location></prev></Spanner>`。fractions は相手の音符との小節内の位置の差 (同じ小節なら始点の音符の長さ)。
- 小節線をまたぐタイは `<location>` に `<measures>` を足す。4 拍目裏の 8 分音符から次の小節の頭へは、始点が `<measures>1</measures><fractions>-7/8</fractions>`、終点が `<measures>-1</measures><fractions>7/8</fractions>` (fractions は小節頭からの位置の差なので符号が逆になる)。`edit_measures.py` の行末 `~` がこの形を書く。
- 1 番括弧、2 番括弧は始点小節の voice 先頭に `<Spanner type="Volta"><Volta><endHookType>1</endHookType><beginText>1.</beginText><endings>1</endings></Volta><next><location><measures>2</measures></location></next></Spanner>` (measures は括弧の小節数)。終点は括弧の次の小節の voice 先頭に `<Spanner type="Volta"><prev><location><measures>-2</measures></location></prev></Spanner>`。

## tpc (root / bass / Note の値)

| 音名 | F | C | G | D | A | E | B |
|---|---|---|---|---|---|---|---|
| ♭ | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
| ♮ | 13 | 14 | 15 | 16 | 17 | 18 | 19 |
| ♯ | 20 | 21 | 22 | 23 | 24 | 25 | 26 |

## 反復記号 (Segno / Coda / D.S.)

`<Marker>` と `<Jump>` を Measure 直下に置く。書式は既存スコア (`~/.local/share/MuseScore/MuseScore4/cloud_scores/*.mscz` のエイリアンズなど) を `unzip -p` して確認してから使う。

## 拍子変更

半端な小節は `<TimeSig><sigN>2</sigN><sigD>4</sigD></TimeSig>` をその小節の voice 先頭に置き、次の小節で 4/4 に戻す。Rest は `half` 1 つ。

## スタイル (score_style.mss)

| キー | 働き |
|---|---|
| `showMeasureNumber` | 1 で小節番号を表示 |
| `measureNumberSystem` | 1 で段頭だけに表示 |
| `lastSystemFillLimit` | 0 で最終段を幅いっぱいに広げる |
| `minSystemDistance`、`minSystemSpread` | 段の間隔の下限。最終段が次のページに送られたら縮める |
| `staffTextPlacement` | 1 = 五線の下 (StaffText のデフォルト) |
| `chordSymbolAAlign` | コード記号の揃え。既存スコアは center |
