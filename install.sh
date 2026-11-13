#!/bin/bash
# Installs the lidless command and its menu bar button (SwiftBar).
#   ./install.sh              command + button
#   ./install.sh --no-button  command only
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
  plugins="$HOME/Library/Application Support/SwiftBar/Plugins"
  defaults write com.ameba.SwiftBar PluginDirectory "$plugins"
fi
mkdir -p "$plugins"
install -m 755 lidless.30s.sh "$plugins/lidless.30s.sh"
echo "Button installed: $plugins/lidless.30s.sh"

open /Applications/SwiftBar.app
open -g "swiftbar://refreshallplugins"
echo "Done: a moon icon shows up in the menu bar."
