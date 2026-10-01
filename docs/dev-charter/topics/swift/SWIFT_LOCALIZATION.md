# Swift Localization

Swift / SwiftUI アプリで、アプリ内の言語設定を実装するときの標準を定義する。

対応言語・ロケール識別子・言語決定の優先順位は言語に依存しない方針として
[LOCALIZATION_POLICY.md](../../LOCALIZATION_POLICY.md) が定める。このトピックは、その方針を
Swift / SwiftUI で実装する形（型・保存・反映・設定画面・文言の書き方）を扱う。

この標準は、テンプレートへの実装と、複数の Swift アプリへの展開を経た形である。
Clean Architecture のレイヤー構造などアプリケーション設計方針は対象外
（[SWIFT_DEV_ENV.md](SWIFT_DEV_ENV.md) と同様、各プロジェクトの `AI_CONTEXT.md` を正本とする）。

## AppLanguage

アプリ内で選べる言語を、次の型で表す。`Packages/Core` の Domain に置き、Foundation のみに依存させる。

~~~swift
public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system
    case ja, en
    case zhHans = "zh-Hans"
    case hi, es, fr, pt

    public var id: String { rawValue }
}
~~~

- `rawValue` を保存値かつロケール識別子にする（`system` は `"system"`）
- 保存値の復元は `init(storedValue:)` で行い、不明な値は `system` として扱う
- 表示名は `nativeName` として各言語の自国語表記で固定する。`system` だけがローカライズ対象のため `nil` を返し、
  呼び出し側が `settings.language.system` をローカライズして表示する
- 保存キーは `appLanguage` とする（`storageKey` として型に持たせてよい）

### resolvedLocale

`resolvedLocale: Locale` は、[Language Resolution](../../LOCALIZATION_POLICY.md#language-resolution) の優先順位を実装する。

1. 明示の言語（`system` 以外）なら、その言語の `Locale(identifier: rawValue)`
2. `system` なら、`Locale.preferredLanguages` から、対応言語に一致する最初のもの
3. 一致がなければ英語

一致判定は言語コードで行う。中国語（`zh`）だけは文字体系で判定する。

- 文字体系がある場合は、`Hans` のときに限り `zh-Hans` とする（`zh-Hant` は対応外）
- 文字体系がない場合は、地域で判定する。`zh-TW`・`zh-HK`・`zh-MO` は繁体字として対応外にし、
  それ以外（`zh`・`zh-CN`・`zh-SG` など）は簡体字として `zh-Hans` とする

対応外は英語にフォールバックする。
`preferredLanguages` を引数に取るオーバーロードを用意すると、テストで差し替えられる。

## Storage

保存先は App Group の `UserDefaults(suiteName:)` の `appLanguage` キーを標準とする。
Widget・Intents・Keyboard の Extension が同じ値を読めるためである。SwiftUI からは
`@AppStorage(AppLanguage.storageKey, store: ...)` で読み書きする。

保存先の例外は、アプリ側の制約があるときだけ許す。

- Widget のサンドボックス制約などで `UserDefaults` を共有できないアプリは、既存の共有手段（設定ファイル、
  共有ストア等）に保存してよい。その場合も保存値は `rawValue` とし、旧形式や未知の値は `system` として読む
- 既存アプリの保存値を変える場合は、旧値を 1 回だけ読み替える移行を入れる（移行先に値があれば上書きしない）

## Applying the Language

反映は 2 層に分ける。

### SwiftUI

全シーンのルート（ウィンドウ・`Settings`・メニューバー・独立パネル・シート）に
`.environment(\.locale, language.resolvedLocale)` を付ける。即時に反映される。
シーンを 1 つでも漏らすと、そのシーンだけシステム言語のままになる。

### Extension

Extension は App Group から `appLanguage` を読む。Widget は次の形にする。

- Provider が読み、タイムラインの entry（またはスナップショット）に含める
- View が `.environment(\.locale, ...)` を付ける
- アプリ側で言語を変えたら、Widget のタイムラインを再読込する

Keyboard Extension は、`UIHostingController` などのルートに同じ `.environment(\.locale, ...)` を付ける。

### Non-SwiftUI strings

`String(localized:)`・App Intents・AppleScript の文言は、環境の `locale` では変わらない。
これらが必要なアプリだけ、次のどちらかを使う。

- **選択言語の lproj を直接引く。** ビュー外の文言（パネルのタイトル、エラー文言、Widget のプレースホルダなど）に向く。
  即時に反映される。システムが返す文言（OS のエラー本文など）は対象外。実装は次の 2 通りがある
  - `AppLanguage` のメソッド（`localizedString(_:bundle:)`）: 解決した識別子の `.lproj` の `Bundle` から
    `localizedString(forKey:value:table:)` で引く。見つからなければ `bundle` の既定の解決（システム言語）に戻す。
    カタログがアプリ target にあるなら `.main`、Swift Package のリソースなら `Bundle.module` を渡す
  - 自由関数 `localizedString(_:locale:)`: `locale` を省略すると保存された言語設定に従う。ビューでは
    `@Environment(\.locale)` を渡すと、言語変更で再描画される。補間つきの文言は
    `String(localized: key, defaultValue: "...\(x)", bundle: languageBundle, locale: locale)` の形で
    `defaultValue` に補間を持たせる（キーは補間を含まない）
- **起動時に `AppleLanguages` へ書き込む。** App Intents・AppleScript など、環境の `locale` も lproj の直接参照も
  届かない箇所に使う。`UserDefaults.standard` の `AppleLanguages` へ選択言語を書き込み、反映はアプリの
  再起動後になる。使うアプリは、設定画面に「再起動後に反映される」旨を出す

どちらも、必要になったアプリだけが実装する（YAGNI）。テンプレートには含めない。

## Settings Screen

設定画面に「言語」セクションを置き、`AppLanguage.allCases` の `Picker` にする。

- 各項目の表示名は `nativeName`。`system` だけローカライズした文言を出す
- macOS は `Settings` シーン、iOS は設定タブなど、プラットフォームの導線に合わせる

## Strings in Code

SwiftUI のビューでは、環境の `locale` を参照する書き方を使う。`String(localized:)` は環境の `locale` を無視するため、
ビューの文言に使うとアプリ内の言語設定が反映されない。

~~~swift
// 推奨: 環境の locale に従う
Text("feature.title", bundle: .module)

// 避ける: 環境の locale を無視する
Text(String(localized: "feature.title"))

// 禁止: ハードコードされた文字列
Text("タイトル")
~~~

- Swift Package（`Packages/Core` 等）内のビューは `bundle: .module` を指定する
- `LocalizedStringKey` を引数に取る API（`Text`・`Label`・`Button` 等）にはキーをそのまま渡す
- 計算結果の文言（残り時間など）やビュー外の文言は環境の `locale` を購読しない。選択言語を明示的に解決して渡す
  （[Non-SwiftUI strings](#non-swiftui-strings) 参照）

### Localized Initializers in a Package

`Button(_:)`・`Label(_:systemImage:)`・`Section(_:)` などの標準イニシャライザは `bundle:` を取れない。
Swift Package のカタログ（`Bundle.module`）を引くには、`Text(_, bundle:)` をラベルに使う形が必要になる。
呼び出し側の差分を小さくするため、`bundle:` を取るイニシャライザを Core の `Shared` に 1 ファイルで用意する。

~~~swift
extension Button where Label == Text {
    init(_ key: LocalizedStringKey, bundle: Bundle, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) { Text(key, bundle: bundle) }
    }
}
~~~

`Label`・`Section`・`Picker`・`Toggle`・`TextField`・`ProgressView` も同じ形で書ける。呼び出し側は
`Button("common.done", bundle: .module) { ... }` になる。`alert`・`confirmationDialog`・`navigationTitle` は
`Text("key", bundle: .module)` を渡す。`ContentUnavailableView` は `Label` を使うクロージャ形式にする。

文言を返すプロパティ（enum の `label` など）は `String` ではなく `LocalizedStringKey`（または `Text`）を返す型にし、
使う側で `Text(x.label, bundle: .module)` にする。`String` で返すとキーそのものが表示される。

### Rebuilding on Language Change

言語の変更時に、ビューツリーの一部が古い言語のまま残ることがある（`Picker` の単位、アラート、タブ名など）。
その場合はルートに `.id(language)` を付けて作り直す。開いている画面の一時的な状態は戻るため、
必要になったアプリだけが採用する。

## String Catalog

- 文言は Xcode の String Catalog（`Localizable.xcstrings`）で管理する。Swift Package のリソースとして
  `Packages/Core/Sources/Core/Resources/` に置く
- `Package.swift` に `defaultLocalization` と `resources: [.process("Resources")]` を指定する。`defaultLocalization` の値は、
  アプリの `project.yml` の `developmentLanguage`（Xcode の development region）と同じにする。
  値は [LOCALIZATION_POLICY.md](../../LOCALIZATION_POLICY.md) の開発言語に従う（クローズドなら `ja`、公開 OSS なら `en`）
- カタログは対応言語の 7 言語すべてで揃える。ポルトガル語の言語キーは `pt`（`pt-BR` などの地域付きにしない）
- アプリが対応言語の一部しか翻訳していない場合は、翻訳を追加するか、選択肢を実際の対応言語に絞るかを決める。
  選べるのに翻訳がない言語を残さない

### Key Naming Convention

文言のキーは `<スコープ>.<内容>` のドット区切りにする。文言そのものをキーにしない。

~~~text
common.retry        → 再試行
common.error.title  → エラー
settings.language.title   → 言語
settings.language.system  → システム設定
~~~

文言を変えてもキーが変わらず、翻訳の対応づけが壊れない。スコープは機能名・画面名・共通（`common`）などで切る。
複数の機能で使う文言（OK、キャンセル、削除など）は `common.*` に置き、単位は `unit.*` のようにまとめる。

### Interpolated Keys

SwiftUI は補間つきの `Text("score \(n)")` から、`score %lld` のようなキーを自動で作る。補間を含む文言は、
次のどちらかに統一する。

- キーを補間なしのドット区切りにし、値に書式指定子（`%@`・`%lld`）を持たせる。`String(localized: "key", defaultValue: "...\(x)")`
  や `String(format: localizedString("key"), x)` で引く。ビュー外でも使える
- 自動生成されるキーの形（`key %lld`）を保つ。コードの補間リテラルとカタログのキーが一致していないと、
  翻訳が当たらず英語（開発言語）のまま表示されるので、置き換え後に一致を確認する

### Renaming Existing Keys

文言そのものをキーにしている既存アプリを移行するときは、次の点に注意する。

- カタログのキーと、コードのリテラルを同じ対応表で一括して変える。対応表はカタログから生成し、
  適用後に「コードのキーがカタログにあるか」「カタログのキーが使われているか」をスクリプトで確認する
- JSON の整形を変えない（Xcode の書式を保つ）。変えるとキー以外の差分が膨らむ
- 英語の語（`Goal`・`Date`・`kg` など）がキーのときは、データ層の識別子（SwiftData のストア名、集計の系列名、
  単位の文字列）と同じリテラルが他の用途にも現れる。リテラルの全置換はせず、`Text(`・`Button(`・`String(localized:`
  などローカライズ用の呼び出しの文脈に限る。`String` 型で受ける箇所に置き換えると、キーがそのまま表示される
- 型で文言と分かるもの（`LocalizedStringResource` を返す enum、App Intents の `title:`）は、文脈の判定では
  拾えないので、ファイル単位で対象にして目視で確認する
- カタログに無かった文言（日本語や英語が固定で表示されていたもの）が見つかったら、キーと全言語の訳を追加する
- 対応表による一括置換では、コードとカタログの対応が合っているかをビルドが抽出するキーで確認する。
  `xcodebuild ... SWIFT_EMIT_LOC_STRINGS=YES build` が出力する `*.stringsdata` のキーを集め、「コードのキーがカタログにある」
  「カタログのキーがコードから抽出される」を突き合わせる（macOS と iOS の両方をビルドする）
- 抽出されないカタログのキーは、`String` 型の引数を経由している（`LabeledContent(title)`・`Text(title)` に `String` を渡している）可能性がある。
  `String` は翻訳されず verbatim 表示になるため、キーを変えた後は英語の原文ではなくキーがそのまま画面に出る。
  引数の型を `LocalizedStringKey` にする（意図して `localizedString` で引く箇所は除く）
- 補間を含む文言（`Text("Years: \(n)")`）のカタログのキーは、整数なら `%lld`、文字列なら `%@`、`specifier:` つきなら
  `%.1f` のように、コードの引数の型から作られる。型が違うと一致せず、翻訳が当たらない。ドット区切りにするときは
  `duration.years %lld` のように、キーの後ろに書式指定子を残す

## Testing

`AppLanguage` は Foundation のみに依存するため、ユニットテストで次を確認する。

- 明示の言語は、その言語の `Locale` になる
- `system` は、`preferredLanguages` の最初の対応言語に解決される
- 対応外の言語、繁体字（`zh-Hant`・`zh-TW` 等）は英語になる
- 不明な保存値は `system` になる

カタログの文言をテストで確認する場合、`String(localized:)` は使わず、ソースの `Localizable.xcstrings` を直接
パースする。Xcode 26.x の SwiftPM は `.xcstrings` を `.lproj` にコンパイルしないため、`String(localized:)` を使う
テストは `swift test` で失敗することがある。

CI の Xcode でも同じことが起きる。カタログが `.lproj` にコンパイルされないと、文言を引く処理（`String(localized:)`・
`localizedString`・`Bundle.module`）は訳ではなくキーをそのまま返す。そのため、次の点に注意する。

- 文言のテキスト（`"太字"` など）を直接期待するテストは、ローカルでは通っても CI で落ちる。期待値は、テスト対象自身が返す
  値（例: `MarkdownAction.bold.syntax.placeholder`）か、空でないことの確認にする
- 文言そのものをキーにしているアプリでは、キーが返ることで偶然通る。キーをドット区切りに変えた時点で、
  そのようなテストが初めて落ちる
- ローカルと CI で結果が変わらないように、lproj を引くテストは fixture bundle（一時ディレクトリに `ja.lproj/Localizable.strings` を
  書いた `Bundle`）を使う。見つからない場合の確認には、どの lproj にもないキーを使う（実行環境の言語に依存させない）
- 保存された言語設定を読む処理は、テストの前後で保存値を固定・復元する（実行環境の言語に依存させない）

## Verification

次はユニットテストで確認できないため、実機（または実行環境）で確認する。

- `Picker` を切り替えると、すべてのシーンの表示が即時に変わる
- Widget・Keyboard などの Extension が、アプリの言語に追従する
- `AppleLanguages` 方式を使うアプリは、再起動後に反映される
