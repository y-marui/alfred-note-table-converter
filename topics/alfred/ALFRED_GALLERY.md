# Alfred Gallery Readiness

Alfred Gallery（公式ワークフローギャラリー）への提出を見据えて、Alfred 5
ワークフロープロジェクトが満たしておくべき技術・ドキュメント面の基準を定義する。
`ALFRED_DEV_ENV.md`（Go 実装の開発環境方針）に対する、Gallery 提出観点の
追加レイヤー。

## Scope

このトピックが扱うのは「提出前に技術的に詰んでおくべき項目」のみ。
実際に Alfred Forum へ投稿し、Gallery チームからの招待を経て提出するかどうか
（[Process](#process) 参照）は各プロジェクトの判断であり、このトピックを
適用したからといって Forum 投稿や提出自体を義務付けるものではない。

## Official Policy Source

Gallery の提出基準は Alfred 公式ページが正本であり、随時更新される可能性がある:

- [alfred.app/submit](https://alfred.app/submit/) — 提出要件
- [alfred.app/submit/styleguide](https://alfred.app/submit/styleguide/) — README・スクリーンショットのスタイルガイド

以下のチェックリストはこれらのページの要点をまとめたものであり、正本ではない。
古くなっている可能性があるため、判断に迷ったら上記ページを再確認してから扱う。

## Checklist

- **署名・公証** — コンパイル済みバイナリを含む場合、Developer ID で署名し
  Apple の notarization を通す（macOS の Gatekeeper を回避する実装は不可）。
  スクリプトのみのワークフローは対象外
- **セルフアップデート禁止** — ワークフロー自身が自己更新する仕組みを持たない。
  Gallery に掲載されたワークフローは Alfred 本体の更新機能でアップデートされる
- **実行時の外部ソフトウェアインストール禁止** — インストール後に
  `pip install`・`brew install`・`curl` でのバイナリ取得等を行わない。実行に
  必要なコードはすべてワークフローパッケージ内に同梱する（ビルド時に取得して
  同梱するのは問題ない）
- **アイコン** — メインアイコンは 256×256px 以上、かつ正方形
- **キーワード** — 3文字以上。他のワークフローと衝突しにくい、意味の通る文字列にする
- **カテゴリ** — `info.plist` の `category` キーを、ワークフローの用途に合った
  有効な値で設定する（未設定のまま放置しない）。有効な値の一覧は
  [Relationship to alfred-workflow-notes](#relationship-to-alfred-workflow-notes) 参照
- **ユーザー設定** — ユーザーが変更しうる値は Alfred の Configuration Builder
  で公開する。変更しうる値が何もない場合は「対象外」でよい
- **README・説明文** — Gallery 上の表示言語である英語で記述し、
  [Style Guide](https://alfred.app/submit/styleguide/) の形式に従う:
  - `## Usage` は1〜2文の短い説明で始め、"via the `<keyword>` keyword"
    （Universal Action の場合は "via the Universal Action"）で締める
  - その直後に、入口（キーワード／Universal Action）ごとに1枚スクリーンショットを置く
  - モディファイアキーは該当スクリーンショット直下に `* <kbd>...</kbd> 説明`
    形式の箇条書きで示す（表形式にしない）
  - `## Setup` は手動の前提条件が実際にある場合のみ置く（Configuration の
    設定項目、アプリのインストール、Homebrew フォーミュラ、API キー取得の
    手順は含めない — Alfred・Gallery 側が別途案内する）
- **スクリーンショット** — 実際の Alfred ウィンドウをキャプチャしたもの
  （角丸・ドロップシャドウ付き、背景は透過）を使う。生のウィンドウスクリーン
  ショットをそのまま貼らない

## Process

Alfred は Gallery への自己申請フォームを持たない。公式に案内されている経路は
「まず [Alfred Forum](https://www.alfredforum.com/) で共有し、一定数のユーザーに
安定して使われていると判断された場合に Gallery チームから提出を招待される」という
招待制のみ。したがって Forum 投稿自体は本トピックのスコープ外とし、各プロジェクトが
必要と判断したときに個別に行う。

## Per-Project Tracking

上記チェックリストの充足状況は、各プロジェクトの `docs/alfred-gallery-readiness.md`
で個別に追跡する（`CI_POLICY.md` に対する各リポジトリの `.github/workflows/` と
同じ関係）。プロジェクトごとに次のような表で管理するとよい:

| Requirement | Status | Notes |
|---|---|---|
| （チェックリストの各項目） | ✅ Done / ⏳ Pending / ❌ Missing / N/A | 根拠へのリンク（リリース・Issue・ADR 等） |

自動化できない項目（実機での Alfred ウィンドウキャプチャ等）は、その場で
代替実装をせず GitHub Issue として記録する。

## Relationship to alfred-workflow-notes

`info.plist` の `category` キーの有効値一覧や、アイコンファイルの具体的な
技術要件など、実際の Alfred エクスポートからしか再生成できない技術リファレンスは
このトピックの対象外とする。`ALFRED_DEV_ENV.md` と同様、採用しているテンプレート／
親リポジトリ側の `docs/alfred-workflow-notes/`（[TEMPLATE_README_GUIDELINES.md](../TEMPLATE_README_GUIDELINES.md)
「Relationship to dev-charter Dev-Env Topics」参照）を正本とする。
