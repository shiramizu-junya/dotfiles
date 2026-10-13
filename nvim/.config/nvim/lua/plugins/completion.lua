-- ============================================================
-- 補完（blink.cmp）
-- ============================================================
-- キーマップ（preset = 'default'。Neovim 標準の補完と同じ操作）:
--   <C-n> / <C-p>  次 / 前の候補          <C-y>  確定
--   <C-space>      候補を出す / ドキュメントを出す
--   <C-e>          閉じる                  <C-k>  引数のヒントを切り替え
-- 【説明】<Tab> で確定しないのは、インデントを入れたいときに補完を誤って確定しないため

return {
  'saghen/blink.cmp',
  version = '1.*', -- リリース版にすると、ビルド済みの高速検索（Rust）を自動でダウンロードする
  dependencies = { 'rafamadriz/friendly-snippets' },
  event = { 'InsertEnter', 'LspAttach' },
  opts = {
    keymap = { preset = 'default' },
    completion = {
      -- 候補を選ぶと横に docstring を出す
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    -- 関数の引数を入力中にシグネチャを出す
    signature = { enabled = true },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    -- コマンドライン（:）の補完は今までどおり Neovim 標準を使う
    cmdline = { enabled = false },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
}
