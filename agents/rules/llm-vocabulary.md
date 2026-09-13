# LLM 語彙の混入防止

LLM が多用する語彙、直訳調、定型句を成果物に混入させない。
対象は回答、コミットメッセージ、コメント、docs、ユーザーに見える文字列のすべて。
ユーザーが指示に用いた語は、この一覧にあってもそのまま使う（vocabulary.md が優先）。

## 原則

- 英語の慣用句を日本語に直訳しない（silently break → 静かに壊れる、the moment → した瞬間、source of truth → 正本、load-bearing → 効く）。
- 物理動作や場所の比喩で抽象を語らない。何がどうなるかを、規範的な書き言葉の動詞で書く。
- 禁止語を同義語に置き換えて逃げない。その語が要る文は、文ごと組み直す。
- 強調語、予告、まとめ口調で「ちゃんと書いている感」を出さない。主張をそのまま書く。
- 共感や励ましを書かない。事実と次の操作だけを書く。

## 日本語の禁止語彙

| 群 | 語 | 書き換えの方向 |
|---|---|---|
| 効果・変化 | 効く、地味に効く、〜した瞬間、壊れる、静かに、黙って | 何がどう変わるかを動詞で書く（「キャッシュが効く」→「キャッシュにより再計算しない」） |
| 検証 | 実測、疑う、照合、突き合わせる、見落とす、取り違える | 確認する、比べる、測る、誤る |
| 場所・物の比喩 | 入口、土台、道具、核心、主役、構図、線引き、境界、見張り | 前提、基準、条件、範囲、中心、監視 |
| 障害 | 事故、混ざる、落とし穴、破綻、実害、素通り | 不具合、誤り、失敗、影響、通過する |
| 作業動詞 | 切り分ける、潰す、踏み込む、塞ぐ、溶かす、逃がす、倒す、叩く、投げる、引く、落ちる、ブランチを切る | 分ける、修正する、調べる、防ぐ、費やす、呼び出す、送信する、取得する、失敗する、作成する |
| 判断 | 既定、別物、定番、要点、素朴、定石、桁違い、正本 | デフォルト、異なる、一般的、原本 |
| 定型句 | 重要なのは、ポイントは、と言えるでしょう、のではないでしょうか、一方で、結論から言うと、結論として、まとめると、〜に他ならない、正面から〜、〜を深掘りする、〜について見ていく、言うまでもなく、ぜひ〜してください | 主張をそのまま書く。予告と総括を置かない |
| 空虚な形容 | 不可欠、核心的、鍵となる、根本的な、多角的、包括的、総合的、非常に、極めて | 根拠や視点そのものを書く |
| 共感の演出 | そのお気持ち、よくわかります／大変でしたね／〜なんですよね | 書かない |

### 直訳調の構文

| 構文 | 書き換え |
|---|---|
| 無生物主語＋他動詞（データが示している、この事実が意味する） | 〜から分かる、〜を見ると |
| することができる、することが可能です | 可能形（できる、短縮できる） |
| という観点から、という点で | 〜で見ると、〜については |
| にとって重要、にとって不可欠 | 〜には〜が要る |
| 〜を持つ（意味を持つ） | 〜がある |
| することによって | 〜すると、〜して |
| 〜ではなく〜の反復、〜だけでなく〜も | 肯定文で書く |

### 記号と構造

- ダッシュ（—、―、——）を使わない。括弧か句点で分ける。
- 日本語を "" で囲まない。「」を使う。
- 絵文字を使わない。
- 太字は一節に一、二箇所まで。太字＋コロンの箇条書き（**重要**: 説明）にしない。
- 「理由は 3 つあります」のように数を先に宣言しない。項目の数だけ書く。
- 見出しを「まとめ」「おわりに」で締めない。

## 英語の禁止語彙

| 群 | 語 | 書き換えの方向 |
|---|---|---|
| 抽象語 | comprehensive, nuanced, fundamentally, paradigm, in essence, essentially, worth noting, inherent tension, thoughtful, load-bearing, silently, subtle | 何がどうなのかを具体的に書く |
| 空虚な動詞 | ensure/ensuring, plays a role in, contributes to, highlights, reflects, delve, leverage, utilize, facilitate, foster, bolster, underscore, streamline, navigate（比喩）, showcase | use, help, show, make, check |
| 形容 | robust, seamless, cutting-edge, vibrant, intricate, meticulous, pivotal, crucial, significant | 削るか、数値や事実に置き換える |
| 副詞 | significantly, effectively, directly, notably, remarkably、typically/often/sometimes/potentially の連発 | 数値がなければ削る |
| コピュラ回避 | serves as, stands as, boasts, features, offers, represents（is の代わり） | is, has |
| 接続 | furthermore, moreover, conversely, nevertheless, thus, hence、rather than の多用 | also, but, so |
| 結び・前置き | it's worth noting that, in today's landscape, one thing is clear, the key takeaway, at the end of the day, in conclusion | 削る |
| 対話の定型 | You're absolutely right, Great question, I hope this helps, Certainly! | 書かない |

- em dash を使わない。
- "Not just X, but Y" と三項の列挙（rule of three）を修辞として使わない。

## ユーザーに見える文字列

UI 文言、エラーメッセージ、API レスポンス、通知、ログのメッセージに適用する。フロントエンドとバックエンドを区別しない。

- ボタンとリンクは動作そのものを書く（保存、削除、Save、Delete）。「さあ始めましょう」「ようこそ」「〜してみましょう！」「Get started」「Welcome back」を使わない。
- 感嘆符と絵文字を使わない。
- 製品を飾る語を使わない: シームレス、直感的、洗練された、強力な、効率的に、簡単に、〜を実現、〜体験、unlock, elevate, empower, supercharge, effortlessly, seamless, journey, game-changer, next-level。機能が何をするかを書く。
- 空状態とエラーは、事実と次の操作だけを書く。励まし、共感、謝罪の演出を書かない。
- 数値や実績を捏造しない（「10,000 チームが利用」）。
- 同じ操作には同じ語を当てる。既存画面の語に揃える。

## 返す前の点検

1. 「効く」「瞬間」「壊れる」「切り分ける」「既定」を検索する。
2. ダッシュ、""、絵文字、太字の数を確認する。
3. 文頭の「重要なのは」「一方で」「まとめると」、文末の「と言えるでしょう」を検索する。
4. 英語なら ensure, comprehensive, nuanced, leverage, robust, seamless, em dash を検索する。
5. 見つけたら同義語に置き換えず、文を組み直す。
