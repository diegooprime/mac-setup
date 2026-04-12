#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing Homebrew packages..."
if command -v brew &>/dev/null; then
  brew bundle --file="$DOTFILES_DIR/Brewfile"
else
  echo "Homebrew not found. Install it first: https://brew.sh"
  exit 1
fi

echo ""
echo "==> Stowing config files..."

PACKAGES=(aerospace alacritty tmux karabiner nvim git palette sketchybar borders ghostty fastfetch)

for pkg in "${PACKAGES[@]}"; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    echo "  Stowing $pkg..."
    stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$pkg"
  fi
done

echo ""
echo "==> Making scripts executable..."
chmod +x "$HOME/.config/tmux/scripts/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/tmux/scripts/"*.py 2>/dev/null || true
chmod +x "$HOME/.config/sketchybar/sketchybarrc" 2>/dev/null || true
chmod +x "$HOME/.config/sketchybar/plugins/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/palette/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/borders/bordersrc" 2>/dev/null || true

echo ""
echo "==> Generating configs from palette..."
bash "$HOME/.config/palette/generate.sh"

echo ""
echo "==> Starting services..."
brew services start sketchybar 2>/dev/null || true
brew services start borders 2>/dev/null || true

echo ""
echo "==> Installing tmux plugins..."
if [[ -d "$HOME/.config/tmux/plugins/tpm" ]]; then
  "$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
else
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
  "$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
fi

echo ""
echo "Done! Extras (Raycast, Vimium C) must be imported manually from extras/."
