# Swift Development Environment

macOS/iOS 向け SwiftUI アプリ（クローズドプロジェクト前提）共通の開発環境構成を定義する。

このトピックは「Swift/Xcode を使う開発環境」の一般方針であり、Clean Architecture の
レイヤー構造（Feature/Domain/Infrastructure）や `@Observable` 等の実装パターンといった
アプリケーション設計方針は対象外。それらは各プロジェクトが採用しているテンプレート／親
リポジトリ側の `AI_CONTEXT.md` を正本とし、そちらを参照する（[TEMPLATE_README_GUIDELINES.md（full）](https://github.com/y-marui/dev-charter/blob/full/topics/TEMPLATE_README_GUIDELINES.md)
「Relationship to dev-charter Dev-Env Topics」参照）。

## Version Policy

- Xcode 自体のバージョンは固定しない。CI は `macos-latest` に同梱された Xcode を使う
- Deployment Target は別ファイルで固定せず、`project.yml`（XcodeGen）の
  `options.deploymentTarget` を単一の情報源とする
- Swift 言語バージョンは対象ごとに管理場所が異なる：
  - アプリターゲットの `SWIFT_VERSION`（言語モード）は `project.yml` の
    `settings.base` で指定する
  - ローカルパッケージ（`Packages/Core` 等）の Swift ツールバージョンは
    `Package.swift` 先頭の `// swift-tools-version:` ディレクティブに従う
  - `.swiftformat` の `--swiftversion` はフォーマッタの構文解釈バージョンの指定であり、
    上記 2 つの言語バージョンと必ずしも一致しなくてよい（フォーマット規則の対象範囲を
    決めるものであり、ビルド時の言語モードには影響しない）

## Toolchain

- プロジェクト生成: **XcodeGen**（`project.yml` を単一の情報源とし、`.xcodeproj` は
  リポジトリにコミットしない。`xcodegen generate` で都度生成する）
- Linter: **SwiftLint**（`.swiftlint.yml` で設定を管理し、CI では `swiftlint --strict`
  を実行する）
- Formatter: **SwiftFormat**（`.swiftformat` で設定を管理する）
- 上記 3 点はいずれも Homebrew でインストールする（`brew install xcodegen swiftlint
  swiftformat`）。バージョンをリポジトリ側で固定する仕組みは持たない

```yaml
# project.yml（抜粋）
name: MyApp

options:
  deploymentTarget:
    macOS: "26.0"
  developmentLanguage: ja

settings:
  base:
    SWIFT_VERSION: "6.0"

packages:
  Core:
    path: Packages/Core

targets:
  MyApp:
    type: application
    platform: macOS
    sources:
      - path: App/macOS
    dependencies:
      - package: Core
```

- SwiftUI のプロパティラッパー属性は改行させない
  （`attributes.always_on_same_line`）。対象は `@Environment` / `@AppStorage` /
  `@SceneStorage` / `@FetchRequest`

```yaml
# .swiftlint.yml（抜粋）
attributes:
  always_on_same_line:
    - "@Environment"
    - "@AppStorage"
    - "@SceneStorage"
    - "@FetchRequest"
```

### Changing SwiftLint Rules

- ルールを**無効化**する場合 → PR に理由を必ず記載する
- ルールを**追加**する場合 → 全ファイルに違反がないことを確認してからマージする

## Project Structure (App/ + Packages/Core/)

- `App/<platform>/`（`macOS/`・`iOS/`・`Widget/` 等） — プラットフォームごとの
  エントリーポイントと DI コンテナのみ。ビジネスロジックを置かない
- `Packages/Core/` — 全フィーチャーを含むローカル Swift Package。単体テスト可能な
  ロジックはすべてここに置く
- ルートの `Package.swift` は **`Packages/Core` のライブラリ・テストを手元で動かす
  ためだけ**に存在する（`swift test` の入口）。iOS アプリ本体のビルド・実行には
  `.xcodeproj`（XcodeGen 生成）が必要であり、`Package.swift` の `targets` は空でよい

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [.iOS(.v26), .macOS(.v26)],
    dependencies: [
        .package(path: "Packages/Core")
    ],
    targets: []
)
```

## Testing

- **swift test**（`Packages/Core` に対して実行）でユニットテストを実行する
- テストは `Packages/Core/Tests/CoreTests/` に置き、依存はプロトコル経由でモックする
- Given / When / Then 構造で書く

```bash
swift test --package-path Packages/Core
```

## CI Integration

`CI_POLICY.md` の job 構成に従いつつ、以下の点は他スタックと異なる:

- ビルド・Lint・テスト系の job は `runs-on: macos-latest`（Xcode・`xcodebuild` の
  ため。`ubuntu-latest` では動かない）
- ドキュメントのみの変更で `lint`/`test`/`build` を skip できるよう、`changes` job
  （`dorny/paths-filter`）で Markdown・`docs/**` 等を除外し、`code` フラグが `true`
  のときだけ後続 job を実行する
- SwiftLint・XcodeGen はいずれも Homebrew でインストールする（バージョンを pin しない）
- 署名なしビルドで検証する（`CODE_SIGN_IDENTITY=""` / `CODE_SIGNING_REQUIRED=NO` /
  `CODE_SIGNING_ALLOWED=NO`）。配布用の署名付きビルドは CI では行わない

```yaml
lint:
  name: Lint
  needs: changes
  if: needs.changes.outputs.code == 'true'
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v7
    - name: Install SwiftLint
      run: brew install swiftlint
    - name: Run SwiftLint
      run: swiftlint --strict

test:
  name: Test
  needs: changes
  if: needs.changes.outputs.code == 'true'
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v7
    - name: Resolve packages (Core)
      run: swift package resolve
      working-directory: Packages/Core
    - name: Run Core unit tests
      run: swift test
      working-directory: Packages/Core

build:
  name: Build
  needs: [changes, security, lint, test]
  if: needs.changes.outputs.code == 'true'
  runs-on: macos-latest
  env:
    SCHEME: MyApp
  steps:
    - uses: actions/checkout@v7
    - name: Install XcodeGen
      run: brew install xcodegen
    - name: Generate Xcode project
      run: xcodegen generate
    - name: Build
      run: |
        xcodebuild \
          -project "$SCHEME.xcodeproj" \
          -scheme "$SCHEME" \
          -destination "platform=macOS" \
          -derivedDataPath build \
          CODE_SIGN_IDENTITY="" \
          CODE_SIGNING_REQUIRED=NO \
          CODE_SIGNING_ALLOWED=NO \
          SWIFT_STRICT_CONCURRENCY=complete \
          build
```

iOS ターゲット（Widget Extension を含む）を追加した場合は、上記 `build` job とは
別に `-destination "generic/platform=iOS Simulator"` を使う iOS 向けビルド job を
追加する。

## Dependency Policy

- 既定でサードパーティ依存ゼロ（外部パッケージを追加しない）
- 追加してよい依存: Apple 純正 framework の薄いラッパー、テスト専用ライブラリ
  （`testTarget` にのみ追加）
- 追加してはいけない依存: Combine ベースのライブラリ（`async/await` に統一）、
  巨大な UI フレームワーク（SwiftUI に統一）
- 依存を追加する場合は該当パッケージの `Package.swift` に追記し、`docs/architecture.md`
  等のアーキテクチャ変更履歴に理由を記録する
