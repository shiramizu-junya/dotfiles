-- ============================================================
-- Linter / Formatter
-- ============================================================
-- 【暫定】Vim と同じ ALE を使う。LSP（ドキュメント表示・補完）を入れるときに
-- 本体の LSP + conform.nvim + nvim-lint へ置き換える予定

return {
  'dense-analysis/ale',
  init = function()
    vim.g.ale_sign_error = '✗'
    vim.g.ale_sign_warning = '⚠'
    vim.g.ale_linters = {
      javascript = { 'eslint' },
      python = { 'pyright', 'flake8', 'pylint' },
      typescript = { 'tsserver', 'eslint' },
    }
    vim.g.ale_fixers = {
      ['*'] = { 'remove_trailing_lines', 'trim_whitespace' },
      javascript = { 'prettier', 'eslint' },
      typescript = { 'prettier', 'eslint' },
      python = { 'black', 'isort' },
    }
    vim.g.ale_fix_on_save = 1
    vim.g.ale_hover_to_floating_preview = 1
  end,
  -- K でカーソル下のドキュメントを表示（LSP を入れたら Neovim 標準の K に任せる）
  keys = {
    { 'K', '<Cmd>ALEHover<CR>', desc = 'ドキュメント表示' },
  },
  lazy = false,
}
