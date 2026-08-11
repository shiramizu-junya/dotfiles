# Claude Code の MCP サーバ / プラグイン管理

いずれも「宣言を JSON に置き、適用をスクリプトで流す」方式で統一している。
`~/.claude/` を丸ごと symlink しない（`sessions/`・`history.jsonl`・`projects/` などの
会話ログとローカル状態が同居しているため）。

| 対象 | 宣言 | 適用 |
|---|---|---|
| MCP サーバ | `mcp-servers.json` | `make mcp` |
| プラグイン | `plugins.json` | `make claude-plugins` |

---

## MCP サーバ

Claude Code の MCP サーバ定義を管理する。
`~/.claude.json` はキャッシュ・マシンID等の**ローカル状態を大量に含む**ため丸ごとは管理せず、
**MCP定義(`mcpServers`)だけ** を `mcp-servers.json` に切り出して管理する。

**秘密は一切含めない**。トークン類は `~/.zshenv` の環境変数を `${VAR}` 形式で参照する
（Claude Code が実行時に展開する）。そのため `mcp-servers.json` は安全にコミットできる。

## 管理しているMCPサーバ

| サーバ | 種別 | 必要な秘密（環境変数 / ファイル） | 用途 |
|---|---|---|---|
| notion | stdio | `NOTION_ACCESS_TOKEN` | Notion 操作 |
| supabase | stdio | `SUPABASE_ACCESS_TOKEN` | Supabase 操作 |
| context7 | http | `CONTEXT7_API_KEY` | ライブラリ最新ドキュメント取得 |
| dbhub | stdio | `~/.config/dbhub/dbhub.toml`（手動配置・秘密） | DB 接続 |
| playwright | stdio | なし | ブラウザ自動化 |
| chrome-devtools | stdio | なし | Chrome DevTools 連携 |
| drawio | stdio | なし | 作図 |

## セットアップ（新Mac）

1. `~/.zshenv` に必要なトークンを設定する（`zsh/.zshenv.example` 参照）
2. `dbhub` を使う場合は `~/.config/dbhub/dbhub.toml` を用意（接続情報＝秘密のため手動）
3. 登録する:
   ```bash
   make mcp          # または bash claude/mcp-setup.sh
   ```
4. 確認: `claude mcp list`

## 設定を更新したとき

Claude Code 側で MCP 構成を変えたら、`mcp-servers.json` に反映してコミットする
（秘密の値は必ず `${VAR}` 参照に置き換えること）。

---

## プラグイン

プラグインの正は `settings.json` の `enabledPlugins` であり、
`~/.claude/plugins/installed_plugins.json` はそこから生成される派生キャッシュ（手で触らない）。
ここでは `~/.claude/settings.json`（user スコープ）へ `claude plugin install -s user` で流し込む。

`~/.claude/settings.json` を symlink しないのは、Claude Code 自身がこのファイルを
書き換える（`/plugin` の UI など）ため、アトミック書き込みで symlink が実ファイルに
置き換わり追跡が切れるリスクがあるため。MCP と同じくスクリプト適用型にしている。

### 管理しているプラグイン

| プラグイン | 常時コスト | 必要なバイナリ | 用途 |
|---|---|---|---|
| typescript-lsp | 0 | `typescript-language-server` | TS/JS の型エラーを編集直後に検知 |
| pyright-lsp | 0 | `pyright-langserver` | Python の型エラーを編集直後に検知 |
| security-guidance | 0 | なし | 生成コードをフック4種で脆弱性レビュー |
| commit-commands | 108 | なし | `/commit` `/commit-push-pr` `/clean_gone` |

**LSP プラグインは言語サーバのバイナリを入れてくれない。** バイナリは `Brewfile` の
「言語サーバ」セクションに書いてあるので、必ず `make brew` を先に済ませること。

コストは `/plugin` の Discover タブ（= `~/.claude/plugins/plugin-catalog-cache.json`）で
インストール前に確認できる。常時コストの大きいもの（`sentry` 4.3k、`vercel` 2.6k など）は
使っていないなら入れない。

### セットアップ（新Mac）

```bash
make brew            # 言語サーバのバイナリを含めて導入
make claude-plugins  # プラグイン導入
```

確認: `claude plugin list` / Claude Code 内で `/plugin` の Errors タブが空であること。
反映: `/reload-plugins`（LSP は本体の再起動が必要な場合あり）。

### 増やしたいとき

`plugins.json` を編集して `make claude-plugins` を実行する。
バイナリを要するプラグインなら `requires` に書き、`Brewfile` にも追加する。
