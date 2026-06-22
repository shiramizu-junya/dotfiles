# ============================================================
# Brewfile（共通）— 全Macに導入。 `make brew` で一括インストール
# ============================================================

# --- tap ---
tap "supabase/tap"               # Supabase CLI 用
tap "domt4/autoupdate"           # brew 自動更新（formula無し。`brew autoupdate start` で有効化）

# --- CLI ---
brew "asdf"                      # 言語バージョン管理（node等）
brew "supabase/tap/supabase"     # Supabase CLI
brew "git"
brew "gh"                        # GitHub CLI
brew "ghq"                       # リポジトリ管理
brew "fzf"                       # あいまい検索
brew "ripgrep"                   # 高速grep
brew "fd"                        # 高速find
brew "bat"                       # cat の強化版
brew "eza"                       # ls の強化版
brew "zoxide"                    # 学習する cd（z <部分名> でジャンプ）
brew "direnv"                    # ディレクトリ毎の環境変数を .envrc で自動ロード
brew "jq"                        # JSON操作
brew "tree"
brew "tldr"                      # 簡易man
brew "git-delta"                 # git diff の見やすい表示
brew "lazygit"                   # git の TUI（対話的ステージ/rebase/cherry-pick）
brew "neovim"
brew "tmux"
brew "starship"                  # プロンプト
brew "zsh-autosuggestions"
brew "zsh-completions"
brew "zsh-syntax-highlighting"
brew "act"                       # GitHub Actions ローカル実行
brew "git-town"                  # gitブランチ運用補助
brew "mysql"                     # ローカルDB
brew "uv"                        # Python パッケージ/バージョン管理
brew "stow"                      # dotfiles シンボリックリンク管理
brew "gitleaks"                  # 秘密検出（pre-commitで使用）

# --- GUI（cask）---
cask "iterm2"
cask "zed"
cask "docker"
cask "dbeaver-community"
cask "postman"
cask "chatgpt"
cask "claude"
cask "slack"
cask "figma"
cask "drawio"
cask "deepl"
cask "raycast"
cask "appcleaner"
cask "imageoptim"
cask "flow"                      # ポモドーロタイマー

# --- フォント（starshipのアイコン表示に必要）---
cask "font-hack-nerd-font"
cask "font-jetbrains-mono-nerd-font"
