# Software Design Principles

ソフトウェア・製品を設計するときに適用する原則。プロジェクト種別を問わない
変更の原則は [PRINCIPLES.md](../PRINCIPLES.md) を参照。

## Development Philosophy
- まず小さなツールを構築する
- ローカルファーストのデザインを優先する
- インフラストラクチャを最小限に保つ

## Design
- 高速なインタラクション
- 最小限のUI

## Architecture
- 最小限の依存関係
- オフライン機能を優先

## CLI Usability

言語・フレームワークによらず、CLIコマンドを実装する場合の最低限のユーザビリティ方針。実装の詳細は言語別のtopicsファイル（Pythonは[PYTHON_CLI.md](python/PYTHON_CLI.md)）を参照。

- **MUST**：`--help` を実装する
- **MUST**：`--version` を実装する
- **SHOULD**：短縮形 `-h`（help）を提供する
- **SHOULD**：version の短縮形は `-V`（大文字）を標準とする。`-v` は verbose 等と衝突しやすいため避ける。フレームワーク・既存慣習と明確に衝突する場合のみ例外とする
- **SHOULD**：少なくとも zsh 向けの shell completion を提供する。bash/fish 等もフレームワーク側で容易に提供できる場合は併せて検討する
