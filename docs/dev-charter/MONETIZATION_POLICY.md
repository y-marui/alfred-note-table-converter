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
| Mac app / iOS app | Sublime Text 方式（時々購入を促すポップアップを表示し、正式購入で解除） |
| Chrome 拡張 | Buy Me a Coffee |
| Alfred workflow | 要検討 |
| Web app / site | Buy Me a Coffee ＋ 可能なら広告 |
| Python library / app | 要検討 |

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
