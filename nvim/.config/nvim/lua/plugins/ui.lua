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

  -- <Space> などを押して待つと、続けて押せるキーの一覧を出す
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      icons = { mappings = false }, -- アイコン用プラグインを入れていないため
      spec = {
        { '<Leader>g', group = 'Git' },
        { '<Leader>h', group = 'Git差分（GitGutter の hunk）' },
        { '<Leader>i', group = '表示の切り替え' },
        { '<Leader>t', group = '整形' },
        { '<Leader>j', desc = '10行下へ' },
        { '<Leader>k', desc = '10行上へ' },
      },
    },
  },

  -- --- カラースキーム（common.vim で切り替えたときに使う）---
  { 'morhetz/gruvbox', lazy = true },
  { 'dracula/vim', name = 'dracula', lazy = true },
  { 'joshdick/onedark.vim', lazy = true },
}
