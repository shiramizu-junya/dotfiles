-- ============================================================
-- 保存時の整形（conform.nvim）
-- ============================================================
-- 【方針】プロジェクトが使っているツールだけを、プロジェクトと同じバージョンで動かす
--   Python : ruff（ruff があって black が無いとき） / isort + black
--            探し方は lua/project_tools.lua（.venv → pre-commit のバージョン → 設定ファイル）
--   JS / TS / JSON / YAML / CSS : biome か prettier（プロジェクトの node_modules と設定ファイルがあるときだけ）
--   それ以外 : 行末の空白と、ファイル末尾の余分な空行を消すだけ
-- <Leader>tf で保存時の整形を一時的に止められる（他人のファイルを触るときなど）

-- project_tools で見つけたツールを使うように、conform の定義を上書きする
local function project_tool(tool)
  local tools = require('project_tools')
  return {
    command = function(_, ctx)
      local r = tools.resolve(ctx.buf, tool)
      return r and r.cmd or tool
    end,
    prepend_args = function(_, ctx)
      local r = tools.resolve(ctx.buf, tool)
      return r and vim.list_extend(vim.deepcopy(r.prefix), r.args) or {}
    end,
    condition = function(_, ctx)
      return tools.resolve(ctx.buf, tool) ~= nil
    end,
  }
end

-- ruff は black を使っていないプロジェクトだけ（両方あるときは black を優先）
local function ruff_tool()
  local tools = require('project_tools')
  local def = project_tool('ruff')
  -- ruff の args（--fix など）は使わない。prefix だけ付ける
  def.prepend_args = function(_, ctx)
    local r = tools.resolve(ctx.buf, 'ruff')
    return r and vim.deepcopy(r.prefix) or {}
  end
  def.condition = function(_, ctx)
    return tools.resolve(ctx.buf, 'ruff') ~= nil and tools.resolve(ctx.buf, 'black') == nil
  end
  return def
end

local js = { 'biome', 'prettier', stop_after_first = true }

return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  cmd = 'ConformInfo',
  keys = {
    {
      '<Leader>tf',
      function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify('保存時の整形: ' .. (vim.g.disable_autoformat and 'オフ' or 'オン'))
      end,
      desc = '保存時の整形を切り替え',
    },
  },
  opts = {
    formatters_by_ft = {
      python = { 'ruff_organize_imports', 'ruff_format', 'isort', 'black' },
      javascript = js,
      javascriptreact = js,
      typescript = js,
      typescriptreact = js,
      json = js,
      jsonc = js,
      yaml = { 'prettier' },
      css = js,
      scss = { 'prettier' },
      -- 整形ツールが無いファイルタイプ
      ['_'] = { 'trim_whitespace', 'trim_newlines' },
    },
    formatters = {
      black = project_tool('black'),
      isort = project_tool('isort'),
      ruff_format = ruff_tool(),
      ruff_organize_imports = ruff_tool(),
      -- 設定ファイルがあるプロジェクトだけで動かす
      prettier = { require_cwd = true },
      biome = { require_cwd = true },
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.api.nvim_buf_get_name(bufnr):match('/node_modules/') then
        return nil
      end
      -- uvx の初回はツールのダウンロードで時間がかかるため長めにする
      return { timeout_ms = 3000, lsp_format = 'never' }
    end,
    notify_no_formatters = false,
  },
}
