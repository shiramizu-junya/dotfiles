-- ============================================================
-- 表示・UI
-- ============================================================

return {
  -- ステータスライン改善（Vim と同じ。設定は ~/.vim/common.vim）
  { 'itchyny/lightline.vim' },

  -- インデントを可視化（Vim の indentLine 相当）
  -- 【説明】indentLine は conceal を使うため JSON や Markdown の記号が隠れる。Neovim では使わない
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = { char = '|' }, -- ambiwidth=double だと '┊' は幅2になり使えない
      scope = { enabled = false },
      exclude = { filetypes = { 'help', 'nerdtree' } },
    },
  },

  -- --- カラースキーム（common.vim で切り替えたときに使う）---
  { 'morhetz/gruvbox', lazy = true },
  { 'dracula/vim', name = 'dracula', lazy = true },
  { 'joshdick/onedark.vim', lazy = true },
}
