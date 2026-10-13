-- ============================================================
-- Neovim設定ファイル (init.lua)
-- 目的: ~/.vimrc を Vim と共有しつつ、Neovim 専用の設定を足す
-- ============================================================

-- --- Vim の設定を読み込む ---
-- 【説明】~/.vim を runtimepath に入れて、vim-plug やプラグインを Vim と共有します
vim.opt.runtimepath:prepend(vim.fn.expand('~/.vim'))
vim.opt.runtimepath:append(vim.fn.expand('~/.vim/after'))
vim.opt.packpath = vim.opt.runtimepath:get()
vim.cmd('source ~/.vimrc')
