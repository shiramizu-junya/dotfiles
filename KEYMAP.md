# KEYMAP — vim と Zed の対応表 / Neovim のキー / tmux のキー

`~/.vimrc`（ターミナルの vim）と `zed/.config/zed/keymap.json`（Zed の vim モード）の対応。
**片方を変えたら、この表を見てもう片方も直す。**
Neovim だけのキー（LSP・補完・検索など）とテクニックは [5. Neovim のキーとテクニック](#5-neovim-のキーとテクニック)、
tmux のキーは [6. tmux のキー](#6-tmux-のキー)。

## なぜ2つ必要なのか

**Zed は `.vimrc` を読まない。** Zed の vim モードは Vim を組み込んだものではなく、
Zed による再実装なので、`inoremap` / `set` / プラグインという vimrc の語彙を解釈する仕組みが無い。
`load_vimrc` のような設定も存在しない（Zed 1.20.2 時点）。

同期の自動化も見送った。vimrc の中身は3層に分かれ、機械変換できるのは1層だけのため。

| 層 | 例 | 自動変換 |
|---|---|---|
| キー → キー | `nnoremap <Leader>j 10j` | ⭕ `workspace::SendKeystrokes` で機械的に書ける |
| キー → コマンド | `nnoremap <Leader>e :NERDTreeToggle<CR>` | ❌ プラグイン名 → Zed アクション名の辞書が要る |
| `set` / プラグイン設定 | `set relativenumber` | △ Zed の settings.json に等価物がある分だけ |

機械変換できるのは十数本、そのうち半分は「矢印キー無効化」という一度書いたら触らない設定。
生成スクリプトを保守するコストのほうが高いので、**この表を正とする手動運用**にしている。

## 1. キーマップ

`.vimrc` の列は Vim / Neovim 共通の `~/dotfiles/vim/.vim/common.vim`（Vim 専用は `~/dotfiles/vim/.vimrc`）、Zed は `~/dotfiles/zed/.config/zed/keymap.json`。

### モード遷移・移動

| 操作 | `.vimrc` | Zed keymap.json |
|---|---|---|
| `jj` でインサートを抜ける | `inoremap <silent> jj <ESC>` | `"j j": "vim::NormalBefore"` |
| 10行下/上へ | `nnoremap <Leader>j 10j` / `<Leader>k 10k` | `"space j"` / `"space k"`: `SendKeystrokes "1 0 j"` / `"1 0 k"` |
| ドキュメント表示 | `K` → `:ALEHover`（Vim）/ LSP 標準の hover（Neovim） | `K`（Zed 既定の `editor::Hover`） |
| 半ページ送り＋中央寄せ | `nnoremap <C-d> <C-d>zz` / `<C-u> <C-u>zz` | `"ctrl-d"` / `"ctrl-u"`: `SendKeystrokes "ctrl-d z z"` / `"ctrl-u z z"` |
| 矢印キー無効化 | `noremap <up> <nop>` ほか8本 | `"up"` / `"down"` / `"left"` / `"right"`: `null` |

### リーダーキー（`<Space>`）

vim 側はプラグイン、Zed 側は組み込み機能に割り当てているため、**キーは同じでも実装が違う**。

| 操作 | `.vimrc` | Zed keymap.json |
|---|---|---|
| ファイルを探して開く | `<Leader>f` → `:Files`（fzf） | `space space` → `file_finder::Toggle` |
| プロジェクト全体を検索 | `<Leader>/` → `:Rg`（fzf） | `space /` → `pane::DeploySearch` |
| バッファ/タブ切替 | `<Leader>b` → `:Buffers` | `space ,` → `tab_switcher::Toggle` |
| ファイルツリー | `<Leader>e` → `:NERDTreeToggle` | `space e` → `project_panel::ToggleFocus` |
| Git パネル | `<Leader>gs` → `:Git`（fugitive） | `space g` → `git_panel::ToggleFocus` |
| 保存 | `<Leader>w` → `:w` | `space w` → `workspace::Save` |
| 閉じる | `<Leader>q` → `:q` | `space q` → `pane::CloseActiveItem` |
| コマンドパレット | （なし） | `space p` → `command_palette::Toggle` |
| 定義へジャンプ | Neovim: `gd`（fzf-lua）/ Vim: 未設定 | `space d` → `editor::GoToDefinition` |
| シンボル一覧 | （なし） | `space o` / `space s` |
| リネーム / 修正 / 整形 | （なし） | `space c r` / `space c a` / `space c f` |

### 片方にしか無いもの（意図的）

| 項目 | 状況 |
|---|---|
| `nnoremap <Esc><Esc> :nohlsearch<CR>` | Zed では normal の `escape`（`editor::Cancel`）が検索ハイライトも消すため未移植。**未検証** — 消えなければバインドを足す |
| 矢印キー無効化（インサートモード） | Zed では**意図的に対象外**。補完・edit prediction の上下選択が効かなくなるため |
| `<Leader>gn` / `<Leader>gp`（GitGutter hunk 移動） | Zed 未移植。必要なら `editor::GoToHunk` |
| `<Leader>c`（vim-commentary） | Zed 未移植。必要なら `editor::ToggleComments` |
| `<Leader>tw`（末尾空白削除） | Zed では `"remove_trailing_whitespace_on_save": true` が常時担当 |
| `<Leader>n` / `<Leader>p` / `<Leader>d`（バッファ操作） | Zed はタブ UI があるため未移植 |
| `<Leader>s` / `<Leader>v`（ウィンドウ分割） | Zed 未移植。必要なら `pane::SplitDown` / `pane::SplitRight` |

## 2. オプション（`set` 系）

キーマップではないが、同じ意図の設定が両側にある。

| 意図 | `.vimrc` | Zed `settings.json` |
|---|---|---|
| 相対行番号 | `set number` + 相対表示 | `"vim": { "toggle_relative_line_numbers": true }` |
| OS クリップボード連携 | `set clipboard=unnamed,autoselect` | `"vim": { "use_system_clipboard": "on_yank" }` |
| 検索の大文字小文字あいまい | `set ignorecase` + `set smartcase` | `"vim": { "use_smartcase_find": true }` |
| 不可視文字の表示 | `set list` + `set listchars=...` | `"show_whitespaces": "all"` |
| インデント幅 | `set shiftwidth=4` ほか | `"tab_size": 4` |
| 保存時の自動整形 | ALE `g:ale_fix_on_save = 1` | `"format_on_save": "on"` |
| 保存時の末尾空白削除 | ALE `trim_whitespace` fixer | `"remove_trailing_whitespace_on_save": true` |
| カーソル行ハイライト | `set cursorline` | `"current_line_highlight": "all"` |
| 折り返しガイド | （なし） | `"wrap_guides": [80, 100]` |

`vim` キーに置ける設定は Zed 側で固定されている（`default_mode` / `use_system_clipboard` /
`use_smartcase_find` / `use_regex_search` / `gdefault` / `toggle_relative_line_numbers` /
`custom_digraphs` / `highlight_on_yank_duration`）。それ以外の vim 的挙動は通常の設定キーで表現する。

## 3. 書き方のメモ

Zed の keymap.json でハマりやすい点。

| 項目 | 書き方 |
|---|---|
| 連続キー | **スペース区切り**。`"j j"` であって `"jj"` ではない |
| 大文字 | `"shift-j"`。`"J"` とは書かない |
| キー列を送る | `["workspace::SendKeystrokes", "1 0 j"]` — 引数も**1打鍵ずつスペース区切り**（`"10j"` は不可）。上限100打鍵 |
| 送る列に自分自身を含める | 可。`"ctrl-d"` に `"ctrl-d z z"` を送ると、内側は**次に優先度の高い定義**（= Zed 既定）に落ちるので再帰しない |
| 既定のバインドを消す | アクションに `null` を指定する |
| アクション名を調べる | コマンドパレットで `zed: open default keymap` / `zed: open all actions` |

出典: <https://zed.dev/docs/key-bindings> / <https://zed.dev/docs/vim>

## 4. どちらがどこで使われるか

| エディタ | 設定 | 起動する場面 |
|---|---|---|
| ターミナルの Neovim | `~/.config/nvim/init.lua` + `~/.vim/common.vim` | `git commit` / `fv`（`$TERM_EDITOR`。既定は nvim）、`nvim <file>` |
| ターミナルの vim | `~/.vimrc` + `~/.vim/common.vim` | `vim <file>`、`TERM_EDITOR=vim` にしたときの `git commit` / `fv` |
| Zed の vim モード | `~/.config/zed/{settings,keymap}.json` | GUI での編集全般 |

> Zed 内蔵ターミナルは `"EDITOR": "zed --wait"` を設定しているため、
> **そこで `git commit` すると Neovim ではなく Zed が開く**。外部ターミナル（iTerm2）では `$TERM_EDITOR`（既定は nvim）が開く。

## 5. Neovim のキーとテクニック

`<Space>` を押して待つと which-key が続きのキーを一覧表示する。迷ったらまずこれ。
最初は **`K`、`gd` → `Ctrl-o`、`grr`、`grn`、`<Space>f`、`<Space>/`** の6つで十分。

設定の場所: LSP は `nvim/.config/nvim/lua/plugins/lsp.lua`、補完は `completion.lua`、検索は `files.lua`、
共通キー（`<Space>j` など）は `vim/.vim/common.vim`。

### コードを読む（LSP）

| キー | 動作 |
|---|---|
| `K` | ドキュメント表示（もう一度押すとポップアップに入ってスクロール・コピーできる） |
| `gd` | 定義へジャンプ（候補が複数なら fzf で選ぶ） |
| `grr` | 参照一覧（fzf・プレビュー付き） |
| `gri` / `grt` | 実装 / 型定義へジャンプ |
| `<Space>o` | ファイル内のシンボル一覧（関数・クラス） |
| `Ctrl-o` / `Ctrl-i` | ジャンプ前の位置に戻る / 進む（`gd` で飛んだら `Ctrl-o` で戻る） |
| `<Space>ih` | 型のインライン表示を切り替え |

### コードを直す

| キー | 動作 |
|---|---|
| `grn` | 名前の一括変更（プロジェクト全体の参照も変わる） |
| `gra` | コードアクション（import の追加・修正の提案） |
| `]d` / `[d` | 次 / 前のエラーへ |
| `Ctrl-w d` | カーソル位置のエラーを全文表示 |
| `<Space>x` | ファイル内のエラー一覧 |
| `:w` | 保存時にプロジェクトの Formatter で整形 |
| `<Space>tf` | 保存時の整形のオン / オフ（他人のファイルを最小差分で直すとき） |

### 補完（挿入モード）

| キー | 動作 |
|---|---|
| `Ctrl-n` / `Ctrl-p` | 次 / 前の候補 |
| `Ctrl-y` | 確定 |
| `Ctrl-Space` | 候補を出す（もう一度でドキュメント） |
| `Ctrl-e` | 閉じる |
| `Ctrl-k` | 引数のヒントを切り替え |

### 探す（fzf-lua）

| キー | 動作 |
|---|---|
| `<Space>f` | ファイル検索 |
| `<Space>g` | git 管理のファイルだけ検索 |
| `<Space>b` | 開いているバッファ |
| `<Space>/` | プロジェクト全体を全文検索（ripgrep） |
| `:FzfLua resume` | 直前の検索画面をそのまま再開 |

fzf の画面の中:

| キー | 動作 |
|---|---|
| `Enter` | 開く |
| `Ctrl-v` / `Ctrl-s` / `Ctrl-t` | 縦分割 / 横分割 / タブで開く |
| `Tab` / `Alt-a` | 複数選択 / 全選択の切り替え |
| `Alt-q` | 選んだものを quickfix に送る |
| `F4` | プレビューの表示切り替え |
| `Shift-↑` / `Shift-↓` | プレビューのスクロール |
| `Alt-h` / `Alt-i` | 隠しファイル / gitignore 対象も含める |

### Git

| キー | 動作 |
|---|---|
| `<Space>gn` / `<Space>gp` | 次 / 前の変更箇所へ |
| `<Space>hp` | 変更箇所の差分をその場で表示 |
| `<Space>hs` / `<Space>hu` | 変更箇所だけステージ / 元に戻す |
| `<Space>gs` | fugitive の status（`s` でステージ、`cc` でコミット） |
| `<Space>gd` | 差分を左右に並べて表示 |

### 編集の小技

| キー | 動作 |
|---|---|
| `gcc` / `<Space>c` | コメントアウト（ビジュアル選択にも使える） |
| `ysiw"` / `cs"'` / `ds"` | 単語を `"` で囲む / `"` を `'` に変える / 囲みを外す |
| `Ctrl-n` | 同じ単語を複数選んでまとめて編集（マルチカーソル） |
| `J` | 下の行と連結 |
| `<Space>j` / `<Space>k` | 10行下 / 上へ |
| `]<Space>` / `[<Space>` | 下 / 上に空行を追加 |
| `]q` / `[q` | quickfix の次 / 前へ |
| `]b` / `[b` | 次 / 前のバッファへ |
| `gx` | カーソル下の URL をブラウザで開く |

### 組み合わせ技

- **プロジェクト全体の置換**: `<Space>/` で検索 → `Alt-a` で全選択 → `Alt-q` で quickfix へ → `:cdo s/old/new/g | update`
- **関数名の変更**: 文字列置換ではなく `grn`。LSP が参照を追うので、同名の別の変数は巻き込まない
- **undo**: 閉じても履歴が残る。`:earlier 10m` で10分前へ、`g-` / `g+` で分岐も含めて時間順に移動
- **並べて読む**: `<Space>v` で縦分割して片方で `gd` → 定義と呼び出し元を並べて読める

### 困ったとき

| コマンド | 用途 |
|---|---|
| `:checkhealth vim.lsp` | 動いている LSP と、ルートにしているフォルダ |
| `:ConformInfo` | このファイルで動く Formatter とエラーログ |
| `:Lazy` | プラグインの状態。`:Lazy update` 後は `lazy-lock.json` を commit する |
| `:messages` | 消えたエラーメッセージを見直す |
| `:Inspect` | カーソル位置の色がどのハイライトから来ているか |

## 6. tmux のキー

プレフィックスは **`Ctrl-a`**（以下 `prefix`）。設定は `tmux/.tmux.conf`、変えたら `prefix r` で再読み込み。

### ウィンドウ・セッションの移動

| キー | 動作 |
|---|---|
| `prefix f` | 全セッションのウィンドウを fzf で検索して移動（`iapi dock` のように打つ。標準の `find-window` を置き換え） |
| `prefix s` | セッション一覧（名前順）。`→` で中のウィンドウを展開して選べる |
| `prefix w` | 今のセッションのウィンドウ一覧（プレビュー付き） |
| `prefix 1`〜`9` | 番号のウィンドウへ |
| `prefix C-p` / `prefix C-n` | 前 / 次のウィンドウへ（押しっぱなしで連続） |
| `prefix a` | Claude Code が入力待ちのウィンドウへ（セッションをまたぐ・連打で巡回） |
| `prefix d` | デタッチ |

### ウィンドウ・ペインの操作

| キー | 動作 |
|---|---|
| `prefix c` | 新しいウィンドウ（今のディレクトリで開く） |
| `prefix \|` / `prefix -` | 左右 / 上下に分割（今のディレクトリで開く） |
| `Ctrl-h` / `Ctrl-j` / `Ctrl-k` / `Ctrl-l` | ペイン移動（プレフィックス不要。Vim の分割ともシームレスに移動） |
| `prefix H` / `J` / `K` / `L` | ペインのサイズ変更（押しっぱなしで連続） |
| `prefix m` | ペインの最大化 / 復元 |
| `prefix S` | 全ペインに同じ入力を送る（同期）の切り替え |

### コピー

| キー | 動作 |
|---|---|
| `prefix [` | コピーモード開始（vi キーで移動） |
| `v` / `Ctrl-v` | 選択開始 / 矩形選択の切り替え |
| `y` / `Enter` | 選択をクリップボードへコピーして終了 |
| `prefix ]` | 貼り付け |
| `prefix Tab` | ペイン内のパス・URL・単語を fzf で選んでコピー（extrakto） |

### セッションの保存・復元（tmux-resurrect / continuum）

| キー | 動作 |
|---|---|
| `prefix Ctrl-s` | 今の状態を保存（continuum が15分ごとに自動保存もする） |
| `prefix Ctrl-r` | 保存した状態を復元 |
