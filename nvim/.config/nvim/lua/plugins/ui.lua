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

  -- --- カラースキーム（VSCode・Zed と同じ Dracula）---
  -- 【説明】公式版。treesitter と LSP の色分け、lightline の配色にも対応している
  -- 起動時に他のプラグインより先に読み込んで色を設定する（Vim は common.vim で設定）
  {
    'dracula/vim',
    name = 'dracula',
    lazy = false,
    priority = 1000,
    config = function() vim.cmd.colorscheme('dracula') end,
  },
  -- 他の候補（:colorscheme gruvbox などで切り替えられる）
  { 'morhetz/gruvbox', lazy = true },
  { 'joshdick/onedark.vim', lazy = true },
}
