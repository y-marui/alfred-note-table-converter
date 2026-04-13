# UI Guidelines

## Appearance Mode

- ライト、ダーク、およびシステムの各モードに対応し、ユーザーが設定から選択できるようにしてください。

### Color Palette

#### Light Mode
- **背景:** 白 (#FFFFFF)
- **文字:** #4e454a
- **強調（テキスト）:** 黒 (#000000)

#### Dark Mode
- **背景:** 黒 (#000000)
- **文字:** #bab1b6
- **強調（テキスト）:** 白 (#FFFFFF)

### Design Principles
- **アクセントカラーと装飾:** 特別な意味がある場合を除き、ライトモードとダークモードで**色相と彩度を維持しつつ、明度を反転**させるものとします。
- システムカラーを優先
- ネイティブUIコンポーネントを優先

## Iconography & Symbols (No Unicode Emoji)

UIパーツ（ボタン、ラベル、装飾等）において、Unicodeの絵文字を使用することを原則禁止します。商用利用におけるライセンスの透明性と、各プラットフォームにおける最高のユーザー体験（アクセシビリティ・保守性）を優先してください。

- **For iOS / macOS (Swift/SwiftUI):**
  - **SF Symbols を絶対優先とする**（`Image(systemName: "...")`）。
  - ブランドロゴ等も可能な限り SF Symbols 内のものを探して使用する。

- **For Web / Chrome Extensions:**
  - **Google Material Symbols**: 標準UIアイコンの第一選択。
  - **Font Awesome (Brands)**: GitHub、X、Google などのブランドロゴが必要な場合に使用。
  - **Lucide Icons**: よりモダンでクリーンなデザインが必要な場合の選択肢（MIT License）。
  - **SVG**: 上記に存在しない固有のロゴやアセットが必要な場合のみ、コードに直接埋め込むかアセットとして管理する。
