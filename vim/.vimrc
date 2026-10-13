" ============================================================
" Vim設定ファイル (.vimrc)
" 目的: Vim 専用の設定とプラグイン
" 共通の設定（基本設定・キーマップ・自動コマンド）は ~/.vim/common.vim に書く
" Neovim の設定は ~/.config/nvim/init.lua
" ============================================================

" ============================================================
" 1. プラグイン管理 (vim-plug)
" ============================================================
" 【説明】vim-plugを使ってプラグインを管理します
" プラグインとは：Vimに機能を追加する拡張機能のことです
" 【注意】Neovim 側にも入れたいプラグインは nvim/.config/nvim/lua/plugins/ にも書く

call plug#begin('~/.vim/plugged')

" --- ファイル検索・操作系 ---
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  " ファイル検索エンジン
Plug 'junegunn/fzf.vim'                               " FZFのVim統合
Plug 'preservim/nerdtree'                             " ファイルツリー表示
Plug 'ryanoasis/vim-devicons'                         " ファイルアイコン表示

" --- Git統合 ---
Plug 'airblade/vim-gitgutter'                         " Git差分を左側に表示
Plug 'tpope/vim-fugitive'                             " Git操作をVim内で実行

" --- 編集補助 ---
Plug 'tpope/vim-commentary'                           " コメントアウトを簡単に
Plug 'tpope/vim-surround'                             " 囲み文字の操作
Plug 'jiangmiao/auto-pairs'                           " 括弧の自動補完
Plug 'mg979/vim-visual-multi'                         " マルチカーソル編集（Ctrl-n。旧 terryma/vim-multiple-cursors の後継）

" --- 表示・UI ---
Plug 'itchyny/lightline.vim'                          " ステータスライン改善
Plug 'Yggdroot/indentLine'                            " インデントを可視化
Plug 'machakann/vim-highlightedyank'                  " ヤンク時にハイライト

" --- tmux連携（重要！）---
Plug 'christoomey/vim-tmux-navigator'                 " tmuxとVimをシームレスに移動
Plug 'tmux-plugins/vim-tmux-focus-events'             " tmux内でのフォーカスイベント
Plug 'roxma/vim-tmux-clipboard'                       " tmuxとクリップボード共有

" --- コード品質 ---
Plug 'dense-analysis/ale'                             " Linter（コードチェック）
Plug 'sheerun/vim-polyglot'                           " 多言語のシンタックス対応

" --- カラースキーム ---
Plug 'morhetz/gruvbox'                                " Gruvboxテーマ
Plug 'dracula/vim', { 'as': 'dracula' }               " Draculaテーマ
Plug 'joshdick/onedark.vim'                           " OneDarkテーマ

call plug#end()

" ============================================================
" 2. Vim 専用の基本設定
" ============================================================

" 256色対応（tmux内でも綺麗に表示）
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" --- undo 履歴の保存先 ---
" 【説明】既定ではファイルと同じ場所に作られるため、専用のフォルダにまとめる（Neovim は ~/.local/state/nvim/undo）
set undodir=~/.local/state/vim/undo//
if !isdirectory(expand('~/.local/state/vim/undo'))
  call mkdir(expand('~/.local/state/vim/undo'), 'p')
endif

" --- クリップボード ---
set clipboard=unnamed,autoselect " クリップボード連携

" tmux内でのクリップボード設定
if exists('$TMUX')
  set clipboard=
endif

" ============================================================
" 3. 共通設定の読み込み
" ============================================================

" 【注意】.vimrc だけをサーバなどにコピーしても起動できるよう、無ければ読まない
if filereadable(expand('~/.vim/common.vim'))
  source ~/.vim/common.vim
endif

" ============================================================
" 4. Vim 専用のプラグイン設定
" ============================================================

" --- ALE（Linter）---
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠'
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'python': ['pyright', 'flake8', 'pylint'],
\   'typescript': ['tsserver', 'eslint'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['prettier', 'eslint'],
\   'typescript': ['prettier', 'eslint'],
\   'python': ['black', 'isort'],
\}
let g:ale_fix_on_save = 1

" K でカーソル下のドキュメントを表示（pyright / tsserver が対応する言語のみ）
let g:ale_hover_to_floating_preview = 1
nnoremap <silent> K :ALEHover<CR>

" --- IndentLine（インデント表示）---
let g:indentLine_char = '┊'
let g:indentLine_fileTypeExclude = ['help', 'nerdtree']

" --- HighlightedYank（ヤンク時のハイライト）---
let g:highlightedyank_highlight_duration = 200

" ============================================================
" 5. 自動コマンド
" ============================================================

" --- 設定ファイルの自動読み込み ---
augroup source-vimrc
  autocmd!
  autocmd BufWritePost *vimrc,common.vim source $MYVIMRC
augroup END

" ============================================================
" 終了
" ============================================================

filetype plugin indent on
