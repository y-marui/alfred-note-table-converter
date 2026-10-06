# Alfred Workflow Development Environment (Go)

Alfred 5 Script Filter ワークフローを Go で実装するプロジェクト共通の開発環境・
アーキテクチャ方針を定義する。`PYTHON_DEV_ENV.md` の Alfred ワークフロー版。

このトピックは「Go を使う開発環境」の一般方針であり、`info.plist` の
オブジェクトスキーマや Configuration Builder のキー一覧といった、実際の
Alfred エクスポートからしか再生成できない Alfred 固有の技術リファレンスは
対象外。それらは各プロジェクトが採用しているテンプレート／親リポジトリ側の
docs を正本とし、そちらを参照する（[TEMPLATE_README_GUIDELINES.md](../TEMPLATE_README_GUIDELINES.md)
「Relationship to dev-charter Dev-Env Topics」参照）。

## Version Policy

- Go のバージョンは `go.mod` の `go` ディレクティブに従う。Python の
  `.python-version` のような別ファイルでの固定は不要 — `go build`/`go test`
  が `go.mod` を直接読む
- 新しい Go リリースを採用する場合は `go.mod` のディレクティブを上げるだけでよい

## Toolchain

- Linter/Formatter: **gofmt** + **go vet**（別途 linter は導入しない。
  プロジェクトが大きくなり必要性が確認されてから golangci-lint 等を検討する）
- テスト: **go test**
- 依存関係: **既定でサードパーティ依存ゼロ**（`go.mod` に `require` ブロックを
  持たない）。Alfred ワークフローは単機能の小さいバイナリであり、Alfred は
  ランタイムインストール手順を持たないため、依存追加はそのままワークフロー
  パッケージのサイズ増加に直結する

## Architecture (one binary per Alfred node, `cmd/`+`internal/`)

- `cmd/<workflow-name>-alfred/`（複数の Script Filter/Run Script ノードを持つ
  ワークフローでは、ノードごとに `cmd/<name>-alfred`、`cmd/<name>-paste-alfred`
  のように分ける）— Alfred が実行する**唯一のコード**。argv ディスパッチと
  環境変数読み取り、Alfred の JSON 契約への出力以外のビジネスロジックを
  書かない
- `internal/<domain>/` — Alfred 非依存の純粋ロジック。Alfred を起動せずに
  単体テスト可能に保つ
- `internal/scriptfilter/` — Script Filter JSON レスポンス型とその書き出し。
  `internal/<domain>` から `internal/scriptfilter` への依存は禁止（逆方向の
  依存だけを許可する）
- `main()` はディスパッチを `recover()` でラップする — 未捕捉の panic は
  Alfred 側で空白表示や無反応になるため、必ずユーザーに見える形（Script
  Filter のエラー行など）に変換する

## Alfred Runtime

- Alfred の Script Filter / Run Script ノードはコンパイル済みバイナリを
  直接実行する。インタプリタ選択やランタイムラッパースクリプトは不要
  （Python ワークフローの `use_uv` トグルに相当するものはない）
- `darwin/amd64` と `darwin/arm64` それぞれでビルドし、`lipo` で1つの
  ユニバーサルバイナリにマージする。ランタイムインストール手順なしで
  Intel・Apple Silicon 両方でネイティブ動作する

```bash
GOOS=darwin GOARCH=amd64 go build -o .build/name-amd64 ./cmd/name-alfred
GOOS=darwin GOARCH=arm64 go build -o .build/name-arm64 ./cmd/name-alfred
lipo -create -output .build/name-alfred .build/name-amd64 .build/name-arm64
```

- `workflow/`（`info.plist` + `icon.png`）とビルド済みバイナリを
  `dist/<name>-<version>.alfredworkflow`（zip）にまとめる。`workflow/`
  自体にバイナリ成果物をバージョン管理しない

## Configuration Management

- ユーザーが設定する値はすべて Alfred の Configuration Builder
  （`info.plist` の `userconfigurationconfig`）に入れる。Alfred の
  `variables` キー（ワークフロー全体の environment variable）は使わない
- Config Builder の値は Alfred がスクリプト実行時に環境変数として渡すため、
  別途設定ファイル形式を自作する必要はない（`os.Getenv()` で読める）
- 設定項目の型は用途に応じて選ぶ: `textfield` / `checkbox` / `select` /
  `file`（`filepicker`）/ `password`

## Native vs. Go

- Alfred ネイティブのオブジェクト（Copy to Clipboard、Post Notification、
  Arguments and Variables、Conditional、Dispatch Key Combo 等）で完全に
  代替できる処理は、Go 側に書かない。バイナリは「Alfred の標準ノードでは
  できないこと」だけを担当する
- 判断の勘所（複数プロジェクトで確認済み）:
  - クリップボードの**読み取り**は Alfred の `{clipboard}` プレースホルダー
    （Arguments and Variables ノード経由）を使い、Go 側で `pbpaste` を
    呼ばない
  - Copy to Clipboard はテキストのみ対応（画像用のキーがない）。画像を
    ペーストボードに書く必要がある場合は Go 側で `osascript` の
    `read (POSIX file ...) as TIFF picture` に頼らざるを得ない
  - Post Notification は上流スクリプトが設定した変数を `{変数名}` で
    そのまま表示できる。**「どのノードが実行されるか」を変えたい場合は
    Conditional ノードが必要**だが、**「同じノードが何を表示するか」だけ
    変えたい場合は共有変数で足りる**（後段ノードは上流スクリプトの終了
    コードで分岐できないため、この違いを理解しているかどうかで実装が
    大きく変わる）
- `info.plist` の正確なオブジェクトスキーマと、各オブジェクトについて
  「確認済み／未検証」の制約は、採用しているテンプレート／親リポジトリ側の
  技術リファレンスドキュメントに記録する（実際の Alfred エクスポートから
  再生成された技術リファレンスであり、原則を扱うこのトピックとは分離する）。
  Go 実装に倒す前に必ず参照する

## Testing

- `internal/` 配下は `go test` で単体テストする
- `cmd/` 配下は、argv ディスパッチや環境変数の配線に分岐ロジックがある場合、
  `exec.Command("go", "build", ...)` でビルドしてから実行し、stdout・終了
  コードを検証する薄い統合テストを追加する
- クリップボード・キーストロークシミュレーションなど OS 境界に依存する
  処理は、モックではなく小さいインターフェース越しにフェイクへ差し替えて
  テストする
- 実際の HTTP 通信はテストで行わない。これらのワークフローは通常オフライン・
  ローカル完結（`SOFTWARE_DESIGN_PRINCIPLES.md` のローカルファースト参照）
  であり、外部通信が必要になること自体が稀

## CI Integration

`CI_POLICY.md` の job 構成に従いつつ、以下の点は Python ワークフローと異なる:

- ビルド・テスト系の job は `runs-on: macos-latest`（`lipo` と darwin
  バイナリのため。`ubuntu-latest` では動かない）
- `actions/setup-go@v7` の `go-version-file: go.mod` を使い、バージョンを
  リテラルで pin しない（`go.mod` を単一の情報源とする）

```yaml
lint:
  name: Lint
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v7
    - uses: actions/setup-go@v7
      with:
        go-version-file: go.mod
    - name: gofmt
      run: |
        out=$(gofmt -l .)
        if [ -n "$out" ]; then echo "$out"; exit 1; fi
    - run: go vet ./...

test:
  name: Test
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v7
    - uses: actions/setup-go@v7
      with:
        go-version-file: go.mod
    - run: go test ./...

build:
  name: Build
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v7
    - uses: actions/setup-go@v7
      with:
        go-version-file: go.mod
    - name: Build .alfredworkflow
      run: make build-workflow
    - uses: actions/upload-artifact@v7
      with:
        name: alfredworkflow
        path: dist/*.alfredworkflow
```

## Release Process

- `v*` タグの push で CI の build job とは別の `release.yml` をトリガーする。
  タグが `workflow/info.plist` の `version` と一致するか検証してから
  `make build-workflow` を実行し、SHA-256 チェックサムを添えて GitHub
  Release を作成する
- リリースノートは GitHub の自動生成（`--generate-notes`）に頼らず、
  `scripts/extract-changelog.sh <tag>` で `CHANGELOG.md` の該当バージョンの
  セクションを抽出したものを使う。一致するエントリがなければ
  `Release vX.Y.Z` にフォールバックし、常に exit 0 とする（リリース自体を
  失敗させない）
- コード署名・notarization・build provenance の attestation は、Apple
  Developer 証明書等のシークレットを用意したプロジェクトのみ有効化する
  オプション拡張であり、必須ではない
- **ローカルフォールバック**: Actions が実行できない場合（billing・spending
  limit の問題等）に備え、同じビルド・チェックサム・GitHub Release 作成の
  手順を `scripts/release.sh`（`make release` で呼び出す）としてローカルからも
  実行できるようにする。タグの push・Release 作成それぞれの実行前にユーザーへ
  確認する（署名・notarization は `CODESIGN_IDENTITY` 等が未設定ならスキップし、
  通常の未署名ローカルビルドと同じ扱いにする）

## Dependency Policy

- 既定でサードパーティ依存ゼロ（`go.mod` に `require` ブロックを持たない）
- 別途コンパイル済みの姉妹 CLI をラップする場合（例: 専用の検出・変換ロジックを
  別リポジトリの Go バイナリとして配布し、こちらはそれを呼び出すだけにする
  構成）は、そのバイナリのバージョンとチェックサムをリポジトリ内に固定し、
  ビルド時に検証してから使う。ビルド時の未検証ダウンロードは行わない
