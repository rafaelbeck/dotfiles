#!/bin/bash

set -e

source "$HOME/.dotfiles/lib/flags.sh"
parse_flags "$@"

DOTFILES_DIR="$HOME/.dotfiles"
export PATH="/opt/homebrew/bin:$PATH"

log "\n🚀 Setting up your Mac..."

# ---------------------------------------------
# Ensure Xcode CLI Tools are installed
# ---------------------------------------------
if ! xcode-select -p &>/dev/null; then
  echo "🛠️ Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "⏳ Waiting for installation to finish..."
  until xcode-select -p &>/dev/null; do sleep 5; done
  echo "✅ Xcode tools installed."
else
  echo "✅ Xcode Command Line Tools already installed."
fi

# ---------------------------------------------
# Clone or update dotfiles repo
# ---------------------------------------------
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "📥 Cloning dotfiles repository..."
  git clone https://github.com/rafaelbeck/dotfiles.git "$DOTFILES_DIR"
else
  echo "📁 $DOTFILES_DIR already exists."
  if [ "$SKIP_UPDATE" = false ]; then
    if [ "$FORCE" = false ]; then
      read -p "↪️  Is this the correct dotfiles repo? [y/n] " -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Aborting setup."
        exit 1
      fi
    fi
    echo "🔄 Pulling latest changes..."
    git -C "$DOTFILES_DIR" pull
  else
    echo "⏭️  Skipping dotfiles update (--skip-update flag set)"
  fi
fi

# ---------------------------------------------
# Ensure Git uses SSH instead of HTTPS
# ---------------------------------------------
cd "$DOTFILES_DIR"
CURRENT_URL=$(git remote get-url origin)
if [[ "$CURRENT_URL" == https://* ]]; then
  echo "🔐 Git remote is using HTTPS:"
  echo "    $CURRENT_URL"
  echo "➡️  Switching to SSH for push access..."
  SSH_URL="git@github.com:rafaelbeck/dotfiles.git"
  git remote set-url origin "$SSH_URL"
  echo "✅ Remote updated to SSH:"
  git remote -v
else
  echo "✅ Git remote already uses SSH."
fi

# ---------------------------------------------
# Homebrew install (if needed)
# ---------------------------------------------
if command -v brew >/dev/null 2>&1; then
  echo "✅ Homebrew is already installed."
else
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "🩺 Running brew doctor..."
  if ! brew doctor; then
    echo "❌ Fix the issues from 'brew doctor' and rerun the script."
    exit 1
  fi
fi

# ---------------------------------------------
# Install Homebrew packages based on role
# ---------------------------------------------
echo
read -p "📦 Choose setup type — [w] Work, [h] Home, [m] Media Server: " -n 1 setup_type
echo

case "$setup_type" in
  [Ww]) BREWFILE="$DOTFILES_DIR/install/brew/Work" ; LABEL="Work" ;;
  [Hh]) BREWFILE="$DOTFILES_DIR/install/brew/Home" ; LABEL="Home" ;;
  [Mm]) BREWFILE="$DOTFILES_DIR/install/brew/Media" ; LABEL="Media Server" ;;
  *) echo "❌ Invalid option. Exiting." && exit 1 ;;
esac

if [ -f "$BREWFILE" ]; then
  echo "📦 Installing from Brewfile: $BREWFILE"
  run "brew bundle --file=\"$BREWFILE\""
else
  echo "❌ Brewfile not found at $BREWFILE. Skipping."
fi

# ---------------------------------------------
# macOS config
# ---------------------------------------------
echo
read -p "🖥️  Apply macOS system preferences? [y/n] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "⚙️  Applying macOS preferences..."
  run "sudo sh \"$DOTFILES_DIR/macos/defaults-chrome.sh\""
  run "sudo sh \"$DOTFILES_DIR/macos/defaults.sh\""
  run "sudo sh \"$DOTFILES_DIR/macos/dock.sh\""
else
  echo "⏭️  Skipping macOS config."
fi

# ---------------------------------------------
# Git config symlinks
# ---------------------------------------------
ln -sfv "$DOTFILES_DIR/config/git/.gitconfig" ~
ln -sfv "$DOTFILES_DIR/config/git/.gitignore" ~

# ---------------------------------------------
# GitHub SSH Setup
# ---------------------------------------------
echo
read -p "🔐 Would you like to set up SSH access to GitHub now? [y/n] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  SSH_KEY="$HOME/.ssh/id_ed25519"
  if [ ! -f "$SSH_KEY" ]; then
    echo "🔧 Generating a new SSH key..."
    ssh-keygen -t ed25519 -C "$(git config user.email)" -f "$SSH_KEY" -N ""
    echo "📋 Copying public key to clipboard..."
    pbcopy < "$SSH_KEY.pub"
    echo "✅ SSH key generated and copied!"
    echo "👉 Now go to: https://github.com/settings/keys"
    echo "➕ Click 'New SSH Key', paste it in, and save it."
    read -p "⏳ Press Enter after you've added the key to GitHub..."
  else
    echo "✅ SSH key already exists: $SSH_KEY"
  fi

  echo "🔌 Testing GitHub SSH connection..."
  if ssh -T git@github.com 2>&1 | grep -q 'successfully authenticated'; then
    echo "✅ SSH connection to GitHub works!"
  else
    echo "⚠️ SSH connection to GitHub failed."
  fi
else
  echo "⏭️  Skipping SSH key setup."
fi

# ---------------------------------------------
# Extra: Media Server Setup
# ---------------------------------------------
if [[ $setup_type =~ [Mm] ]]; then
  echo "\n🎬 Starting Media Server setup..."

  if [ ! -d "/Users/mediaserver/.dotfiles" ]; then
    echo "📥 Cloning dotfiles for mediaserver user..."
    sudo -iu mediaserver git clone https://github.com/rafaelbeck/dotfiles.git /Users/mediaserver/.dotfiles
  else
    echo "🔁 mediaserver dotfiles already exist."
  fi

  if [ ! -x "$HOME/homebrew/bin/brew" ]; then
    echo "📦 Installing local Homebrew for mediaserver..."
    mkdir -p "$HOME/homebrew"
    cd "$HOME/homebrew"
    git clone https://github.com/Homebrew/brew .brew
    mkdir -p bin && ln -s .brew/bin/brew bin/brew
    echo 'export PATH="$HOME/homebrew/bin:$PATH"' >> "$HOME/.zprofile"
    source "$HOME/.zprofile"
  fi

  export PATH="$HOME/homebrew/bin:$PATH"
  export HOMEBREW_NO_AUTO_UPDATE=1
  export HOMEBREW_CACHE="$HOME/Library/Caches/Homebrew"
  export HOMEBREW_TEMP="$HOME/Library/Caches/Homebrew"
  export HOMEBREW_LOCK_DIR="$HOME/Library/Locks/Homebrew"
  mkdir -p "$HOMEBREW_CACHE" "$HOMEBREW_LOCK_DIR"

  echo "📦 Installing media server Brewfile..."
  run "$HOME/homebrew/bin/brew bundle --file=\"$BREWFILE\" || echo '⚠️ Some installs failed.'"

  if [ -d "$HOME/Applications/Plex Media Server.app" ]; then
    echo "🎛 Launching Plex to initialize..."
    "$HOME/Applications/Plex Media Server.app/Contents/MacOS/Plex Media Server" &
    sleep 10
    killall "Plex Media Server" || true
  fi

  echo
  read -p "💾 Would you like to set up a USB drive for Movies? [y/n] " -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔌 Running USB setup..."
    run "bash \"$DOTFILES_DIR/config/plex/setup-usb-movies.sh\""
  else
    echo "📂 Skipping USB setup."
  fi

  echo "🌐 Configuring LAN sharing..."
  run "bash \"$DOTFILES_DIR/config/plex/configure-media-lan.sh\""

  echo "✅ Media server setup complete."
fi

# ---------------------------------------------
# Final Summary
# ---------------------------------------------
echo "\n✅ Setup complete: $LABEL configuration installed."
if [ "$DRY_RUN" = true ]; then
  echo "🧪 Note: This was a DRY RUN — no real installs occurred."
fi

