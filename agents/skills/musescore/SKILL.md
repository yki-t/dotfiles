---
name: musescore
description: MuseScore のコード譜 (リードシート) を mscz として作成・編集・追記・読み取り・PDF 出力する。「譜面にして」「コード譜を作って」「MuseScore で開ける形に」「譜面を直して」「小節を書き換えて」「リズムを書いて」「テンポを半分に」「mscz に歌詞を追記」「続きを追記」「MuseScore で編集した内容を読んで」「PDF にして」のように、コード進行・セクション構成・歌詞・リズムを MuseScore のファイルに書く/読む作業のときに必ず使う。音源の解析は含まない。
---

# MuseScore コード譜

バンド用のコード譜を、ユーザーの既存スコアと同じ流儀で mscz に書く。

| 作業 | スクリプト |
|---|---|
| 新規作成 | spec (Python モジュール) → `gen_chart.py` |
| 末尾への追記 | `append_chart.py` |
| 指定小節の書き換え (コード、休符、音符、メモ) | `edit_measures.py <in.mscz> <out.mscz> <edits.txt>` |
| 2 小節を 1 小節に結合 (テンポ半分) | `halftime.py <in.mscz> <out.mscz>` |
| 区間を複製して 1 番括弧、2 番括弧を付ける | `expand_repeat.py <in.mscz> <out.mscz> <first_bar> <last_bar>` |
| 反復を展開して回ごとに書き下す (2A、2B、2 番の歌詞) | `unroll_repeat.py <in.mscz> <out.mscz> <first_bar> <last_bar>` |
| 改行を n 小節ごとに付け直す | `breaks.py <in.mscz> <out.mscz> 1-36:4 37-44:2` |
| スタイルの値を変える (五線の大きさ、小節番号) | `set_style.py <in.mscz> <out.mscz> spatium=1.6` |
| mscx の手編集 | `pack.sh unpack <mscz> <dir>` / `pack.sh pack <dir> <mscz>` |
| 内容の読み取り | `read_score.py` |
| 確認用 PNG と PDF | `render.sh` |

書式の詳細は `references/mscx.md`。spec の書き方は `spec_example.py`。

## 前提

- flatpak の MuseScore (`org.musescore.MuseScore`)、`xvfb-run`、`magick`。
- 譜面の保存先は `~/Documents/MuseScore4/Scores/`。一時ファイル (spec、edits.txt、確認用 PNG、置き換え前のコピー) は scratchpad に置く。
- スクリプトは `~/.claude/skills/musescore/` にある。scratchpad は消えることも、別のセッションのファイルが残っていることもある。spec は譜面を作るたびに書き、出力先は書く前に消す。
- このスキルの作業は実装前の確認が不要 (ユーザーの指示。グローバルの「実装は承認を待つ」より優先)。指示の解釈が 2 通りあって結果が変わるときだけ確認する。

## 流儀 (既存スコアに合わせる)

- Piano 1 パート 1 段、調号なし、4/4。基本はコードネーム＋休符で小節を埋め、リズムの指定があった小節だけ音符を書く。
- Title は曲名、Subtitle は `Key: C, BPM 155` の形、Composer はアーティスト名 (不明なら空)。
- 1 小節 1 コードは全休符、2 コードは 2 分休符 ×2。同じ 1 コードの小節が続くと `%`。
- 結合などで同じコードが 1 小節に 2 つ入るときは全休符ではなく 2 分休符 2 つにし、後半はコード記号なし。
- 半端な拍数は 2/4 小節を挿入する。
- 小節番号は 1 小節目から数える。`IRREGULAR` は拍が欠けたピックアップだけに付ける。段頭に小節番号を表示する (`showMeasureNumber` 1、`measureNumberSystem` 1)。
- RehearsalMark は `I` (イントロ)、`A`、`B`、`C` (サビ)、`D`、`2A` `2B` `2C` (2 番)、`3C` (ラスサビ)、`Solo`、`Outro`。変化形は `C'`。
- StaffText は演奏指示だけ: `Band In` `Gt In` `Ba In` `Dr In` `Vo only` `Gt only` `落ち` `キメ` `break` `Solo` `x2`。N.C. には `break` を付ける。StaffText はデフォルトで五線の下に出る。拍の上に置くメモは `placement above`。
- 反復 3 回以上は `endRepeat` の回数に加えて `x3` の StaffText を置く (MuseScore は回数を印字しない)。
- 回ごとの小さい違いはコード名に `(x2 Am)` の形で添える。進行が違う区間は複製して 1 番括弧、2 番括弧で展開する。
- 食いは、音符を書く小節では 8 分音符で前の拍の裏から入れ、次の拍にタイでつなぐ (小節線をまたいでよい)。コード記号は食いの音符に付ける。
- コードと休符だけの小節では食いを音符で書かず、食うコードの上に `<` の StaffText (`placement above`、edits.txt では `^<`) を置く。凡例は付けない。
- セクション直前の小節のピックアップは `n2 n4 n8 <根音>8<` (2 分休符、4 分休符、8 分休符、そのコードの根音の 8 分音符にアクセント)。
- リズム譜の音符は 1 つの音高 (指定がなければ G4) に置く。ゴーストは ×符頭。コード記号の位置と文字は変えない。
- 歌詞は参考用で、五線の下の StaffText に 4 小節 1 行 (2 小節で 1 行の曲は 2 小節ごと) で置く。正確さは求めない。食い (前の小節から始まる歌い出し) は次の小節頭に書く。「ーーー」などの伸ばしはそのまま書く。
- 1 つの StaffText を複数行にするときは `<br/>` の後に全角空白 2 つで字下げする (`1 行目<br/>　　2 行目`)。
- 1 番と 2 番は別の StaffText にし、2 番は `2) ` で始める。反復を展開したら各回に分けて `2) ` を外す (`unroll_repeat.py` が行う)。
- 1 段 4 小節を基本に、改行は段の最後の小節に付ける。セクションの頭が段の先頭に来るようにする。短い区間 (break 2 小節など) は前後の段と合わせて 5〜6 小節の段にしてよい。
- 半分のテンポへの変換は 2 小節を 1 小節に結合して BPM を半分にする。改行は結合前の 2 小節目から引き継ぐので段の小節数は半分になる。4 小節 1 段に戻すなら `breaks.py`。半端な最後の小節は 2/4。反復括弧は奇数小節で始まり長さが偶数なら `halftime.py` が引き継ぐ。

## 指示の記法

ユーザーの指示と `edits.txt` で使う。

| 記法 | 意味 |
|---|---|
| `e8 g8 g#8 a8~a2` | 音名＋音価。`~` はタイ。行末の `~` (`n4 n8 e8~`) は次の小節の最初の音符につなぐ (次の小節の頭は同じ音高の音符にする) |
| `c#5/8` | オクターブ付きの音名 (C#5 の 8 分音符)。省略時は `--octave` (4)。`read_score.py` も 4 以外のときこの形で出す |
| `4.` | 付点 (`g4.`、`n4.`) |
| `n4` | 休符 (4 分)。`n1` は全休符 |
| `x8` | ゴースト (×符頭) |
| `o8` | デフォルトの音高の音符 (`--pitch g --octave 4` で変える) |
| `F:` `"C (x2 Am)":` `N.C.:` | 直後の音符か休符に付くコード |
| `^break` | 五線の上のメモ。`<` や `&` もそのまま書く (`^<`) |
| `_text` | 五線の下のメモ |
| `d#8<` | アクセント (`<` を音符の後ろに付ける) |
| `T3(b8 b8 b8)` | 3 連符。括弧の中は同じ音価。コードは `B:T3(b8 b8 b8)` |
| `-text` `-mark` | 行のどこかに置くと、元の StaffText か RehearsalMark を消す |
| 小節番号 | 現在の表示番号 (`read_score.py` と同じ) |

## 手順

### 新規作成

1. コード進行・構成・歌詞をユーザーから受け取る (音源解析は別の作業)。
2. scratchpad に spec を書く。`spec_example.py` を写して SECTIONS、BREAKS、TEXTS、LYRICS を埋める。
3. `python3 ~/.claude/skills/musescore/gen_chart.py <spec.py> ~/Documents/MuseScore4/Scores/<曲名>.mscz`
4. `render.sh <mscz> <scratchpad>/<name>.png` で PNG にし、`magick <png> -resize 1100x <small.png>` で縮小して Read で目視する。確認点: セクション記号が段の先頭にあるか、歌詞が右端で切れていないか、ページ数。
   段を拡大するときはページ PNG (9921×14031 px) から絶対座標で切る: `magick <page.png> -crop <W>x<H>+<X>+<Y> +repage -resize 1100x <crop.png>`。縮小画像の座標を 9 倍すると位置が分かる。
5. `render.sh <mscz> ~/Documents/MuseScore4/Scores/<曲名>.pdf` で PDF を出す。
6. 報告には構成表 (Mark、小節、進行) と、判断に迷った箇所 (コードの候補、歌詞を置けなかった区間) を書く。

### ユーザーが編集した mscz を読む

`python3 ~/.claude/skills/musescore/read_score.py <mscz>` で小節ごとの一覧を出し、生成時の spec と比べて差分を報告する。
MuseScore で保存されたファイルはユーザーの編集が入っている原本なので、spec から再生成して上書きしない。以後の変更は `append_chart.py` か「既存ファイルの編集」で行う。

### 追記

1. 追記前のファイルを scratchpad にコピーしておく (戻せるように)。
2. 追記分だけの spec を書く (index 0 が追記の最初の小節。TITLE は不要)。
3. `python3 ~/.claude/skills/musescore/append_chart.py <spec.py> <in.mscz> <out.mscz>`。終止線を最後の小節に付け替え、追記部の前で改行する。
4. レンダリングして確認し、PDF を更新する。

### 既存ファイルの編集

1. `cmp` で Scores のファイルが前回置いたものと同じか確かめる。違えば MuseScore で保存されているので、先に `read_score.py` の出力を diff してユーザーの編集を把握し、そのファイルを原本にする。
2. 置き換え前のファイルを scratchpad にコピーする。
3. 対象の小節だけを書き換える。コード、休符、音符、連符、アクセント、メモは `edit_measures.py` (`edits.txt` は `7: F:f8 f8 n2 G:g4` のように 1 行 1 小節)、テンポ半分は `halftime.py`、括弧付きの複製は `expand_repeat.py`、反復の展開は `unroll_repeat.py`、改行は `breaks.py`。スクリプトで扱えない修正は `pack.sh unpack` で取り出した mscx を `references/mscx.md` の書式で直し、`pack.sh pack` で戻す。他の小節、`Thumbnails/` は触らない。`score_style.mss` は小節番号の表示などスタイルの指示があったときと、ページに収めるときだけ `set_style.py` で書き換える。
4. `read_score.py` で対象小節を確認し、`render.sh` の PNG から該当する段を `magick -crop` で切り出して目視する。
5. `~/Documents/MuseScore4/Scores/` のファイルを置き換える。`.mscz.autosave` があれば MuseScore で開いたままなので、開き直すよう伝える。
6. MuseScore で保存されたファイルを受け取ったら、置いたファイルと保存されたファイルの `read_score.py` の出力を diff し、ユーザーの編集と消えた要素を分けて報告する。MuseScore の保存は要素の順序と eid を変えるだけのこともある (内容の差分なし)。

### ページに収める

段がページからはみ出したら、`set_style.py` で `spatium` (五線の大きさ、デフォルト 1.75) を 0.05 刻みで下げる。候補ごとにレンダリングしてページ数を数え、収まる中で一番大きい値を採る。改行を減らして段を詰める方法はセクションの頭が段の先頭から外れるので、`spatium` で収まらないときだけにする。

## 注意

- MuseScore で開いたままのファイルを置き換えると、`<name>.mscz.autosave` が残り、ユーザーが保存した時点で古い内容に戻る。置き換えたら開き直すよう伝える。
- `QT_QPA_PLATFORM=offscreen` は MuseScore が無視するので、`render.sh` の xvfb-run を使う。
- 出力先が home の外のときは `render.sh` が `--filesystem` を付ける。
