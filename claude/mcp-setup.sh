#!/usr/bin/env bash
# Claude Code の MCP サーバを登録する（user スコープ）。
# 秘密は ~/.zshenv の環境変数を ${VAR} で参照するため、このリポジトリには秘密を含まない。
# 前提: ~/.zshenv に各トークンを設定済み（zsh/.zshenv.example 参照）。
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON="$DIR/mcp-servers.json"

if ! command -v claude >/dev/null 2>&1; then
  echo "❌ claude CLI が見つかりません。Claude Code を先に導入してください。" >&2
  exit 1
fi

for name in $(jq -r 'keys[]' "$JSON"); do
  cfg=$(jq -c --arg n "$name" '.[$n]' "$JSON")
  echo "→ MCP登録: $name"
  claude mcp add-json "$name" "$cfg" -s user 2>/dev/null \
    || echo "  ⚠️ $name は登録済みか、CLI差異の可能性。'claude mcp list' で確認してください。"
done

echo "✅ MCP セットアップ完了。'claude mcp list' で確認してください。"
