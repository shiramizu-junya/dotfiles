#!/usr/bin/env bash
# Claude Code のプラグインを user スコープで導入する。
# 宣言は plugins.json。増減させたいときはその JSON だけ編集して `make claude-plugins`。
#
# 注意: プラグインは言語サーバのバイナリを入れてくれない。
#       必要なバイナリは Brewfile 側に書いてあるので `make brew` で導入すること。
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON="$DIR/plugins.json"

if ! command -v claude >/dev/null 2>&1; then
  echo "❌ claude CLI が見つかりません。Claude Code を先に導入してください。" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "❌ jq が見つかりません。先に 'make brew' を実行してください。" >&2
  exit 1
fi

# --- 1) マーケットプレイス登録 ---
# 公式マーケットプレイスは起動時に自動追加されるが、新Macでの確実性のため明示する。
while IFS= read -r name; do
  repo=$(jq -r --arg n "$name" '.marketplaces[$n]' "$JSON")
  echo "→ marketplace: $name ($repo)"
  claude plugin marketplace add "$repo" >/dev/null 2>&1 \
    || echo "  (登録済みか、CLI差異。'claude plugin marketplace list' で確認してください)"
done < <(jq -r '.marketplaces | keys[]' "$JSON")

# --- 2) プラグイン導入 ---
missing=0
while IFS= read -r plugin; do
  while IFS= read -r bin; do
    [ -n "$bin" ] || continue
    if ! command -v "$bin" >/dev/null 2>&1; then
      echo "  ⚠️ $plugin は '$bin' を PATH に必要とします（'make brew' で導入）"
      missing=1
    fi
  done < <(jq -r --arg p "$plugin" '.plugins[$p].requires[]?' "$JSON")

  echo "→ plugin: $plugin"
  claude plugin install "$plugin" -s user >/dev/null 2>&1 \
    || echo "  ⚠️ $plugin は導入済みか失敗。'claude plugin list' で確認してください。"
done < <(jq -r '.plugins | keys[]' "$JSON")

echo ""
if [ "$missing" -eq 1 ]; then
  echo "⚠️ 言語サーバのバイナリが不足しています。'make brew' を実行してください。"
fi
echo "✅ プラグインセットアップ完了。'claude plugin list' で確認してください。"
echo "   反映: Claude Code 内で /reload-plugins（LSP は本体の再起動が必要な場合あり）"
