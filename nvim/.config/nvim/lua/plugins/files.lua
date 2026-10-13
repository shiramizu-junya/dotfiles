-- ============================================================
-- ファイル検索・操作系
-- ============================================================

return {
  -- ファジーファインダー（Vim の fzf.vim 相当。同じ fzf を使う）
  -- 【説明】LSP の参照一覧・シンボル一覧・エラー一覧も同じ画面で絞り込めるため、Neovim では fzf-lua を使う
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    keys = {
      { '<Leader>f', '<Cmd>FzfLua files<CR>', desc = 'ファイル検索' },
      { '<Leader>b', '<Cmd>FzfLua buffers<CR>', desc = 'バッファ一覧' },
      { '<Leader>g', '<Cmd>FzfLua git_files<CR>', desc = 'Git管理のファイル検索' },
      { '<Leader>/', '<Cmd>FzfLua live_grep<CR>', desc = 'プロジェクト全体を検索' },
    },
    opts = {
      winopts = { height = 0.4, width = 1, row = 1, preview = { horizontal = 'right:50%' } },
      fzf_opts = { ['--pointer'] = '>', ['--marker'] = '+' },
      files = { prompt = '検索: ' },
      buffers = { prompt = '検索: ' },
      git = { files = { prompt = '検索: ' } },
      grep = { prompt = '検索: ' },
    },
  },

  -- ファイルツリー表示 + ファイルアイコン（Vim と同じ。設定は ~/.vim/common.vim）
  { 'preservim/nerdtree' },
  { 'ryanoasis/vim-devicons' },
}
