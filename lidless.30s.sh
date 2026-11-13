#!/bin/bash
# Menu bar button for ~/.local/bin/lidless (refreshed every 30 s by SwiftBar).
LIDLESS="$HOME/.local/bin/lidless"
STATE=/var/run/lidless

# Click on a menu entry: SwiftBar runs this script again with an argument.
# macOS shows its administrator password dialog, then lidless runs in the background.
if [ -n "$1" ]; then
  [[ "$1" =~ ^([1-9][0-9]*(h|m)|stop)$ ]] || exit 1
  osascript -e "do shell script \"$LIDLESS $1 >/dev/null 2>&1 &\" with administrator privileges"
  exit
fi

if [ -f "$STATE" ] && read -r pid end < "$STATE" && ps -p "$pid" >/dev/null 2>&1; then
  echo "$(date -r "$end" '+%H:%M') | sfimage=eye"
  echo "---"
  echo "Awake until $(date -r "$end" '+%H:%M')"
  echo "Stop | bash='$0' param1=stop terminal=false refresh=true"
  echo "---"
  echo "Restart for…"
else
  echo "| sfimage=moon.zzz"
  echo "---"
  echo "Keep the Mac awake for…"
fi
for d in 30m 1h 2h 4h 8h; do
  echo "$d | bash='$0' param1=$d terminal=false refresh=true"
done
