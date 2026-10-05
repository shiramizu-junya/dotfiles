#!/bin/sh
# ============================================================
# Claude Code の入力待ちを tmux で見落とさないための補助スクリプト
#   notify : macOS 通知を出し、待っているウィンドウに印を付ける（Claude Code の Notification/Stop フック）
#   clear  : 印を消す（Claude Code の UserPromptSubmit フック）
#   jump   : 印の付いたウィンドウへ移動する（tmux の prefix + a）
#   count  : 印の付いたウィンドウ数を表示する（tmux の status-right）
# 印は tmux のウィンドウオプション @claude_waiting で管理する
# ============================================================

cmd="$1"
pane="${TMUX_PANE:-}"

case "$cmd" in
notify)
  input=$(cat)
  msg=$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)
  [ -z "$msg" ] && msg="応答が完了しました"
  where=""
  if [ -n "$pane" ]; then
    target=$(tmux display-message -p -t "$pane" '#{session_name}:#{window_index}')
    where="$target $(tmux display-message -p -t "$pane" '#{window_name}')"
    # 直近に操作したクライアントが見ているウィンドウには印を付けない
    viewing=$(tmux list-clients -F '#{client_activity} #{session_name}:#{window_index}' | sort -rn | awk 'NR==1{print $2}')
    [ "$viewing" != "$target" ] && tmux set-option -w -t "$pane" @claude_waiting 1
  fi
  osascript -e 'on run argv' \
    -e 'display notification (item 1 of argv) with title "Claude Code" subtitle (item 2 of argv)' \
    -e 'end run' "$msg" "$where" >/dev/null 2>&1
  ;;
clear)
  cat >/dev/null
  [ -n "$pane" ] && tmux set-option -wu -t "$pane" @claude_waiting
  ;;
jump)
  current=$(tmux display-message -p '#{session_name}:#{window_index}')
  waiting=$(tmux list-windows -a -F '#{@claude_waiting} #{session_name}:#{window_index}' | awk '$1==1{print $2}')
  # 今いるウィンドウ以外を優先し、連打で順に巡回できるようにする
  next=$(printf '%s\n' "$waiting" | grep -vxF "$current" | head -n 1)
  [ -z "$next" ] && next=$(printf '%s\n' "$waiting" | head -n 1)
  if [ -n "$next" ]; then
    tmux switch-client -t "$next"
  else
    tmux display-message "入力待ちの Claude Code はありません"
  fi
  ;;
count)
  n=$(tmux list-windows -a -F '#{@claude_waiting}' | grep -c '^1$')
  [ "$n" -gt 0 ] && printf '#[fg=colour196,bold]● Claude待ち %s #[default]' "$n"
  ;;
esac
exit 0
