# Chrome Extension Development Environment

Manifest V3 で実装する Chrome（および Firefox 同時対応）拡張機能プロジェクト共通の
開発環境構成を定義する。`PYTHON_DEV_ENV.md`・`ALFRED_DEV_ENV.md` の Chrome Extension 版。

このトピックは「Manifest V3 + Node.js ツールチェーンを使う開発環境」の一般方針であり、
`manifest.json` の実際の `permissions` 一覧や機能仕様、UI コンポーネント設計といった、
プロジェクト固有の実装内容は対象外。それらは各プロジェクトが採用しているテンプレート／
親リポジトリ側の docs を正本とし、そちらを参照する（[TEMPLATE_README_GUIDELINES.md](../TEMPLATE_README_GUIDELINES.md)
「Relationship to dev-charter Dev-Env Topics」参照）。

## Version Policy

- Node.js のバージョンは **`.nvmrc`** を単一の情報源とする。CI では
  `actions/setup-node` の `node-version-file: '.nvmrc'` を使い、
  `node-version: 'NN'` のようにリテラルで pin しない
- `manifest_version` は **3 固定**（Manifest V2 は Chrome Web Store で新規提出
  できないため使用しない）
- 拡張機能自体のバージョンは `manifest.json` の `version` を単一の情報源とする。
  ストア提出に必要なのはこちらであり、`package.json` の `version` とは独立に
  管理してよい

## Toolchain

- Bundler: **esbuild**（軽量・高速。webpack/rollup 等の大規模バンドラは導入しない）
- Linter: **ESLint**（flat config, `eslint.config.js`）。`globals.browser` +
  `globals.webextensions` を有効にする。専用の Formatter は導入せず、ESLint の
  ルールで整形も兼ねる（プロジェクトが大きくなり必要性が確認されてから
  Prettier 等の追加を検討する）
- Test runner: **Node.js 組み込みの `node --test`**（Jest/Vitest 等の外部テスト
  ランナーは導入しない — 依存を増やさずに済むため）
- 上記はいずれも `package.json` の `devDependencies` に固定バージョンで含める

## Dual Build (Chrome / Firefox)

- 単一の `src/` を esbuild で1回だけバンドルし、`manifest.json` の `background`
  指定のみをターゲットごとに出し分ける（Chrome: `service_worker`、Firefox:
  `scripts` 配列 + `browser_specific_settings.gecko`）
- ビルド出力は `stage/<target>/`（Load Unpacked 検証用の展開済みディレクトリ）と
  `dist/<name>-<version>-<target>.zip`（ストア提出用 ZIP）に分離する。両方同時に
  ビルドして `stage/chrome/`・`stage/firefox/` を並行して Load Unpacked できるように
  しておく
- Firefox 非対応のプロジェクトでは `build:firefox` を省略し、Chrome 単体構成を
  選択してよい
- ローカルでの動作確認は必ずビルド後の `stage/<target>/` を Load Unpacked する。
  `src/` はバンドル前の ES Module のままであることが多く、`manifest.json` は
  バンドル済み plain script を前提にしているため、プロジェクトルート自体を
  直接 Load Unpacked することはできない

## Architecture (Centralized Chrome API Access)

- `chrome.*` API の呼び出しは `shared/storage.js`・`shared/messaging.js` 等、
  ラッパー専用のモジュールに一点集約する。background／popup／content の各
  エントリーポイントはこれらのモジュール越しにのみアクセスする
- background（`service-worker.js`）は `chrome.runtime.onInstalled` 等の
  ライフサイクルイベント登録に限定し、ビジネスロジックを持たない
- popup・content script から Chrome API を直接呼び出さない（Chrome 非依存の
  単体テストを可能にし、将来 Firefox（`browser.*`）等へ移植する際の変更箇所を
  ラッパー層に閉じ込めるため）

## Store Submission Assets

- ストア掲載素材（説明文・パーミッション説明・スクリーンショット等）は
  `docs/store/<platform>/<locale>/` に配置する
- Chrome Web Store の文字数制限（詳細説明 16,000 文字等）はビルド前に検証
  スクリプト（`npm run validate:store` 等）で機械チェックする
- `permissions`/`host_permissions` を追加する前に、審査で求められる説明を
  想定して必要性を確認する

## Testing

- `test/unit/*.test.js` に `node --test` 形式のユニットテストを置く
- Chrome API に依存するロジックは `shared/*.js` のラッパー経由に閉じ込め、
  グローバル `chrome` オブジェクトのスタブでテストする
- 実ブラウザでの E2E テスト（Puppeteer/Playwright 等）は必須としない。小規模な
  拡張機能では導入コストに見合わないため、手動の Load Unpacked 確認で代替してよい

```bash
node --test test/unit/*.test.js
```

## CI Integration

`CI_POLICY.md` の job 構成に従う。`changes` job（`dorny/paths-filter`）で
`docs/**`・`*.md` 等を除外し、ドキュメントのみの変更では `lint`/`test`/`build`
を skip する。

```yaml
lint:
  name: Lint
  needs: changes
  if: needs.changes.outputs.code == 'true'
  steps:
    - uses: actions/checkout@v7
    - uses: actions/setup-node@v7
      with:
        node-version-file: '.nvmrc'
    - run: npm install --ignore-scripts
    - run: npm run lint

test:
  name: Test
  needs: changes
  if: needs.changes.outputs.code == 'true'
  steps:
    - uses: actions/checkout@v7
    - uses: actions/setup-node@v7
      with:
        node-version-file: '.nvmrc'
    - run: npm install --ignore-scripts
    - run: npm test

build:
  name: Build
  needs: [changes, security, lint, test]
  if: needs.changes.outputs.code == 'true'
  steps:
    - uses: actions/checkout@v7
    - uses: actions/setup-node@v7
      with:
        node-version-file: '.nvmrc'
    - run: npm install --ignore-scripts
    - run: npm run build:chrome
    - run: npm run build:firefox  # Firefox 非対応プロジェクトでは省略
    - uses: actions/upload-artifact@v7
      with:
        name: <project-name>-${{ github.sha }}
        path: dist/*.zip
```

## Release Process

- `v*` タグの push で CI の build job とは別の `release.yml` をトリガーする。
  タグが `manifest.json`/`package.json` の `version` と一致するか検証してから
  `npm run build` を実行し、SHA-256 チェックサムを添えて GitHub Release を
  作成する。リリースノートは GitHub の自動生成（`--generate-notes`）でよい
- build provenance の attestation は必須ではないオプション拡張とする
- **ローカルフォールバック**: Actions が実行できない場合（billing・spending
  limit の問題等）に備え、同じビルド・チェックサム・GitHub Release 作成の
  手順を `scripts/release.sh`（`make release` で呼び出す）としてローカルからも
  実行できるようにする。タグの push・Release 作成それぞれの実行前にユーザーへ
  確認する

## Dependency Policy

- 実行時（`src/` にバンドルされる）依存は既定でゼロとする。バニラ JS と
  Chrome/Web 標準 API のみで実装し、React 等の UI フレームワークは導入しない
- `devDependencies` は esbuild・ESLint とその関連プラグインに限定する。
  ビルド・Lint に直接寄与しないユーティリティは追加前に必要性を検討する
