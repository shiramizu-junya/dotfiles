" ============================================================
" Vim / Neovim 共通設定 (common.vim)
" 目的: 基本設定・キーマップ・自動コマンドを Vim と Neovim で共有する
" 読み込み元: ~/.vimrc（Vim）と ~/.config/nvim/init.lua（Neovim）
" 【注意】プラグインの導入はここに書かない（Vim は .vimrc、Neovim は lua/plugins/）
" ============================================================

" ============================================================
" 1. 基本設定
" ============================================================

" --- 文字コード ---
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis

" --- ファイル処理 ---
set nobackup                    " バックアップファイルを作らない
set nowritebackup               " 保存時のバックアップを作らない
set noswapfile                  " スワップファイルを作らない
set autoread                    " 外部で変更されたら自動で読み込む
set hidden                      " 保存せずに別ファイルを開ける
set undofile                    " 閉じた後も undo できるように履歴を保存（保存先は Vim / Neovim で別）

" --- 表示設定 ---
set number                      " 行番号を表示
set norelativenumber            " 相対行番号は使わない(常に絶対行番号)
set cursorline                  " カーソル行をハイライト
set showmatch                   " 対応する括弧を表示
set matchtime=1                 " 括弧のハイライト時間
set laststatus=2                " ステータスラインを常に表示
set showcmd                     " 入力中のコマンドを表示
set cmdheight=2                 " コマンドラインの高さ
set title                       " タイトルを表示
set signcolumn=yes              " 記号の列を常に表示（エラーや Git 差分の記号で画面がずれない）

" --- 色設定 ---
" 【注意】termguicolors は Vim / Neovim で書き方が違うため、それぞれの設定ファイルで行う
syntax on                       " シンタックスハイライト有効化
set background=dark             " ダークモード

" カラースキーム（お好みで変更してください）
colorscheme sorbet
" colorscheme gruvbox
" colorscheme dracula
" colorscheme onedark

" コメントの色
hi Comment ctermfg=3

" --- インデント設定 ---
set autoindent                  " 自動インデント
set smartindent                 " スマートインデント
set expandtab                   " タブをスペースに変換
set tabstop=4                   " タブの表示幅
set shiftwidth=4                " インデント幅
set softtabstop=4               " タブキー押下時の幅

" --- 検索設定 ---
set ignorecase                  " 大文字小文字を区別しない
set smartcase                   " 大文字で検索すると区別する
set incsearch                   " インクリメンタル検索
set hlsearch                    " 検索結果をハイライト
set wrapscan                    " 検索がファイル末尾に達したら先頭から

" --- 補完設定 ---
set wildmenu                    " コマンドライン補完を強化
set wildmode=longest:full,full  " 補完モード
set history=10000               " コマンド履歴
set completeopt=menuone,noinsert,noselect

" --- マウス ---
" 【注意】クリップボードは Vim / Neovim で値が違うため、それぞれの設定ファイルで行う
set mouse=a                     " マウスを有効化

" --- その他 ---
set backspace=indent,eol,start  " バックスペースの動作
set virtualedit=block           " 矩形選択で文字がなくても移動可能
set ambiwidth=double            " 全角文字の表示幅
set noerrorbells                " エラー音を鳴らさない
set belloff=all                 " ビープ音を無効化
set nofoldenable                " フォールド機能を無効化

" --- 不可視文字の表示 ---
set list
set listchars=tab:>\ ,trail:.,extends:>,precedes:<,nbsp:+

" tmux連携のための設定
set ttimeoutlen=10              " キーコードのタイムアウトを短く
set updatetime=100              " 更新時間を短く（GitGutterなど）

" ============================================================
" 2. キーマッピング（キーボードショートカット）
" ============================================================

" --- リーダーキー = Space ---
" 【説明】Spaceキーを起点にして様々な操作ができます
let mapleader = "\<Space>"

" --- 矢印キーを無効化（hjkl推奨）---
" 【説明】Vimはhjklで移動するのが基本です
noremap  <up>    <nop>
noremap  <down>  <nop>
noremap  <left>  <nop>
noremap  <right> <nop>
inoremap <up>    <nop>
inoremap <down>  <nop>
inoremap <left>  <nop>
inoremap <right> <nop>

" --- ノーマルモードへ移行 ---
inoremap <silent> jj <ESC>

" --- 移動の強化 ---
" 【注意】J は本来の「行をつなげる」、K は「ドキュメント表示」に使うため、10行移動はリーダーキーで
" K の割り当ては Vim（.vimrc の ALE）と Neovim（標準の LSP）で実装が違うため、それぞれで行う
nnoremap <Leader>j 10j
nnoremap <Leader>k 10k

" --- スムーズスクロール ---
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" --- 検索ハイライトの消去 ---
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>

" --- 保存・終了 ---
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>Q :q!<CR>

" --- バッファ操作 ---
nnoremap <Leader>n :bnext<CR>
nnoremap <Leader>p :bprevious<CR>
nnoremap <Leader>d :bdelete<CR>

" --- ウィンドウ分割 ---
nnoremap <Leader>s :split<CR>
nnoremap <Leader>v :vsplit<CR>

" ============================================================
" 3. 共通プラグインの設定
" ============================================================
" 【説明】Vim と Neovim の両方に入れているプラグインの設定です
" プラグインが無くてもエラーにはなりません（変数とキーマップだけのため）

" --- NERDTree（ファイルツリー）---
nnoremap <Leader>e :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen=1        " ファイルを開いたら自動で閉じる
let NERDTreeShowHidden=1        " 隠しファイルを表示
let NERDTreeShowBookmarks=1     " ブックマークを表示
let NERDTreeWinSize=30          " ウィンドウサイズ

" --- FZF（ファジーファインダー）---
nnoremap <Leader>f :Files<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>g :GFiles<CR>
nnoremap <Leader>/ :Rg<CR>

let g:fzf_layout = { 'down': '40%' }
let g:fzf_preview_window = ['right:50%', 'ctrl-/']

" プロンプトを「検索: 」に設定（複数の方法で確実に適用）
let $FZF_DEFAULT_OPTS = '--prompt="検索: " --pointer=">" --marker="+"'
let g:fzf_opts = ['--prompt=検索: ', '--pointer=>', '--marker=+']

" Filesコマンドをカスタマイズ
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, {'options': ['--prompt=検索: ', '--pointer=>', '--marker=+']}, <bang>0)

" --- Lightline（ステータスライン）---
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }

" --- GitGutter（Git差分表示）---
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '-'
nmap <Leader>gn <Plug>(GitGutterNextHunk)
nmap <Leader>gp <Plug>(GitGutterPrevHunk)

" --- vim-commentary（コメントアウト）---
nnoremap <Leader>c :Commentary<CR>
vnoremap <Leader>c :Commentary<CR>

" --- vim-tmux-navigator（tmux連携）---
" 【重要】Ctrl+h/j/k/lでVimとtmuxをシームレスに移動
let g:tmux_navigator_no_mappings = 0
let g:tmux_navigator_save_on_switch = 1

" --- vim-fugitive（Git操作）---
nnoremap <Leader>gs :Git<CR>
nnoremap <Leader>gc :Git commit<CR>
nnoremap <Leader>gd :Gdiff<CR>

" ============================================================
" 4. 自動コマンド
" ============================================================

" --- 自動コメントを無効化 ---
augroup auto_comment_off
  autocmd!
  autocmd BufEnter * setlocal formatoptions-=r
  autocmd BufEnter * setlocal formatoptions-=o
augroup END

" --- HTML/XML閉じタグ自動補完 ---
augroup MyXML
  autocmd!
  autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
  autocmd Filetype html inoremap <buffer> </ </<C-x><C-o>
augroup END

" --- カーソル位置を記憶 ---
augroup remember_cursor_position
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
augroup END

" --- ファイルタイプ別設定 ---
augroup filetype_settings
  autocmd!
  autocmd FileType python setlocal shiftwidth=4 tabstop=4
  autocmd FileType javascript,typescript,typescriptreact setlocal shiftwidth=2 tabstop=2
  autocmd FileType html,css,scss setlocal shiftwidth=2 tabstop=2
  autocmd FileType markdown setlocal wrap linebreak
augroup END

" --- tmux内での自動再描画 ---
if exists('$TMUX')
  augroup tmux_auto_rename
    autocmd!
    autocmd BufEnter * call system("tmux rename-window 'vim'")
    autocmd VimLeave * call system("tmux rename-window 'zsh'")
  augroup END
endif

" ============================================================
" 5. カスタム関数
" ============================================================

" --- 末尾の空白を削除 ---
function! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfunction

nnoremap <Leader>tw :call TrimWhitespace()<CR>
