# KEYMAP — vim と Zed の対応表

`~/.vimrc`（ターミナルの vim）と `zed/.config/zed/keymap.json`（Zed の vim モード）の対応。
**片方を変えたら、この表を見てもう片方も直す。**

## なぜ2つ必要なのか

**Zed は `.vimrc` を読まない。** Zed の vim モードは Vim を組み込んだものではなく、
Zed による再実装なので、`inoremap` / `set` / プラグインという vimrc の語彙を解釈する仕組みが無い。
`load_vimrc` のような設定も存在しない（Zed 1.20.2 時点）。

同期の自動化も見送った。vimrc の中身は3層に分かれ、機械変換できるのは1層だけのため。

| 層 | 例 | 自動変換 |
|---|---|---|
| キー → キー | `nnoremap J 10j` | ⭕ `workspace::SendKeystrokes` で機械的に書ける |
| キー → コマンド | `nnoremap <Leader>e :NERDTreeToggle<CR>` | ❌ プラグイン名 → Zed アクション名の辞書が要る |
| `set` / プラグイン設定 | `set relativenumber` | △ Zed の settings.json に等価物がある分だけ |

機械変換できるのは十数本、そのうち半分は「矢印キー無効化」という一度書いたら触らない設定。
生成スクリプトを保守するコストのほうが高いので、**この表を正とする手動運用**にしている。

## 1. キーマップ

`.vimrc` は `~/dotfiles/vim/.vimrc`、Zed は `~/dotfiles/zed/.config/zed/keymap.json`。

### モード遷移・移動

| 操作 | `.vimrc` | Zed keymap.json |
|---|---|---|
| `jj` でインサートを抜ける | `inoremap <silent> jj <ESC>` | `"j j": "vim::NormalBefore"` |
| 10行下/上へ | `nnoremap J 10j` / `K 10k` | `"shift-j"` / `"shift-k"`: `SendKeystrokes "1 0 j"` / `"1 0 k"` |
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
| 定義へジャンプ | （ALE/LSP 未設定） | `space d` → `editor::GoToDefinition` |
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
| ターミナルの vim | `~/.vimrc` | `git commit`（`core.editor = vim`）、`vim <file>` |
| Zed の vim モード | `~/.config/zed/{settings,keymap}.json` | GUI での編集全般 |

> Zed 内蔵ターミナルは `"EDITOR": "zed --wait"` を設定しているため、
> **そこで `git commit` すると vim ではなく Zed が開く**。外部ターミナル（iTerm2）では vim が開く。
