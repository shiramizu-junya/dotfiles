# ============================================================
# 1. 補完システムの初期化（最優先！）
# ============================================================
# zshの補完機能（Tabキーでコマンドやファイル名を自動補完）を使うために
# 他の初期化処理より先に設定する必要がある

# Homebrew補完パスを追加
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

# 補完システム初期化（1回だけ！）
autoload -Uz compinit && compinit

# fzf-tab: Tab補完をfzf化（compinitの後・autosuggestionsの前に読むのが鉄則）
if [ -f ~/.config/zsh/fzf-tab/fzf-tab.plugin.zsh ]; then
  source ~/.config/zsh/fzf-tab/fzf-tab.plugin.zsh
  # cd補完: ディレクトリツリーをプレビュー
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=1 --icons $realpath 2>/dev/null'
  # グループ間を < > で移動
  zstyle ':fzf-tab:*' switch-group '<' '>'
fi

# ============================================================
# 2. 初期化・読み込み
# ============================================================

# SSH Agent起動（既存のエージェントがなければ起動）
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null 2>&1
fi

# macOS Keychainから鍵を読み込み
ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null

# Starshipプロンプト初期化
eval "$(starship init zsh)"

# zoxide: 訪問頻度を学習する cd。`z <部分名>` でジャンプ / `zi` で fzf 選択
if type zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# direnv: ディレクトリごとの環境変数を .envrc で自動ロード（cd した瞬間に反映）
if type direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# GitHub CLI補完（compinitの後に実行）
if type gh &>/dev/null; then
  eval "$(gh completion -s zsh)"
fi

# asdf shimsをPATHに追加（asdf 0.16+のGo版は asdf.sh を提供しないため手動で追加）
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# asdf補完（Go版）
if type asdf &>/dev/null; then
  fpath=("${ASDF_DATA_DIR:-$HOME/.asdf}/completions" $fpath)
fi

# uv/uvx補完
if type uv &>/dev/null; then
  eval "$(uv generate-shell-completion zsh)"
  eval "$(uvx --generate-shell-completion zsh)"
fi

# zsh-autosuggestions読み込み
if [ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# ============================================================
# 3. パス設定
# ============================================================

# Homebrew（基本パス）
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# ローカルバイナリ
export PATH="$HOME/.local/bin:$PATH"

# ============================================================
# 4. シェルオプション
# ============================================================

setopt no_beep              # ビープ音を無効化

# ディレクトリ移動の強化
setopt AUTO_CD              # ディレクトリ名だけでcd（cd省略可能）
setopt AUTO_PUSHD           # cd時に自動でpushd（cd -で戻れる）
setopt PUSHD_IGNORE_DUPS    # pushd履歴の重複を無視
setopt PUSHD_SILENT         # pushd/popdの出力を抑制

# 履歴設定
export HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS     # 連続する重複を無視
setopt HIST_IGNORE_ALL_DUPS # 古い重複を削除
setopt HIST_REDUCE_BLANKS   # 余分な空白を除去
setopt SHARE_HISTORY        # ターミナル間で履歴共有
setopt HIST_IGNORE_SPACE    # スペース始まりは記録しない（秘密コマンド用）

# ============================================================
# 5. 環境変数
# ============================================================

# --- 認証・トークン ---
# ~/.zshenvに移動しました

# --- ロケール ---
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# --- ツール設定 ---
export BAT_THEME="Monokai Extended"
export RIPGREP_CONFIG_PATH=~/.ripgreprc

# --- fzf（ファジーファインダー） ---
# fzfはあいまい検索ツール。ファイル・履歴・ブランチ等を絞り込み選択できる
# 以下はfzf起動時のデフォルト表示設定（Draculaテーマ配色）
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview-window=right:60%
  --bind ctrl-u:preview-page-up,ctrl-d:preview-page-down
  --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
  --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
  --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
'

# fzfのファイル検索にripgrepを使用（.gitignore対応で高速）
if type rg &>/dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# ============================================================
# 6. エイリアス
# ============================================================

# --- Git基本操作 ---
alias g='git'
alias gits='git status'           # 状態確認
alias gitb='git branch'           # ブランチ一覧
alias gitba='git branch -a'       # リモート含む全ブランチ
alias gitco='git checkout'        # ブランチ切り替え
alias gitcb='git checkout -b'     # 新規ブランチ作成＆切り替え
alias gitsw='git switch'          # ブランチ切り替え（新コマンド）
alias gitswc='git switch -c'      # 新規ブランチ作成（新コマンド）

# --- Git差分確認 ---
alias gitd='git diff'             # 差分表示
alias gitdf='git diff --color-words'  # 単語単位で差分表示
alias gitdc='git diff --cached'   # ステージング済みの差分

# --- Gitステージング・コミット ---
alias gita='git add'              # ファイルをステージング
alias gitaa='git add -A'          # 全変更をステージング
alias gitcm='git commit -m'       # メッセージ付きコミット
alias gitca='git commit --amend'  # 直前のコミットを修正

# --- Gitリモート操作 ---
alias gitm='git merge'            # マージ
alias gitps='git push'            # プッシュ
alias gitpsu='git push -u'        # 上流ブランチ設定してプッシュ
alias gitpull='git pull'          # プル
alias gitf='git fetch'            # フェッチ

# --- Gitログ確認 ---
alias gitl='git log'              # ログ表示
alias gitll='git log --oneline'   # 1行表示
alias gitlg='git log -p'          # 差分付きログ
alias gitgraph='git log --graph --date-order -C -M --all --date=iso --color'
alias gitgr='git log --graph --date=short --decorate=short --pretty=format:"%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s"'

# --- Gitスタッシュ ---
alias gitsl='git stash list'      # スタッシュ一覧
alias gitsp='git stash pop'       # スタッシュを適用して削除
alias gitss='git stash save'      # スタッシュに保存

# --- Gitファイル操作 ---
alias gitls='git ls-files'        # 追跡中ファイル一覧
alias gitlso='git ls-files -o'    # 未追跡ファイル一覧

# --- Gitブランチクリーンアップ ---
alias gitfc-preview='git fetch -p && git branch -vv --no-color | awk "/: gone]/{print \$1}"'  # 削除対象確認
alias gitfc='git fetch -p && git branch -vv --no-color | awk "/: gone]/{print \$1}" | xargs -r git branch -D'  # リモートで削除済みのブランチを削除

# --- ファイル操作（eza: モダンなls代替。アイコン付きでGit状態も表示） ---
alias ls='eza --icons'            # アイコン付き一覧
alias ll='eza -la --icons --git'  # 詳細表示（Git状態付き）
alias l='eza -l --icons'          # 詳細表示
alias la='eza -la --icons'        # 隠しファイル含む詳細表示
alias lt='eza --tree --level=2 --icons'  # ツリー表示（2階層）

# --- ファイル表示（bat: シンタックスハイライト付きcat代替） ---
alias cat='bat'

# --- 基本コマンド ---
alias rm='rm -i'                  # 削除前に確認
alias c='clear'                   # 画面クリア
alias e='exit'                    # シェル終了
alias grep='grep --color=auto'    # マッチ部分を色付け
alias help='tldr'                 # 簡易マニュアル表示

# --- fzf短縮エイリアス ---
alias fhist='fh'                  # 履歴検索
alias fdir='fcd'                  # ディレクトリ移動
alias fbranch='fbr'               # Gitブランチ切り替え
alias fvim='fv'                   # ファイルをvimで開く
alias frepo='fghq'                # ghqリポジトリ移動

# --- Claude Code ---
alias ccmcp="claude --mcp-config=.mcp.json"  # カレントディレクトリの.mcp.jsonを使ってClaude Codeを起動

# ============================================================
# 7. カスタム関数
# ============================================================

# ------------------------------------------------------------
# mkcd: ディレクトリ作成して移動
# 使い方: mkcd new-directory
# ------------------------------------------------------------
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# ------------------------------------------------------------
# ghcr: GitHubリポジトリ作成 → ghqでclone → VSCodeで開く
# ------------------------------------------------------------
# 使い方:
#   ghcr <repo-name> [--public|--private|--internal] [-o <owner>]
# 例:
#   ghcr my-super-program --public
#   ghcr my-private-program
# ------------------------------------------------------------
ghcr() {
  local name="" owner="" vis="--private" arg

  while [[ $# -gt 0 ]]; do
    arg="$1"
    case "$arg" in
      --public|--private|--internal) vis="$arg"; shift ;;
      -o|--owner) owner="$2"; shift 2 ;;
      -*)
        echo "Unknown option: $arg" >&2
        return 1 ;;
      *)
        if [[ -z "$name" ]]; then
          name="$arg"
          shift
        else
          echo "Usage: ghcr <repo-name> [--public|--private|--internal] [-o <owner>]" >&2
          return 1
        fi ;;
    esac
  done

  if [[ -z "$name" ]]; then
    echo "Usage: ghcr <repo-name> [--public|--private|--internal] [-o <owner>]" >&2
    return 1
  fi

  command -v gh >/dev/null || { echo "Error: gh not found"; return 1; }
  gh config set git_protocol ssh >/dev/null 2>&1

  if [[ -z "$owner" ]]; then
    owner="$(gh api user -q .login 2>/dev/null)"
    [[ -z "$owner" ]] && { echo "Error: failed to resolve login owner"; return 1; }
  fi
  local full="$owner/$name"

  if ! gh repo create "$full" "$vis" -y; then
    echo "Error: gh repo create failed for $full" >&2
    return 1
  fi

  local base="${GHQ_ROOT:-$HOME/workspace}"
  local precloned="$base/github.com/$owner/$name"
  if [[ -d "$precloned/.git" ]]; then
    cd "$precloned"
    command -v code >/dev/null 2>&1 && code "$precloned" || echo "Cloned at: $precloned"
    return 0
  fi

  local ssh_url
  ssh_url="$(gh repo view "$full" --json sshUrl -q .sshUrl 2>/dev/null)"
  [[ -z "$ssh_url" ]] && { echo "Error: could not get sshUrl for $full" >&2; return 1; }

  local clone_path=""
  if command -v ghq >/dev/null 2>&1; then
    if ghq get "$ssh_url"; then
      local first=""
      while IFS= read -r first; do
        clone_path="$first"
        break
      done < <(ghq list --full-path -e "$full")
    else
      echo "Error: ghq get failed for $ssh_url" >&2
      return 1
    fi
  else
    mkdir -p "$base/github.com/$owner"
    if git clone "$ssh_url" "$base/github.com/$owner/$name"; then
      clone_path="$base/github.com/$owner/$name"
    else
      echo "Error: git clone failed for $ssh_url" >&2
      return 1
    fi
  fi

  if [[ -n "$clone_path" ]]; then
    cd "$clone_path"
    command -v code >/dev/null 2>&1 && code "$clone_path" || echo "Cloned at: $clone_path"
  else
    echo "Repository path not found after clone for $full" >&2
    return 1
  fi
}

# ------------------------------------------------------------
# fzf関数群: fzf（ファジーファインダー）を使ったインタラクティブな検索・選択
# 各関数はfzfで候補を表示し、選択した項目に対してアクションを実行する
# ------------------------------------------------------------

# ------------------------------------------------------------
# fh: コマンド履歴をfzfで検索して再実行
# 使い方: fh と入力 → 過去のコマンド一覧から選択 → コマンドラインに挿入
# ?キーでプレビュー表示を切り替え可能
# エイリアス: fhist
# ------------------------------------------------------------
fh() {
  local selected
  selected=$(fc -rl 1 |
    fzf --tac --no-sort \
        --preview 'echo {}' \
        --preview-window down:3:hidden:wrap \
        --bind '?:toggle-preview' |
    sed 's/ *[0-9]* *//')
  if [ -n "$selected" ]; then
    print -z "$selected"
  fi
}

# ------------------------------------------------------------
# fcd: ディレクトリをfzfで検索して移動
# 使い方: fcd と入力 → カレント以下のディレクトリ一覧から選択 → そのディレクトリにcd
# プレビューにツリー構造を表示
# エイリアス: fdir
# ------------------------------------------------------------
fcd() {
  local selected
  selected=$(fd --type d --hidden --exclude .git |
    fzf --preview 'eza --tree --level=1 --icons {} 2> /dev/null || ls -la {}')
  if [ -n "$selected" ]; then
    cd "$selected"
  fi
}

# ------------------------------------------------------------
# fv: ファイルをfzfで検索してvimで開く
# 使い方: fv と入力 → ファイル一覧から選択 → vimでそのファイルを開く
# プレビューにファイル内容をシンタックスハイライト付きで表示
# エイリアス: fvim
# ------------------------------------------------------------
fv() {
  local selected
  selected=$(fd --type f --hidden --exclude .git |
    fzf --preview 'bat --color=always --style=numbers --line-range=:500 {} 2> /dev/null')
  if [ -n "$selected" ]; then
    vim "$selected"
  fi
}

# ------------------------------------------------------------
# fbr: Gitブランチをfzfで選択して切り替え
# 使い方: fbr と入力 → ローカル/リモートブランチ一覧から選択 → そのブランチにcheckout
# プレビューにブランチのコミット履歴を表示
# エイリアス: fbranch
# ------------------------------------------------------------
fbr() {
  local branches branch
  branches=$(git branch -a 2> /dev/null | grep -v HEAD)
  if [ -z "$branches" ]; then
    echo "Not a git repository"
    return 1
  fi
  branch=$(echo "$branches" |
    fzf --preview 'git log --oneline --graph --color=always {1} 2> /dev/null' |
    sed 's/^[* ]*//' |
    awk '{print $1}' |
    sed 's#remotes/origin/##')
  if [ -n "$branch" ]; then
    git checkout "$branch"
  fi
}

# ------------------------------------------------------------
# fghq: ghq管理下のリポジトリをfzfで選択して移動
# 使い方: fghq と入力 → ghqで管理しているリポジトリ一覧から選択 → そのディレクトリにcd
# プレビューにリポジトリのツリー構造を表示
# エイリアス: frepo
# ------------------------------------------------------------
fghq() {
  local selected
  selected=$(ghq list -p | fzf --preview 'eza --tree --level=2 --icons {} 2> /dev/null')
  if [ -n "$selected" ]; then
    cd "$selected"
  fi
}

# ------------------------------------------------------------
# fghqv: ghq管理下のリポジトリをfzfで選択してVSCodeで開く
# 使い方: fghqv と入力 → リポジトリ一覧から選択 → cdしてVSCodeで開く
# ------------------------------------------------------------
fghqv() {
  local selected
  selected=$(ghq list -p | fzf --preview 'eza --tree --level=2 --icons {} 2> /dev/null')
  if [ -n "$selected" ]; then
    cd "$selected"
    code "$selected"
  fi
}

# ------------------------------------------------------------
# fga: Git変更ファイルをfzfで選択してステージング（git add）
# 使い方: fga と入力 → 変更/未追跡ファイルの一覧から複数選択（Tab） → git add
# プレビューに差分を表示
# ------------------------------------------------------------
fga() {
  local selected
  selected=$(git ls-files -m -o --exclude-standard 2> /dev/null |
    fzf -m --preview 'git diff --color=always {} 2> /dev/null | head -200')
  if [ -n "$selected" ]; then
    echo "$selected" | xargs git add
    echo "✓ Added: $selected"
  fi
}

# ------------------------------------------------------------
# fshow: Gitコミット履歴をfzfでブラウズ
# 使い方: fshow と入力 → グラフ付きコミット一覧から選択 → そのコミットの詳細を表示
# ------------------------------------------------------------
fshow() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" 2> /dev/null |
  fzf --ansi --no-sort --reverse --tiebreak=index \
    --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs git show --color=always 2> /dev/null'
}

# ------------------------------------------------------------
# frg: ripgrepで検索してfzfで絞り込み（ファイル内テキスト検索）
# 使い方: frg 検索ワード → マッチした行の一覧から選択 → プレビューで該当箇所を表示
# 例: frg "TODO" でプロジェクト内のTODOを検索
# ------------------------------------------------------------
frg() {
  rg --color=always --line-number --no-heading --smart-case "${*:-}" |
  fzf --ansi \
      --delimiter : \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
}

# ------------------------------------------------------------
# fkill: プロセスをfzfで選択してkill（強制終了）
# 使い方: fkill と入力 → 実行中のプロセス一覧から複数選択（Tab） → kill -9で終了
# 引数でシグナルを指定可能: fkill 15（SIGTERMで優しく終了）
# ------------------------------------------------------------
fkill() {
  local pid
  pid=$(ps aux | sed 1d |
    fzf -m --preview 'echo {}' --preview-window=down:3 |
    awk '{print $2}')
  if [ -n "$pid" ]; then
    echo "Killing: $pid"
    echo $pid | xargs kill -${1:-9}
  fi
}

# ============================================================
# 8. その他の設定
# ============================================================

# .zshrc変更時の自動リロード
# .zshrcを編集して保存すると、次にEnterを押したタイミングで自動的にsourceされる
# 手動で source ~/.zshrc を実行する必要がなくなる
function reload_zshrc() {
  if [[ ~/.zshrc -nt ~/.zshrc_last_load ]]; then
    source ~/.zshrc
    touch ~/.zshrc_last_load
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd reload_zshrc

# インストールしたコマンドを即座に認識
zstyle ":completion:*:commands" rehash 1

# マシン固有設定（プロキシ・職場用PATH等。存在すれば読み込む / Git管理しない）
# 雛形: zsh/.zshrc.local.example
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# zsh-syntax-highlighting（必ずファイルの最後！）
if [ -f $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
