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
      python = { 'flake8', 'pylint' },
      typescript = { 'tsserver', 'eslint' },
    }
    vim.g.ale_fixers = {
      ['*'] = { 'remove_trailing_lines', 'trim_whitespace' },
      javascript = { 'prettier', 'eslint' },
      typescript = { 'prettier', 'eslint' },
      python = { 'black', 'isort' },
    }
    vim.g.ale_fix_on_save = 1
  end,
}
