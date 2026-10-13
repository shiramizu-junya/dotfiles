-- ============================================================
-- Neovim設定ファイル (init.lua)
-- 目的: Neovim 専用の設定とプラグイン
-- 共通の設定（基本設定・キーマップ・自動コマンド）は ~/.vim/common.vim に書く
-- プラグインは lua/plugins/*.lua に書く（lazy.nvim で管理）
-- ============================================================

-- ============================================================
-- 1. Neovim 専用の基本設定
-- ============================================================

vim.opt.termguicolors = true -- 24bit色（Neovim は t_8f/t_8b 不要）
vim.o.winborder = 'rounded'  -- ドキュメント表示などのポップアップに枠を付ける

-- --- クリップボード ---
-- 【説明】Neovim に autoselect は無いため unnamedplus を使う
vim.opt.clipboard = 'unnamedplus'

-- tmux内でのクリップボード設定（vim-tmux-clipboard に任せる）
if vim.env.TMUX then
  vim.opt.clipboard = ''
end

-- --- 使わない外部言語プロバイダを無効化（起動が速くなり :checkhealth の警告も消える）---
-- 【説明】Python などのプラグインは使っていない。LSP や Linter はプロバイダを使わない
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- ============================================================
-- 2. 共通設定の読み込み
-- ============================================================
-- 【注意】mapleader を設定するため、lazy.nvim より前に読み込む

vim.cmd('source ~/.vim/common.vim')

-- ============================================================
-- 3. 標準機能の設定
-- ============================================================

-- --- ヤンク時にハイライト（Vim の vim-highlightedyank 相当）---
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight_yank', { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- ============================================================
-- 4. プラグイン管理 (lazy.nvim)
-- ============================================================

-- --- lazy.nvim が無ければ取得する ---
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- lazy-lock.json を dotfiles 側に書き出す（init.lua はstowのリンクなので実体のディレクトリを使う）
local config_dir = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.stdpath('config') .. '/init.lua'), ':h')

require('lazy').setup({
  spec = { { import = 'plugins' } },
  lockfile = config_dir .. '/lazy-lock.json',
  install = { colorscheme = { 'dracula', 'sorbet' } },
  rocks = { enabled = false }, -- luarocks が必要なプラグインは使っていない
  change_detection = { notify = false },
})
