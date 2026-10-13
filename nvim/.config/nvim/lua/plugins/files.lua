-- ============================================================
-- ファイル検索・操作系（Vim と同じプラグイン。設定は ~/.vim/common.vim）
-- ============================================================

return {
  -- ファイル検索エンジン + FZFのVim統合
  {
    'junegunn/fzf.vim',
    dependencies = {
      { 'junegunn/fzf', build = ':call fzf#install()' },
    },
  },

  -- ファイルツリー表示 + ファイルアイコン
  { 'preservim/nerdtree' },
  { 'ryanoasis/vim-devicons' },
}
