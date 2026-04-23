# Language Policy

## Basic Principles

本プロジェクト群では、日本語を **canonical (正本)** とし、英語版は **reference (参照)** とする。
このことは、タイトルを除くドキュメントの最初で宣言してから内容に移ること。

**セクションヘッダ**：日本語ドキュメントでも英語で記載する。

### README Rules
- `README.md` は英語（国際的な参照用）
- `README-jp.md` を日本語版（正本）として作成

### Language by Project
1. **開発憲章:** 日本語を使用する。
2. **OSSプロジェクト:** 公開面は英語、開発内部は日本語OK。

   **英語必須**（外部の人が読む可能性があるもの）
   - README・コントリビュートガイド・CHANGELOG
   - 公開 API / CLI の説明・docstring（公開関数のみ）
   - examples/ のコメント
   - エラーメッセージ・ログ（issue 共有用）
   - コミットメッセージ・issue / PR のタイトルと本文

   **日本語OK**（開発者内部のもの）
   - 内部コメント（private 関数・実装詳細を含む）
   - 試行メモ・設計メモ

   **判断基準:** 外部の人が読む可能性があれば英語、そうでなければ日本語OK。

3. **クローズドプロジェクト:** 日本語を使用する。

## Multilingual Document Structure

### When Combining Languages in a Single File
日本語と英語の両方を一つのファイルに書く場合は、以下の順序で構成すること。
1. タイトル
2. 日本語の宣言（正本である旨）
3. 英語の宣言（参照である旨）
4. 日本語の内容
5. 英語の内容

### When Using Separate Files
日本語版を正本、英語版を参照とし、それぞれの冒頭でその旨を宣言すること。

**日本語版冒頭:**
```
> **このファイルは正本（日本語版）です。**
> 英語版（参照）は [README.md](README.md) を参照してください。
```

**英語版冒頭:**
```
> **This is the reference (English) version.**
> The canonical (Japanese) version is [README-jp.md](README-jp.md).
```

末尾には編集ルールフッターを記載する。

**日本語版末尾:**
```
---
*この文書には英語版 [README.md](README.md) があります。編集時は同一コミットで更新してください。*
```

**英語版末尾:**
```
---
*This document has a Japanese canonical version [README-jp.md](README-jp.md). Update both in the same commit when editing.*
```

## Editing Rules

日本語と英語の両方が存在する場合、**日本語を主として編集し、英語はそれに合わせて更新する**。英語版を独立して編集してはならない。

日本語版と英語版は**同一コミットで更新**する。
