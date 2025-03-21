#!/bin/bash

### ⚙️ CONFIGURATION ###
USB_NAME="MOVIES_USB"                        # Name of your USB stick as it appears in /Volumes
MEDIA_FOLDER="Movies"                        # Folder to hold media
MOUNT_PATH="/Volumes/$USB_NAME"
MEDIA_PATH="$MOUNT_PATH/$MEDIA_FOLDER"
LINK_PATH="$HOME/Movies"

### 🧠 CHECKS ###
if [[ ! -d "$MOUNT_PATH" ]]; then
  echo "❌ USB drive '$USB_NAME' not found in /Volumes. Is it plugged in?"
  exit 1
fi

### 📂 CREATE FOLDER IF NEEDED ###
if [[ ! -d "$MEDIA_PATH" ]]; then
  echo "📁 Creating folder: $MEDIA_PATH"
  mkdir -p "$MEDIA_PATH"
fi

### 🔗 OPTIONAL: Symlink to ~/Movies ###
if [[ ! -L "$LINK_PATH" && ! -d "$LINK_PATH" ]]; then
  echo "🔗 Linking $MEDIA_PATH to $LINK_PATH"
  ln -s "$MEDIA_PATH" "$LINK_PATH"
elif [[ -L "$LINK_PATH" ]]; then
  echo "✅ Link already exists: $LINK_PATH → $(readlink $LINK_PATH)"
else
  echo "⚠️ $LINK_PATH exists and is not a symlink. Skipping link creation."
fi

### 🔐 PERMISSIONS (just in case) ###
echo "🔒 Setting permissions on $MEDIA_PATH"
chmod -R 755 "$MEDIA_PATH"

### 🎬 DONE ###
echo "✅ USB movie folder is ready: $MEDIA_PATH"
echo "🌐 Open Plex and add this path as a library: $MEDIA_PATH"
open "http://localhost:32400/web"
