# Claude Code の MCP サーバ管理

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
