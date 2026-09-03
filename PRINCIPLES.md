# Principles

プロジェクト種別（ソフトウェア・ドキュメント・研究ノート等）を問わず、変更を
加えるときに共通して適用する原則。ソフトウェア・製品設計に固有の原則は
`full` 版の
[topics/SOFTWARE_DESIGN_PRINCIPLES.md](https://github.com/y-marui/dev-charter/blob/full/topics/SOFTWARE_DESIGN_PRINCIPLES.md)
を参照。

## Change Design Principles

- **変更範囲は必要最小限**（Over-engineeringしない）
- **YAGNI原則**：今必要ないものは作らない
- **重複の判断**：2回の重複では抽象化・共通化しない、3回目で検討
- **既存の成果物の再利用**：新規作成前に類似のものがないか確認
- **TODO/懸案を残さない**：その場で対応するか、issueとして記録する
- **既存のパターンに従う**（命名規則・構成・ディレクトリ構造）
