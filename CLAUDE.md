# dotfiles 運用ルール（Claude Code / エージェント向け）

このリポジトリは macOS の dotfiles を **GNU Stow** で管理する。
作業する際は以下を厳守すること。

## 絶対厳守（事故防止）

- セットアップ・リンク操作は **必ず `make` 経由**で行う。生の `stow` を直接実行しない。
- **`stow --adopt` は絶対に実行しない**（リポジトリ側のファイルがマシン上の内容で上書きされる事故になる）。
- ホームを変更する操作（`make link` / `make install` / `make bootstrap` / `make restore` / `make prune` / `make brew-cleanup`）の前に、**必ず `make dry-run` または `make doctor` を実行し、出力をユーザーに見せて承認を得る**。
- **秘密・個人情報を生成・コミットしない**:
  - `*.local`（`~/.gitconfig.local` 等）、`~/.zshenv`、`hosts.yml`、各種トークン/鍵。
  - これらは `.gitignore` 済み。新規に秘密を含むファイルを作らない。
- コミット時は **gitleaks pre-commit フック**が自動で秘密スキャンする。検出されたら commit せず、ユーザーに報告する。`--no-verify` でフックを回避しない。
- `make brew-cleanup` は破壊的（アプリ削除）。確認プロンプトを勝手に `y` で通さない。

## 安全な入口（コマンド）

| 目的 | コマンド |
|---|---|
| 新Mac一括 | `make bootstrap` |
| リンクのみ | `make link`（内部で backup → stow --no-folding → フック設置） |
| 確認のみ（変更しない） | `make dry-run` / `make doctor` |
| 復旧 | `make uninstall`（リンク削除）/ `make restore`（backupから復元）/ `make prune`（幽霊リンク掃除） |

## 構成

- パッケージ（stow対象）= `ROOT` 直下のディレクトリを自動検出（`EXCLUDE = iterm2 hooks` を除く）。
  - 新しい設定を管理するには、パッケージ用フォルダを作ってファイルを置き `make link` するだけ。
- **iterm2**: stow 対象外。iTerm2 純正のフォルダ同期で管理（`iterm2/README.md`）。
- アプリ/ツール: `Brewfile`（共通）/ `Brewfile.personal`（個人Macのみ）。
- 環境差分: `.local` 方式（`~/.gitconfig.local` `~/.zshrc.local` `~/.zshenv`）。

## コミット規約

Conventional Commits（`feat:` `fix:` `build:` `chore:` `docs:` `refactor:` 等）。
