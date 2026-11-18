#!/bin/bash
# Installs the lidless command, its service (launchd) and its menu bar button (SwiftBar).
#   ./install.sh              command + service + button
#   ./install.sh --no-button  command + service only
set -e
cd "$(dirname "$0")"

mkdir -p "$HOME/.local/bin"
install -m 755 lidless "$HOME/.local/bin/lidless"
echo "Command installed: ~/.local/bin/lidless"
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) echo "Warning: ~/.local/bin is not in your PATH. Add this line to ~/.zshrc:"
     echo '  export PATH="$HOME/.local/bin:$PATH"' ;;
esac

# The service runs as root, so its copy of the script lives in a root-only
# folder: the one in ~/.local/bin could be edited by anyone logged in as you.
label=io.github.zenud.lidless
echo "Installing the service (asks for your password, this one time)."
root="set -e
  cd '$PWD'
  install -d -o root -g wheel -m 755 /Library/PrivilegedHelperTools
  install -o root -g wheel -m 755 lidless /Library/PrivilegedHelperTools/lidless
  install -o root -g wheel -m 644 $label.plist /Library/LaunchDaemons/$label.plist
  [ -f /var/db/lidless ] || echo 0 > /var/db/lidless
  chmod 666 /var/db/lidless
  launchctl bootout system/$label 2>/dev/null || true
  while launchctl print system/$label >/dev/null 2>&1; do sleep 1; done
  launchctl bootstrap system /Library/LaunchDaemons/$label.plist"
if [ -t 0 ]; then
  sudo sh -c "$root"
else
  # No terminal to type the password in: use the macOS password dialog instead.
  osascript -e "do shell script \"$root\" with administrator privileges"
fi
echo "Service installed: $label"

[ "$1" = --no-button ] && exit 0

if [ ! -d /Applications/SwiftBar.app ]; then
  if ! command -v brew >/dev/null; then
    echo "Homebrew is missing: install SwiftBar from https://swiftbar.app then run ./install.sh again" >&2
    exit 1
  fi
  brew install --cask swiftbar
fi

plugins="$(defaults read com.ameba.SwiftBar PluginDirectory 2>/dev/null || true)"
if [ -z "$plugins" ]; then
  # Not ~/Library/Application Support/SwiftBar: SwiftBar keeps its own data there,
  # in folders named after each plugin, and then mistakes them for broken plugins.
  plugins="$HOME/.swiftbar"
  defaults write com.ameba.SwiftBar PluginDirectory "$plugins"
fi
mkdir -p "$plugins"
install -m 755 lidless.30s.sh "$plugins/lidless.30s.sh"
echo "Button installed: $plugins/lidless.30s.sh"

# So the button is back after every restart (macOS may ask to allow this once).
osascript -e 'tell application "System Events" to if not (exists login item "SwiftBar") then make login item at end with properties {path:"/Applications/SwiftBar.app", hidden:true}' >/dev/null 2>&1 \
  || echo "Could not add SwiftBar to your login items: click the button, then SwiftBar, and turn on Launch at Login."

open /Applications/SwiftBar.app
open -g "swiftbar://refreshallplugins"
echo "Done: a moon icon shows up in the menu bar."
