# Monetization Policy

## Basic Policy

作成するツールは自分の必要性に基づいて決定しており、マーケティング主導ではない。
需要の有無は不明なため、**課金収益への期待は最小限にとどめる**。

独自の課金システムはメンテナンスコストとセキュリティリスクを伴うため、**原則禁止**。
既存の信頼されたプラットフォームを使用すること。

## Platform-Specific Policy

Open/Closed を問わず、プラットフォームに応じて以下の方式を選択する。

| プラットフォーム | 方式 |
|---|---|
| Apple App Store（Swift: macOS / iOS） | 無料試用後、月間・年間サブスクリプションまたは買い切り（「Apple App Store Policy」参照） |
| Chrome 拡張 | Buy Me a Coffee |
| Alfred workflow | Buy Me a Coffee |
| Web app / site | Buy Me a Coffee ＋ 可能なら広告 |
| Python library / app | Buy Me a Coffee |

## Apple App Store Policy

Swift で開発し、Apple App Store で配布する macOS・iOS アプリには以下を基本方針として適用する。

### Free Trial

- 無料試用期間は初回利用日時から 1 か月とする
- 試用期間中はすべての機能を利用可能にし、機能制限を設けない
- 試用期間終了後は、月間サブスクリプション・年間サブスクリプション・買い切りのいずれかを購入しなければ継続利用できない

### Pricing

月間サブスクリプションの価格を基準価格とする。

| 購入方式 | 価格 |
|---|---|
| 月間サブスクリプション | 基準価格（月額） |
| 年間サブスクリプション | 基準価格の 10 か月分 |
| 買い切り | 基準価格の 12 か月分 |

### Cross-Platform Purchase

- macOS 版と iOS 版は同一購入に含める
- いずれか一方で購入した利用者は、もう一方でも購入を復元して同じ権利を利用できるようにする
- 月間・年間サブスクリプションと買い切りのすべてで、macOS・iOS 間の購入権利を共有する

## GitHub Published Projects

GitHub 上で公開するプロジェクトは、Open/Closed にかかわらず、プラットフォーム別の方式に加えて **GitHub Sponsors** を追加する。

### .github/FUNDING.yml

GitHub Sponsors を有効化するために `.github/FUNDING.yml` を作成する。

```yaml
github: [USERNAME]
buy_me_a_coffee: [USERNAME]
```

`[USERNAME]` はプロジェクト作成時に GitHub ユーザー名（および Buy Me a Coffee のユーザー名）に置き換えること。`github` フィールドに設定することでリポジトリページに「Sponsor」ボタンが表示される。

## Buy Me a Coffee Implementation

### Wording

```
役に立ったらサポートしてもらえると嬉しいです[コーヒーの絵文字]
```

`[コーヒーの絵文字]` はプロジェクトの性質に応じた非ユニコード絵文字（SF Symbols / Material Symbols等）に置き換えること。

### Button (Standard)

サイズはデフォルト値を維持し、特別な事情がない限り変更しない。

```html
<a href="https://www.buymeacoffee.com/y.marui" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png"
       alt="Buy Me A Coffee"
       style="height: 60px !important;width: 217px !important;">
</a>
```

### Widget (Optional)

ページに常駐させる場合に使用可。

```html
<script data-name="BMC-Widget" data-cfasync="false"
  src="https://cdnjs.buymeacoffee.com/1.0.0/widget.prod.min.js"
  data-id="y.marui"
  data-description="Support me on Buy me a coffee!"
  data-message=""
  data-color="#FF813F"
  data-position="Right"
  data-x_margin="18"
  data-y_margin="18"></script>
```

## Monetization Plan Record

市場調査等に基づいてマネタイズを本格的に検討する場合は、以下のルールに従う。

1. **各プロジェクトのリポジトリに `MONETIZATION.md` を作成する**
   - 対象プラットフォーム・収益モデル・価格設定・実施時期などを記載する

2. **`AI_CONTEXT.md` にその概要を記載する**
   - AI がセッションをまたいでマネタイズ方針を把握できるようにする
   - 詳細は `MONETIZATION.md` を参照する旨を記載するにとどめる
