-- ============================================================
-- Linter（nvim-lint）
-- ============================================================
-- 【方針】LSP が無いチェックだけをここで動かす。プロジェクトが使っているものだけ
--   Python : ruff / flake8 / mypy（探し方は lua/project_tools.lua。mypy は .venv にあるときだけ）
--   JS / TS : eslint は LSP（vscode-eslint-language-server）で動かすため、ここでは何もしない
-- 結果は LSP のエラーと同じ場所（左端の記号・下線・<Leader>x）に出る

local PYTHON_LINTERS = { 'ruff', 'flake8', 'mypy' }

return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPost', 'BufNewFile', 'BufWritePost' },
  config = function()
    local lint = require('lint')
    local tools = require('project_tools')

    -- project_tools で見つけたツールを使うように、nvim-lint の定義を包む
    for _, name in ipairs(PYTHON_LINTERS) do
      local base = require('lint.linters.' .. name)
      lint.linters[name] = function()
        local linter = vim.deepcopy(type(base) == 'function' and base() or base)
        local r = tools.resolve(0, name)
        if not r then
          return linter
        end
        linter.cmd = r.cmd
        local args = vim.list_extend(vim.list_extend(vim.deepcopy(r.prefix), r.args), linter.args or {})
        -- mypy はプロジェクトの .venv の Python でライブラリを探す
        if name == 'mypy' then
          for i, arg in ipairs(args) do
            if arg == '--python-executable' then
              args[i + 1] = tools.venv_python(tools.venv_root(0))
            end
          end
        end
        linter.args = args
        return linter
      end
    end

    local function lint_buffer(bufnr)
      if vim.bo[bufnr].filetype ~= 'python' then
        return
      end
      local names = vim.tbl_filter(function(name)
        return tools.resolve(bufnr, name) ~= nil
      end, PYTHON_LINTERS)
      if #names > 0 then
        vim.api.nvim_buf_call(bufnr, function()
          lint.try_lint(names)
        end)
      end
    end

    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
      group = vim.api.nvim_create_augroup('nvim_lint', { clear = true }),
      callback = function(args)
        lint_buffer(args.buf)
      end,
    })
    -- このプラグイン自体が BufReadPost で読み込まれるため、最初に開いたファイルはここでチェックする
    lint_buffer(vim.api.nvim_get_current_buf())
  end,
}
