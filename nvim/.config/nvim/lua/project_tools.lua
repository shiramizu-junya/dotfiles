-- ============================================================
-- プロジェクトが使っている Python の Linter / Formatter を探す
-- ============================================================
-- 【説明】プロジェクトごとにツールとバージョンが違うため、エディタ側では決め打ちしない
-- 探す順番:
--   1. プロジェクトの .venv/bin にあるもの
--   2. .pre-commit-config.yaml で指定されたバージョン・引数（uvx で同じバージョンを動かす）
--   3. requirements*.txt / pyproject.toml で固定されたバージョン（ruff==0.16.9 など）
--   4. pyproject.toml などに設定があるもの（uvx で最新版を動かす）
-- どれにも当たらなければ動かさない

local M = {}

-- pre-commit の args をそのまま使うツール（ruff の args は --fix など整形向けのため使わない）
local USE_HOOK_ARGS = { black = true, isort = true, flake8 = true }

-- pre-commit の hook id
local HOOK_IDS = {
  black = { 'black' },
  isort = { 'isort' },
  flake8 = { 'flake8' },
  ruff = { 'ruff', 'ruff-check', 'ruff-format' },
}

-- 設定ファイルで使っていると分かるツール（ファイル名 / pyproject などのセクション）
local CONFIG_FILES = {
  ruff = { 'ruff.toml', '.ruff.toml' },
  isort = { '.isort.cfg' },
  flake8 = { '.flake8' },
}
local CONFIG_SECTIONS = {
  ruff = { 'pyproject.toml', '%[tool%.ruff[%.%]]' },
  black = { 'pyproject.toml', '%[tool%.black%]' },
  isort = { 'pyproject.toml', '%[tool%.isort%]' },
  flake8 = { 'setup.cfg', '%[flake8%]' },
}

-- バッファのファイルから上にたどって探す（ホームより上は見ない）
local function find_up(bufnr, names)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then
    return nil
  end
  return vim.fs.find(names, { path = vim.fs.dirname(name), upward = true, stop = vim.env.HOME })[1]
end

local function read(path)
  local f = io.open(path, 'r')
  if not f then
    return ''
  end
  local s = f:read('*a')
  f:close()
  return s
end

-- "[a, "b,c", 'd']" を { 'a', 'b,c', 'd' } にする
local function parse_list(s)
  local items = {}
  local inner = s:match('^%s*%[(.*)%]%s*$')
  if not inner then
    return items
  end
  local i = 1
  while i <= #inner do
    local c = inner:sub(i, i)
    if c:match('[%s,]') then
      i = i + 1
    elseif c == '"' or c == "'" then
      local j = inner:find(c, i + 1, true) or (#inner + 1)
      table.insert(items, inner:sub(i + 1, j - 1))
      i = j + 1
    else
      local j = inner:find(',', i, true) or (#inner + 1)
      table.insert(items, vim.trim(inner:sub(i, j - 1)))
      i = j
    end
  end
  return items
end

-- "python39" / "python3.12" を "3.9" / "3.12" にする（"python3" のように版が決まらないものは nil）
local function python_version(s)
  local v = s and s:match('python(%d[%d%.]*)')
  if not v or #v < 2 then
    return nil
  end
  return v:find('%.') and v or (v:sub(1, 1) .. '.' .. v:sub(2))
end

-- .pre-commit-config.yaml を読む（ファイルが変わるまで結果を使い回す）
-- 戻り値: { dir, exclude, python, hooks = { [id] = { rev, args, python } } }
local precommit_cache = {}
local function precommit_config(bufnr)
  local path = find_up(bufnr, { '.pre-commit-config.yaml' })
  local stat = path and vim.uv.fs_stat(path)
  if not stat then
    return nil
  end
  local cached = precommit_cache[path]
  if cached and cached.mtime == stat.mtime.sec then
    return cached.config
  end

  local config = { dir = vim.fs.dirname(path), hooks = {} }
  local rev, hook, in_default
  for line in io.lines(path) do
    config.exclude = config.exclude or line:match('^exclude:%s*["\']?(.-)["\']?%s*$')
    if line:match('^default_language_version:') then
      in_default = true
    elseif line:match('^%S') then
      in_default = false
    end
    if in_default then
      config.python = config.python or python_version(line:match('^%s+python:%s*(%S+)'))
    end

    if line:match('^%s*-%s*repo:') then
      rev, hook = nil, nil
    end
    rev = line:match('^%s*rev:%s*["\']?([^"\'%s]+)') or rev
    local id = line:match('^%s*-%s*id:%s*([%w_%.%-]+)')
    if id then
      hook = { rev = rev and rev:gsub('^v', ''), args = {} }
      config.hooks[id] = config.hooks[id] or hook
    elseif hook then
      local args = line:match('^%s*args:%s*(%[.*%])')
      if args then
        hook.args = parse_list(args)
      end
      hook.python = hook.python or python_version(line:match('^%s*language_version:%s*(%S+)'))
    end
  end
  precommit_cache[path] = { mtime = stat.mtime.sec, config = config }
  return config
end

-- pre-commit の exclude に当たるファイル（migrations など）は、どのツールも動かさない
local function precommit_excluded(bufnr, config)
  if not (config and config.exclude) then
    return false
  end
  local rel = vim.api.nvim_buf_get_name(bufnr):sub(#config.dir + 2)
  local ok, re = pcall(vim.regex, '\\v' .. config.exclude)
  return ok and re:match_str(rel) ~= nil
end

-- requirements*.txt / requirements/*.txt / pyproject.toml で固定されたバージョン（例: ruff==0.16.9）
local function pinned_version(bufnr, tool)
  local files = {}
  local req = find_up(bufnr, { 'requirements' })
  if req and vim.fn.isdirectory(req) == 1 then
    vim.list_extend(files, vim.fn.glob(req .. '/*.txt', false, true))
  end
  local base = find_up(bufnr, { 'requirements.txt', 'pyproject.toml' })
  if base then
    vim.list_extend(files, vim.fn.glob(vim.fs.dirname(base) .. '/requirements*.txt', false, true))
    table.insert(files, vim.fs.dirname(base) .. '/pyproject.toml')
  end
  for _, path in ipairs(files) do
    local text = '\n' .. read(path)
    local v = text:match('\n%s*' .. tool .. '%s*==%s*([%w%.]+)') or text:match('["\']' .. tool .. '==([%w%.]+)["\']')
    if v then
      return v
    end
  end
  return nil
end

local function declared_in_config(bufnr, tool)
  if CONFIG_FILES[tool] and find_up(bufnr, CONFIG_FILES[tool]) then
    return true
  end
  local section = CONFIG_SECTIONS[tool]
  if section then
    local path = find_up(bufnr, { section[1] })
    if path and read(path):find(section[2]) then
      return true
    end
  end
  return false
end

-- .venv があるディレクトリ（なければ nil）
function M.venv_root(bufnr)
  local venv = find_up(bufnr, { '.venv' })
  return venv and vim.fs.dirname(venv) or nil
end

-- 指定ディレクトリの .venv の python（なければ nil）
function M.venv_python(root)
  local python = root and (root .. '/.venv/bin/python')
  return python and vim.fn.executable(python) == 1 and python or nil
end

-- ツールの実行方法を返す
-- 戻り値: { cmd = 実行ファイル, prefix = cmd の直後に付ける引数, args = pre-commit の args }、使わないなら nil
-- mypy はプロジェクトの依存ライブラリとプラグインが要るため .venv にあるときだけ使う
function M.resolve(bufnr, tool)
  local precommit = precommit_config(bufnr)
  if precommit_excluded(bufnr, precommit) then
    return nil
  end
  local root = M.venv_root(bufnr)
  local hook
  for _, id in ipairs(HOOK_IDS[tool] or {}) do
    hook = hook or (precommit and precommit.hooks[id])
  end
  local hook_args = (hook and USE_HOOK_ARGS[tool]) and hook.args or {}

  local bin = root and (root .. '/.venv/bin/' .. tool)
  if bin and vim.fn.executable(bin) == 1 then
    return { cmd = bin, prefix = {}, args = hook_args }
  end
  if tool == 'mypy' or vim.fn.executable('uvx') == 0 then
    return nil
  end
  if hook and hook.rev then
    local prefix = { '--from', tool .. '==' .. hook.rev, tool }
    -- 古いツールは新しい Python で動かないことがあるため、pre-commit と同じ Python を使う
    local python = hook.python or precommit.python or M.venv_python(root)
    if python then
      prefix = vim.list_extend({ '--python', python }, prefix)
    end
    return { cmd = 'uvx', prefix = prefix, args = hook_args }
  end
  local pinned = pinned_version(bufnr, tool)
  if pinned then
    local prefix = { '--from', tool .. '==' .. pinned, tool }
    local python = M.venv_python(root)
    if python then
      prefix = vim.list_extend({ '--python', python }, prefix)
    end
    return { cmd = 'uvx', prefix = prefix, args = {} }
  end
  if declared_in_config(bufnr, tool) then
    return { cmd = 'uvx', prefix = { tool }, args = {} }
  end
  return nil
end

return M
