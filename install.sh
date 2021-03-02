#!/bin/sh

set -e

DOTFILES_DIR=~/.dotfiles

echo "Setting up your Mac..."
echo

if ! hash gcc 2>/dev/null; then
    echo "----------> You must install Xcode command-line tools first to proceed. Finishing..."
    exit
fi

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "----------> Downloading repository..."
    echo
    git clone https://github.com/rafaelbeck/dotfiles.git $DOTFILES_DIR
else
    echo "----------> $DOTFILES_DIR is already present."
    read -p "Are you sure the directory $DOTFILES_DIR contains this repository? [y/n] " -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "----------> No need to clone. Checking for updates..."
        git -C $DOTFILES_DIR pull
    else
        exit
    fi
fi

echo

if hash brew 2>/dev/null; then
    echo "----------> Homebrew is already installed, skipping..."
else
    echo "----------> Installing Homebrew..."
    echo
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    echo
    brew doctor

    if [ $? -ne 0 ]; then
      echo "You need to fix the warnings/errors thrown by brew doctor. Then run the script again."
      exit
    fi
fi

echo
read -p "----------> Would you like to install default Homebrew formulas and Casks? [y/n] " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo
  echo "----------> Installing Homebrew formulas and casks..."
  echo

  brew tap homebrew/bundle

  echo
  read -p "----------> Is this a work computer? [y/n] " -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
      brew bundle --verbose --file=$DOTFILES_DIR/install/brew/Work
  else
      brew bundle --verbose --file=$DOTFILES_DIR/install/brew/Home
  fi

else
  echo "----------> Skipping Homebrew formulas and casks..."
fi

if hash code 2>/dev/null; then
  echo
  read -p "----------> Would you like to change macOS config? [y/n] " -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "----------> Changing macOS settings..."
    echo
    sudo sh -c 'sh $DOTFILES_DIR/macos/defaults-chrome.sh'
    sudo sh -c 'sh $DOTFILES_DIR/macos/defaults.sh'
    sudo sh -c 'sh $DOTFILES_DIR/macos/dock.sh'
  else
    echo "----------> Skipping macOS config..."
  fi
fi


# git symlinks
ln -sfv "$DOTFILES_DIR/config/git/.gitconfig" ~
ln -sfv "$DOTFILES_DIR/config/git/.gitignore" ~

# Set macOS preferences
# We will run this last because this will reload the shell
source ~/.zshrc

echo
echo
echo "----------> Provisioning process complete."
