#!/usr/bin/env bash
# Claude Code → Windows トースト通知
# Usage: notify.sh "タイトル" "メッセージ"
# hookからはstdinでJSONが渡される。引数がなければJSONからイベント名を抽出する。

title="${1:-Claude Code}"
message="${2:-}"

if [ -z "$message" ]; then
  json=$(cat)
  event=$(echo "$json" | jq -r '.hook_event_name // empty' 2>/dev/null)
  case "$event" in
    Stop)           message="応答が完了しました" ;;
    Notification)   message="入力を待っています" ;;
    SubagentStop)
      agent=$(echo "$json" | jq -r '.agent_type // "エージェント"' 2>/dev/null)
      message="${agent} が完了しました" ;;
    *)              message="${event:-通知}" ;;
  esac
fi

powershell.exe -NoProfile -Command "
  [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
  [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null
  \$xml = [Windows.Data.Xml.Dom.XmlDocument]::new()
  \$xml.LoadXml('<toast><visual><binding template=\"ToastText02\"><text id=\"1\">$title</text><text id=\"2\">$message</text></binding></visual></toast>')
  \$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code')
  \$notifier.Show([Windows.UI.Notifications.ToastNotification]::new(\$xml))
" >/dev/null 2>&1 &

exit 0
