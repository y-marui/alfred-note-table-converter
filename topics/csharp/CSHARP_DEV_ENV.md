# C# Development Environment

Windows 向けデスクトップアプリ・ツール（.NET、WinForms 等）共通の開発環境構成を定義する。

このトピックは「.NET SDK を使う開発環境」の一般方針であり、アプリケーションの設計方針
（レイヤー構造・UI 設計・ドメインロジック）は対象外。それらは各プロジェクトが採用している
テンプレート／親リポジトリ側の `AI_CONTEXT.md` を正本とし、そちらを参照する
（[TEMPLATE_README_GUIDELINES.md（full）](https://github.com/y-marui/dev-charter/blob/full/topics/TEMPLATE_README_GUIDELINES.md)
「Relationship to dev-charter Dev-Env Topics」参照）。

## Version Policy

- **.NET は LTS を使う。** 公式のサポート期間は、LTS が 3 年（偶数バージョン）、STS が 2 年（奇数バージョン）。
  確認時点（2026-10）の LTS は .NET 10（2025-11-11 リリース、2028-11-14 まで）で、.NET 8 は
  **2026-11-10 にサポートが終了する**。STS（.NET 9 等）は使わない
  （[Support Policy](https://dotnet.microsoft.com/en-us/platform/support/policy/dotnet-core) 参照）
- LTS は 2 年ごとの 11 月に出る。次の LTS が出たら、現行 LTS のサポート終了（リリースの約 3 年後）
  までに移行する。移行は `global.json`・`TargetFramework`・CI・README・`DEVELOPING.md` を同じ PR で更新する
- **SDK は `global.json` で固定する。** ローカルと CI で同じ SDK を使い、ビルドを再現可能にする
  （公式も CI では範囲指定を推奨している）。`rollForward` は `latestFeature` にする
  （指定した版以降の、同じメジャー・マイナーの最新の機能バンド・パッチ）

```json
{
  "sdk": { "version": "10.0.100", "rollForward": "latestFeature" },
  "test": { "runner": "Microsoft.Testing.Platform" },
  "msbuild-sdks": { "WixToolset.Sdk": "6.0.2" }
}
```

- `global.json` の `sdk.version` は、ワイルドカードや `10.0` のような省略形を受け付けない（`10.0.100` のように書く）
- `test.runner` は、xUnit v3 のように Microsoft.Testing.Platform（MTP）で動くテストに必須
  （.NET 10 SDK の `dotnet test` が、VSTest モードか MTP モードかをここで判断する）。
  `msbuild-sdks` は、MSBuild SDK（WiX 等）のバージョンを 1 か所に集約する
- Dependabot は `dotnet-sdk` ecosystem で `global.json` の SDK 更新を扱える

## Toolchain

- ビルド・実行・テストは **`dotnet` CLI** で行う（Visual Studio を前提にしない）。ローカルの前提は
  .NET SDK だけで、`dotnet build` が入口になる
- ソリューションは **`.slnx`**（.NET 10 の `dotnet new sln` の既定）。XML で読みやすく、diff・マージが
  扱いやすい。`dotnet build` / `dotnet format` / `dotnet test` が `.slnx` で動く
- 共通のビルド設定は、リポジトリ直下の次の 4 ファイルに集約する:

| ファイル | 役割 |
|---|---|
| `global.json` | SDK・テストランナー・MSBuild SDK のバージョン |
| `Directory.Build.props` | 全プロジェクト共通のプロパティ（`Version`、`Nullable`、解析設定） |
| `Directory.Packages.props` | NuGet のバージョン（Central Package Management） |
| `.editorconfig` | 整形・コードスタイル・アナライザの重大度 |

- **Central Package Management（CPM）を常に使う。** `Directory.Packages.props` に
  `<ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>` と `<PackageVersion>` を書き、
  各 csproj の `<PackageReference>` には `Version` を書かない。依存の追加・更新が 1 か所に集まる。
  Dependabot の `nuget` ecosystem は CPM に対応している
- `Directory.Build.props` に置く値:
  - `<Version>`（アセンブリと MSI の単一の情報源。`CHANGELOG.md` と揃える）
  - `<Nullable>enable</Nullable>`、`<ImplicitUsings>enable</ImplicitUsings>`
  - 解析設定（[Lint](#lint) 参照）

## Lint

C# の lint は、SDK 同梱の **Roslyn アナライザ**（コード品質の `CA` 系と、コードスタイルの `IDE` 系）と
`dotnet format` の組み合わせで行う。既定のままだと、警告に出る規則が少数で、CI も警告で落ちない
ため、実質ほとんど何も検査しない。次の設定で、実効性のある lint にする:

```xml
<!-- Directory.Build.props -->
<PropertyGroup>
  <AnalysisLevel>latest-Recommended</AnalysisLevel>
  <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
  <!-- 警告をエラーにするのは CI のときだけ（GitHub Actions は CI=true を設定する）。
       ローカルでは警告として見え、作業を止めない -->
  <TreatWarningsAsErrors Condition="'$(CI)' == 'true'">true</TreatWarningsAsErrors>
</PropertyGroup>
```

- `AnalysisLevel` は `latest-Recommended`（`AnalysisMode` が `Recommended`。`Default` より多くの規則が
  ビルド警告になる）。SDK を上げると規則が増えるため、増えた警告は更新 PR で解消する
- `EnforceCodeStyleInBuild` で、`IDE` 系の規則をコマンドラインのビルドでも警告・エラーにできる。
  各規則の重大度は `.editorconfig` に書く
- **サードパーティのアナライザは既定では入れない**（StyleCop・Roslynator・Meziantou・SonarAnalyzer 等）。
  不足を実感した時点で、`PrivateAssets="all"` の開発専用依存として追加し、理由を記録する
- テストプロジェクトでは、`Method_Condition_Expected` 形式のテスト名が `CA1707`（名前にアンダースコア）に
  触れるので、`.editorconfig` で緩める:

```ini
[tests/**.cs]
dotnet_diagnostic.CA1707.severity = none
```

- フォーマットは `dotnet format <ソリューション> --verify-no-changes`（CI で差分があれば失敗させる）
- 規則を**無効化**する場合は PR に理由を書く。規則を**追加**する場合は、全ファイルに違反がないことを確認してからマージする

## Project Structure

```text
<repo>/
├── global.json
├── Directory.Build.props
├── Directory.Packages.props
├── .editorconfig
├── <Name>.slnx
├── src/
│   ├── <Name>.App/          # WinForms アプリ（エントリポイント、UI）
│   └── <Name>.Core/         # UI に依存しないロジック
├── tests/
│   └── <Name>.Core.Tests/   # xUnit v3
├── installer/               # WiX（MSI）
└── docs/
```

- ソースは `src/<Project>/`、テストは `tests/<Project>.Tests/` に置く
- **`Core` は UI 非依存にする。** `System.Windows.Forms` / `System.Drawing` に依存させず、`net10.0` を
  対象にする。UI に依存する処理（画像の変換・描画）は `App` 側に置く。これにより Windows 以外でも
  ビルド・テストでき、純粋関数としてテストしやすい
- 単一の小さなツールは `src/<Name>/` 1 つでよい。複数の実行ファイルがロジックを共有する場合に、
  `Core` を分ける
- `bin/`・`obj/`・`dist/` は `.gitignore` に入れる（ビルド成果物はコミットしない）
- 実行機固有の設定は `.gitignore` 対象にし、`*.example` だけをコミットする

## App Shell Defaults

常駐する WinForms アプリ（トレイアプリ）の土台として、次を標準にする:

- **トレイ**は `ApplicationContext` に `NotifyIcon` を載せる（隠したフォームを置かない）。`Dispose` で
  `NotifyIcon` を破棄する
- **高 DPI** は `<ApplicationHighDpiMode>PerMonitorV2</ApplicationHighDpiMode>`（csproj）
- **単一インスタンス**は名前付き `Mutex` で保証する。2 つ目の起動は何もせずに終了する
- **未処理例外**は `Application.ThreadException` / `AppDomain.UnhandledException` で、
  `%APPDATA%\<App>\app.log` に書いて終了する。ロギングのライブラリは入れない
- **設定**は `%APPDATA%\<App>\settings.json`（型付きの設定。ユーザーごと）。`Core` に型と Load/Save を
  置き、単体テストの対象にする。設定は独立した「設定」ウィンドウで編集し、トレイのメニューには
  「設定…」と「終了」を置く
- ローカライズ・DI（Generic Host）・ロギングのライブラリは、既定では入れない。必要になったら、
  `LOCALIZATION_POLICY.md` と依存方針に従って追加する

## Build and Publish

配布する成果物は、**自己完結（self-contained）のフォルダ**（win-x64）で作り、インストーラー
（MSI）に載せる。利用者の PC に .NET ランタイムが無くても動く。**単一ファイル（`PublishSingleFile`）
にはしない。** インストーラーで配るなら単一にする理由が薄く、自己展開による起動の遅さや
アンチウイルスの誤検知の原因になる。

```xml
<!-- 実行ファイルの csproj -->
<RuntimeIdentifier>win-x64</RuntimeIdentifier>
<SelfContained>true</SelfContained>
```

```powershell
dotnet publish src/<Name>.App -c Release -o publish
```

- `OutputType` は、UI を持つ常駐アプリは `WinExe`（コンソールを出さない）、コンソールツールは `Exe`
- **Windows 専用のスタックである。** WinForms/WPF は `net10.0-windows` を対象にするため、Linux では
  `EnableWindowsTargeting` を指定しても `restore`/`build` までしか確かめられない。このため CI の
  `lint`・`build` は Windows ランナーで行う
- ビルドのコマンドは `Makefile`（または同等のスクリプト）に集約し、README・CI から同じコマンドを呼ぶ

## Installer (MSI)

**配布の入口はインストーラー（MSI）に一本化する。** exe を直接配る経路や、アプリ自身がショートカットを
作る経路（`--install` 等）は持たない。開発時の起動は `dotnet run` で足りる。

- **WiX 6.x** の SDK スタイル（`.wixproj`）で、`dotnet build` により MSI をビルドする。バージョンは
  `global.json` の `msbuild-sdks` で固定する。`.wixproj` の SDK は `Sdk="WixToolset.Sdk"`（バージョンなし）
- **インストーラーのプロジェクトは `.slnx` に含めない。** publish したフォルダが入力なので、ソリューション全体の
  ビルド（`lint` の `dotnet build` 等）が、publish 前に失敗する。publish のあとに、`.wixproj` を単独でビルドする
- publish したフォルダは、`Files` 要素で丸ごと取り込む（Heat によるハーベストは非推奨）。**`<Feature>` は
  書かない**（明示すると暗黙の既定 feature が作られず、`Files` の部品が「親 Feature なし」の
  `WIX0267` になる）。ショートカット等の部品も、`Package` 直下に置けば暗黙の feature に入る
- インストールの範囲は `Scope="perMachine"`（`Program Files`）を既定にする。ユーザーごとの設定は
  `%APPDATA%` に置くので、`Program Files` に書き込めなくても動く
- `MajorUpgrade` を入れ、上書きアップグレードできるようにする。`UpgradeCode` は**製品ごとに固定の GUID**
  （テンプレートから作ったときに新しく採番し、以後変えない）。テンプレートの仮の値は、全部 0 の GUID に
  してはならない（MSI の検証 ICE74 で不正になる。クリーンビルドでだけ失敗し、増分ビルドでは検証が
  省かれて通るため、気づきにくい）。有効な GUID を入れる。`Manufacturer` に `[AUTHOR]` のような
  角括弧のプレースホルダを書くと、プロパティ参照と解釈されて `WIX1077` になる
- MSI のバージョンは、`Directory.Build.props` の `<Version>` を `$(Version)` で受ける（二重管理しない）
- CI の `build` でも同じコマンドで MSI をビルドし、壊れていないことを確認する
- **self-hosted の Windows runner（標準ユーザー）では、MSI の検証（ICE）が動かない。** runner のユーザーは
  Windows Installer サービスに触れず、`WIX0217`（ICE01 等が失敗）でビルドが落ちる。`WINDOWS_RUNNER` が設定
  されているときだけ `-p:SuppressValidation=true` を付けて検証を省く（hosted では検証する。ローカルでも検証する）

```xml
<!-- installer/Package.wxs（抜粋） -->
<Package Name="MyApp" Manufacturer="..." Version="$(Version)" UpgradeCode="..." Scope="perMachine">
  <MajorUpgrade DowngradeErrorMessage="A newer version of MyApp is already installed." />
  <MediaTemplate EmbedCab="yes" />
  <StandardDirectory Id="ProgramFiles64Folder">
    <Directory Id="INSTALLFOLDER" Name="MyApp">
      <Files Include="$(PublishDir)\**" />
    </Directory>
  </StandardDirectory>
</Package>
```

```powershell
dotnet build installer/<Name>.Installer.wixproj -c Release -p:PublishDir=<publish フォルダの絶対パス>
```

### WiX License (OSMF)

WiX v6 以降は、Open Source Maintenance Fee（OSMF）の対象。年間売上が 1 万ドルを超える組織が
wixtoolset の GitHub 組織へスポンサーすることが条件で、v7 以降は EULA の承諾も要る。**個人・研究室の用途
（収益なし）では支払いは不要**だが、収益が出るプロジェクトでは条件を確認する。WiX 5.x は OSMF の対象外。

### Release

タグ `vX.Y.Z` の push で、Windows ランナーが MSI をビルドし、GitHub Releases に添付する。
`GITHUB_TOKEN`（`contents: write`）だけを使い、OIDC・署名鍵は使わない。このため、private リポジトリでは
`WINDOWS_RUNNER`（self-hosted）で動かしてよい（[Runner Billing](https://github.com/y-marui/dev-charter/blob/full/topics/CI_POLICY.md#runner-billing)
の、OIDC を使う release job だけ hosted に残す規則に抵触しない）。MSI の署名は対象外
（利用者の PC で SmartScreen の警告が出る。必要になったら別途検討する）。

**リリースのたびに、`Directory.Build.props` の `<Version>` を上げる。** MSI の `MajorUpgrade` は、
`AllowSameVersionUpgrades` を指定しない限り、同じバージョンを上書きアップグレードとして扱わず、
「より新しいバージョンがインストールされています」で拒否する（実機で確認済み: 新しいビルドの
バージョンが公開済みのリリースと同じ場合、上書きできない）。同じ理由で、**手元でより高いバージョンを
ビルドしてインストールしたままにすると、それより低いバージョンの MSI は、アンインストールするまで
入らない**（開発用に別のバージョンを入れたときは、検証後にアンインストールする）。リリースの手順は、
バージョンの更新と `CHANGELOG.md` の `[Unreleased]` の確定を、タグを打つ前に済ませる順にする。

## Testing

- ロジックは、ハードウェアや UI に依存しない**純粋な関数**として `Core` に書き、実機なしで検証する
- **xUnit v3**（`xunit.v3`）を標準とし、`tests/<Project>.Tests/` に置く。xUnit v3 のテストプロジェクトは
  `OutputType` が `Exe` で、MTP で動く。`global.json` の `test.runner` が必要（[Version Policy](#version-policy) 参照）
- 実行は `dotnet test --solution <ソリューション>`（MTP モードの引数。VSTest 時代の `--nologo` 等は
  「不明なオプション」になる）
- Visual Studio のテストエクスプローラーは、xUnit v3 の環境で固まる事例が報告されている。`dotnet test`
  で通ることを正とする
- テストは CI の `build` job で、ビルドと同じ Windows job にまとめて実行する（job ごとの切り上げ課金を避ける）
- UI・実機（カメラ等）のテストは自動化せず、手動で確認する。手順は `DEVELOPING.md` に残す

## Dependency Policy

- 既定でサードパーティの NuGet 依存ゼロ
- 追加してよい依存: Microsoft が提供する公式パッケージ（例: `System.ServiceProcess.ServiceController`）、
  テストプロジェクトにだけ追加するテストライブラリ（`xunit.v3` 等）、開発専用のアナライザ
  （`PrivateAssets="all"`）
- 上記以外の依存を追加する場合は、**ユーザーに確認し**、理由とライセンスを `Directory.Packages.props`
  のコメントと `AI_CONTEXT.md` に記録する。バージョンは固定する（浮動バージョンにしない）
- 追加の可否を判断するときは、まず .NET 標準ライブラリ・WinForms の範囲で実現できないかを検討する

## CI Integration

`CI_POLICY.md` の job 構成（`changes`・`security`・`lint`・`build`・`gate`）に従う。
C# では次の点が他のスタックと異なる:

- `security`・`changes`・`gate` は Linux、`lint`・`build` は **Windows** ランナーで動かす
- `actions/setup-dotnet`（v6。v5 以降は node24 で動くため、runner は v2.327.1 以降）は `global-json-file: global.json`
  で、`global.json` と同じ SDK を入れる。`dotnet-version` を CI に重複して書かない
- `lint` は `dotnet format <ソリューション> --verify-no-changes` と、警告をエラーにした `dotnet build`
  （`CI=true` で `TreatWarningsAsErrors` が有効になる）
- `build` は `dotnet test --solution`、`dotnet publish`、MSI の `dotnet build`（wixproj）を実行する
- `changes` job（`dorny/paths-filter`）は、PR の情報を読むため `permissions` に
  `contents: read` と `pull-requests: read` を付ける。付けないと private リポジトリで
  `Resource not accessible by integration` で失敗する
- 各 job に `timeout-minutes` を付ける（目安は `changes`・`gate` が 5、`security`・`lint` が 10、`build` が 30）
- ワークフローのトップレベルに `concurrency`（古い run のキャンセル）を付ける
- private リポジトリでは、リポジトリ変数 `LINUX_RUNNER`・`WINDOWS_RUNNER` で self-hosted
  runner に切り替えられる。**ランナーを登録してから、両方の変数を設定する**
  （条件は [Runner Billing](https://github.com/y-marui/dev-charter/blob/full/topics/CI_POLICY.md#runner-billing) 参照）
- Dependabot（`.github/dependabot.yml`）は `nuget`・`dotnet-sdk`・`github-actions` の 3 つの ecosystem を設定する

```yaml
lint:
  name: Lint
  needs: changes
  if: needs.changes.outputs.code == 'true'
  # WINDOWS_RUNNER は private リポジトリでのみ設定する。fork の PR は常に hosted
  runs-on: ${{ vars.WINDOWS_RUNNER && !github.event.pull_request.head.repo.fork && vars.WINDOWS_RUNNER || 'windows-latest' }}
  timeout-minutes: 10
  permissions:
    contents: read
  steps:
    - uses: actions/checkout@v7
    - uses: actions/setup-dotnet@v6
      with:
        global-json-file: global.json
    - run: dotnet format <Name>.slnx --verify-no-changes
    - run: dotnet build <Name>.slnx -c Release --no-incremental

build:
  name: Build
  needs: [changes, security, lint]
  if: needs.changes.outputs.code == 'true'
  runs-on: ${{ vars.WINDOWS_RUNNER && !github.event.pull_request.head.repo.fork && vars.WINDOWS_RUNNER || 'windows-latest' }}
  timeout-minutes: 30
  permissions:
    contents: read
  steps:
    - uses: actions/checkout@v7
    - uses: actions/setup-dotnet@v6
      with:
        global-json-file: global.json
    - run: dotnet test --solution <Name>.slnx -c Release
    - run: dotnet publish src/<Name>.App -c Release -o publish
    # self-hosted の Windows runner では ICE 検証が動かないため、そのときだけ省く
    - run: dotnet build installer/<Name>.Installer.wixproj -c Release -p:PublishDir=${{ github.workspace }}\publish ${{ vars.WINDOWS_RUNNER && '-p:SuppressValidation=true' || '' }}
```

`gate` の `needs` は `[changes, security, lint, build]` にし、結果の検証ループも `lint` と
`build` だけにする（`gate` の `name` はワークフロー自身の `name` と同じにする）。
