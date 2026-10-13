-- ============================================================
-- 編集補助・tmux連携（Vim と同じプラグイン。設定は ~/.vim/common.vim）
-- ============================================================

return {
  -- --- 編集補助 ---
  { 'tpope/vim-commentary' },   -- コメントアウトを簡単に
  { 'tpope/vim-surround' },     -- 囲み文字の操作
  { 'jiangmiao/auto-pairs' },   -- 括弧の自動補完
  { 'mg979/vim-visual-multi' }, -- マルチカーソル編集（Ctrl-n）

  -- --- tmux連携 ---
  -- 【説明】フォーカスイベントは Neovim 標準対応のため vim-tmux-focus-events は不要
  { 'christoomey/vim-tmux-navigator' }, -- tmuxとNeovimをシームレスに移動
  { 'roxma/vim-tmux-clipboard' },       -- tmuxとクリップボード共有
}
