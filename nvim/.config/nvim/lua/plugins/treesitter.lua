-- ============================================================
-- Treesitter（シンタックスハイライト）
-- ============================================================
-- 【説明】Vim の vim-polyglot 相当。構文木を作って正確にハイライトする
-- 【必要】tree-sitter-cli と C コンパイラ（Brewfile の tree-sitter-cli）
-- インデントは Neovim 標準のものを使う（Treesitter のインデントは Python で崩れやすいため）

local languages = {
  -- 業務の主戦場
  'python', 'htmldjango', 'javascript', 'typescript', 'tsx',
  'json', 'yaml', 'html', 'css',
  -- 周辺
  'bash', 'dockerfile', 'toml', 'sql', 'markdown', 'markdown_inline',
  -- Neovim 設定用
  'lua', 'vim', 'vimdoc', 'query',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false, -- 遅延読み込みに非対応
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').install(languages)

    -- パーサーがあるファイルタイプだけハイライトを有効にする
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter_start', { clear = true }),
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
