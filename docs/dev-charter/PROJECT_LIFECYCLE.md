# Project Lifecycle

小さく始め、段階的に進化させる。

## Team Structure

- 規模: 個人 〜 3人程度
- 特徴: アジャイルで迅速な意思決定を重視

## Git Workflow

- **ホスティング**：GitHub（`github.com`）、デフォルトブランチは `main`
- **コミット粒度**：機能単位・動作確認OK後
- **コミットメッセージ**：Conventional Commits形式（feat/fix/refactor/docs）
- **WIP禁止**：動作しないコードはコミットしない
- **main の安定性**：`main` は常にビルド可能・install可能な状態を保つ。直接pushは禁止し、変更は完成した状態のPRのみでマージする
- **作業の隔離**：プロジェクト固有の理由で `main` への直接pushを許可する場合でも、作業自体は短命な作業ブランチで行う。直接pushの許可は「PRを経由せずローカルで `main` へmerge&pushしてよい」という統合方法の簡略化であり、作業を `main` から隔離すること自体は省略しない
- **PRのタイミング**：実装が未完成の間はPRを作成しない（Draftとして新規に作成することも禁止）。ローカルまたは作業ブランチで完結させてからPRを出す
  - 例外：一度Ready状態で作成したPRに、後からバグや仕様との乖離が見つかった場合は、そのPRをDraftへ戻して開発を継続してよい（新規PRを作り直す必要はない）。Draft中はCIをスキップする（[topics/CI_POLICY.md](topics/CI_POLICY.md) の Draft PRs 参照）

## Branch Strategy

- **通常の変更**：短命な作業ブランチ（例：`work/`・`feat/`）を `main` から切り、完成後に `main` へ直接PRする
- **複数ステップ、または sub-issue を持つ大規模な改修**：`epic/<name>` ブランチを `main` から作成する
  - 作成したら親 issue にコメントで報告する（epic ブランチの存在と進捗の追跡先を明示する。この時点でPRは不要）
  - `epic/<name>` への小さな変更は、通常のPRと同じ品質基準（CI green必須）でPRしてmergeしてよい
  - `epic/<name>` にも `main` と同様のRuleset（PR必須・force push禁止・削除制限・必須ステータスチェック）を適用する（[topics/CI_POLICY.md](topics/CI_POLICY.md) の Epic Branch Ruleset 参照）
  - 改修が完了したら `epic/<name>` から `main` へPRを出してマージし、`epic/<name>` は削除する
