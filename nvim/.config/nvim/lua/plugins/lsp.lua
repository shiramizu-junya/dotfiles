-- ============================================================
-- LSP（ドキュメント表示・定義ジャンプ・補完の元データ・エラー表示）
-- ============================================================
-- 【説明】language server は Brewfile で入れる（basedpyright / typescript-language-server /
-- vscode-langservers-extracted / yaml-language-server）。eslint と biome はプロジェクトの node_modules を使う
--
-- キーマップ（Neovim 標準 + 追加分）:
--   K          ドキュメント表示            <C-s>（挿入中） 引数のヒント
--   gd         定義へジャンプ              grr  参照一覧
--   gri        実装へジャンプ              grt  型定義へジャンプ
--   grn        名前の一括変更              gra  コードアクション
--   [d / ]d    前 / 次のエラー             <C-w>d  カーソル位置のエラーを全文表示
--   <Leader>o  ファイル内のシンボル一覧    <Leader>x  エラー一覧
--   <Leader>ih 型のインライン表示を切り替え

return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'saghen/blink.cmp', 'b0o/SchemaStore.nvim', 'ibhagwan/fzf-lua' },
    config = function()
      local tools = require('project_tools')

      -- --- 全サーバ共通 ---
      vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

      -- --- Python ---
      -- 【説明】.venv があるディレクトリをプロジェクトのルートにして、その Python でライブラリを探す
      -- （Docker だけで動かすプロジェクトも、エディタ用に .venv を作れば Django などのドキュメントが出る）
      vim.lsp.config('basedpyright', {
        root_dir = function(bufnr, on_dir)
          on_dir(tools.venv_root(bufnr) or vim.fs.root(bufnr, {
            'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', 'manage.py', '.git',
          }))
        end,
        -- 【注意】config.settings はサーバに渡るテーブルそのものなので、作り直さずに直接書き換える
        before_init = function(_, config)
          local settings = config.settings
          local python = tools.venv_python(config.root_dir)
          if python then
            settings.python = settings.python or {}
            settings.python.pythonPath = python
          end
          -- ルートに site-packages があれば優先して使う（コンテナの依存ライブラリを手元にコピーして使うプロジェクト向け）
          local copied = config.root_dir and (config.root_dir .. '/site-packages')
          if copied and vim.fn.isdirectory(copied) == 1 then
            settings.basedpyright.analysis.extraPaths = { copied }
          end
        end,
        settings = {
          basedpyright = {
            -- 既定の recommended は厳しすぎるため pyright と同じ standard にする
            analysis = { typeCheckingMode = 'standard' },
          },
        },
      })

      -- --- JSON / YAML（ファイル名からスキーマを自動で当てる）---
      vim.lsp.config('jsonls', {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      })
      vim.lsp.config('yamlls', {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = '' }, -- SchemaStore.nvim の一覧を使う
            schemas = require('schemastore').yaml.schemas(),
          },
        },
      })

      vim.lsp.enable({ 'basedpyright', 'ts_ls', 'eslint', 'biome', 'jsonls', 'yamlls' })

      -- --- エラー表示 ---
      -- 下線と左端の記号は全行、メッセージはカーソル行だけ出す（古いコードでも画面が埋まらない）
      vim.diagnostic.config({
        severity_sort = true,
        underline = true,
        virtual_text = { current_line = true, source = 'if_many', spacing = 2 },
        float = { source = 'if_many' },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '✗',
            [vim.diagnostic.severity.WARN] = '⚠',
            [vim.diagnostic.severity.INFO] = 'i',
            [vim.diagnostic.severity.HINT] = 'h',
          },
        },
      })

      -- --- LSP が動いているバッファだけのキーマップ ---
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp_keymaps', { clear = true }),
        callback = function(args)
          local fzf = require('fzf-lua')
          local function map(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map('gd', fzf.lsp_definitions, '定義へジャンプ')
          map('grr', fzf.lsp_references, '参照一覧')
          map('gri', fzf.lsp_implementations, '実装へジャンプ')
          map('<Leader>o', fzf.lsp_document_symbols, 'ファイル内のシンボル一覧')
          map('<Leader>x', fzf.diagnostics_document, 'エラー一覧')
          map('<Leader>ih', function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = args.buf })
          end, '型のインライン表示を切り替え')
        end,
      })
    end,
  },

  -- JSON / YAML のスキーマ一覧（package.json / tsconfig.json / docker-compose / GitHub Actions など）
  { 'b0o/SchemaStore.nvim', lazy = true },
}
