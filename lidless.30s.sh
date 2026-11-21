#!/bin/bash
# Menu bar button for ~/.local/bin/lidless (refreshed every 30 s by SwiftBar).
#
# Shown by SwiftBar in the button's "About" window:
# <xbar.title>lidless</xbar.title>
# <xbar.author>zenud</xbar.author>
# <xbar.author.github>zenud</xbar.author.github>
# <xbar.desc>The eye that never closes. Keeps your Mac awake for a set time, even with the lid shut.</xbar.desc>
# <xbar.abouturl>https://zenud.github.io/lidless/</xbar.abouturl>
LIDLESS="$HOME/.local/bin/lidless"
STATE=/var/db/lidless

# Click on a menu entry: SwiftBar runs this script again with an argument.
[ -n "$1" ] && exec "$LIDLESS" "$1"

read -r end < "$STATE" 2>/dev/null
if [[ "$end" =~ ^[0-9]{1,10}$ ]] && [ "$end" -gt "$(date +%s)" ]; then
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
