# dotfiles

個人Mac / 職場Mac で同じ開発環境を再現するための設定管理リポジトリ。
**GNU Stow** でシンボリックリンクを張り、`git clone` + `make` で環境を即再現する。

## 1. 管理方針

- **共通設定は Git 管理**、**マシン固有・秘密情報は `.local` ファイルで分離**（各Macで手動配置）。
- リンク管理は **GNU Stow**（1ツール = 1パッケージ）。`make link` で安全に張る。
- **秘密情報は絶対にコミットしない**（`.gitignore` + gitleaks pre-commit フック + CI(GitHub Actions) の三重ガード）。
- アプリ/ツールは **Brewfile**（共通）と **Brewfile.personal**（個人）で管理。

## 2. 前提（最初の1回だけ手動）

```bash
# Homebrew（これだけは brew で入れられないので手動）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 3. 新Macセットアップ

```bash
git clone git@github.com:shiramizu-junya/dotfiles.git ~/dotfiles
cd ~/dotfiles

make dry-run          # まず何が起きるか確認（変更しない）
make bootstrap        # brew → link → runtime → plugins を一括実行

# 残りの手動ステップ（bootstrap 完了後に表示される）
cp zsh/.zshenv.example         ~/.zshenv            # 各種トークンを記入
cp zsh/.zshrc.local.example    ~/.zshrc.local       # 任意（プロキシ等）
cp git/.gitconfig.local.example ~/.gitconfig.local  # 氏名・メールを記入

make mcp               # Claude Code の MCPサーバを登録（要 ~/.zshenv）
brew autoupdate start --upgrade   # brew の自動更新を有効化（domt4/autoupdate tap）

# 個人Macのみ
make brew-personal

# iTerm2 の設定フォルダを ~/dotfiles/iterm2 に向ける（iterm2/README.md 参照）
```

## 4. 管理対象一覧

### パッケージ（stow でリンク）
| パッケージ | 内容 |
|---|---|
| zsh | `.zshrc` `.zprofile`（`.zshenv` は秘密のため除外） |
| git | `.gitconfig` `.config/git/ignore`（グローバル無視はXDGの `~/.config/git/ignore` に一本化。氏名/メールは `.local` に分離） |
| tmux | `.tmux.conf` |
| vim | `.vimrc` |
| starship | `.config/starship.toml` |
| gh | `.config/gh/config.yml`（`hosts.yml` は除外） |
| ripgrep | `.ripgreprc` |
| asdf | `.tool-versions` `.asdfrc` |
| zed | `.config/zed/settings.json` `keymap.json` |

### stow 対象外（個別管理）
- **iterm2**: iTerm2 純正のフォルダ同期で管理（`iterm2/README.md`）
- **claude**: Claude Code の MCP サーバ定義（`claude/README.md`）。秘密は `.zshenv` の環境変数を参照
- **hooks**: gitleaks pre-commit フック

### アプリ/ツール
- `Brewfile`（共通・全Mac）/ `Brewfile.personal`（個人Macのみ）
- Mac App Store アプリは `mas` 経由（`Brewfile.personal` にアプリIDを記入）

## 5. 運用方法（シナリオ別）

### A. 既存の設定を変えたい
```bash
vim ~/.zshrc          # 実体は ~/dotfiles/zsh/.zshrc（stowリンク）
reload                # zsh を再起動して変更を反映（= exec zsh のエイリアス）
cd ~/dotfiles && git add -A && git commit -m "feat: ..." && git push
```

### B. 新しいツール/アプリを brew で入れた → 管理に追加
```bash
brew install <tool>                       # または brew install --cask <app>
# 共通なら Brewfile、個人なら Brewfile.personal に1行追記
cd ~/dotfiles && git add -A && git commit -m "build: add <tool>" && git push
```

### C. 新しい設定ファイルを管理対象に追加
```bash
mkdir -p ~/dotfiles/<tool>
mv ~/.<tool>rc ~/dotfiles/<tool>/.<tool>rc   # リポジトリへ移動
cd ~/dotfiles && make link                   # 自動でリンク（パッケージ自動検出）
git add -A && git commit -m "feat: manage <tool>" && git push
```

### D. 別のMacへ反映（同期）
```bash
cd ~/dotfiles && git pull
make link                                    # 設定の同期（冪等）
make brew                                    # アプリも同期（増えていれば）
```

### E. 設定を変えたとき
→ A と同じ（編集して commit するだけ）。

### F. ツール/アプリを使わなくなった → 消す
```bash
# brewツール
brew uninstall <tool>                        # Brewfile からも該当行を削除
# 管理していた設定ごと
cd ~/dotfiles && stow -D <pkg> && rm -rf <pkg>
git add -A && git commit -m "chore: drop <pkg>" && git push
```

### G. ツールを別物に置き換え
→ F（旧を消す）+ B/C（新を足す）の組み合わせ。

### 削除を他Macにも安全に反映
```bash
git pull
make prune          # リンク切れ(幽霊リンク)を掃除
make brew-cleanup   # （任意・破壊的）Brewfileに無いアプリを削除
```

## 6. Makefile コマンド一覧

`make help` で表示。主なもの:

| コマンド | 説明 |
|---|---|
| `make bootstrap` | 新Mac一括（brew→link→runtime→plugins） |
| `make dry-run` | 何が起きるか確認（変更しない） |
| `make doctor` | 健全性チェック（ツール有無・リンク切れ・Brewfile差分） |
| `make link` | backup→stowリンク→gitleaksフック設置 |
| `make brew` / `make brew-personal` | Brewfile / Brewfile.personal を導入 |
| `make runtime` | asdf install |
| `make plugins` | vim-plug / TPM プラグイン取得 |
| `make uninstall` | stowリンクを全削除 |
| `make restore` | 最新backupから復元 |
| `make prune` | リンク切れを掃除 |
| `make brew-cleanup` | Brewfileに無いものを削除（破壊的・確認あり） |

## 7. 環境差分の扱い（.local 方式）

共通設定は Git 管理し、マシン固有の値は `.local` ファイルに分離する（Git管理しない）。

| ファイル | 用途 |
|---|---|
| `~/.gitconfig.local` | git の氏名・メール（職場では会社メール） |
| `~/.zshrc.local` | 社内プロキシ・職場専用 PATH/エイリアス等 |
| `~/.zshenv` | 各種 API トークン（秘密） |

各 `.example` をコピーして作成する。

> 💡 GUI エディタは既定で **Zed**（`ghcr` / `fghqv` 等が使用）。VS Code を使いたいMacでは `~/.zshrc.local` に `export GUI_EDITOR=code` を書けば切り替わる。

## 8. トラブルシュート

```bash
make doctor      # 何が足りないか・リンク切れ・Brewfile差分を診断
make dry-run     # 変更せずに stow の挙動を確認
make uninstall   # リンクを全部外す
make restore     # backup（~/.dotfiles-backup/<日時>/）から実ファイルを戻す
make prune       # リンク切れ(幽霊リンク)を掃除
```

> backup は `make link` のたびに `~/.dotfiles-backup/<日時>/` に自動退避される。

> **tap信頼**: Homebrew 6+ は非公式tap(`supabase/tap` `domt4/autoupdate`)に信頼登録(`brew trust`)が必須。
> `make brew` が自動で行うが、手動で `brew bundle` する場合は先に
> `brew trust --tap supabase/tap domt4/autoupdate` を実行する。

## 9. 品質チェック / その他

- **CI**（`.github/workflows/ci.yml`）: push / PR ごとに次を自動実行し、壊れたコミットを早期検知する。
  - `shellcheck`（`hooks/pre-commit` `claude/mcp-setup.sh` の静的解析）
  - `gitleaks`（履歴含む秘密スキャン）
  - `stow -n`（リンク衝突のドライラン）
- **`.editorconfig`**: エディタ間でインデント・改行を統一（2スペース既定、`Makefile`/`.gitconfig` は tab、`*.md` は行末保持）。
- **`LICENSE`**: MIT。
