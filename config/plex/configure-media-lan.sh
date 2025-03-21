#!/bin/bash

# -------------------------
# CONFIGURATION
# -------------------------
MEDIA_USER="mediaserver"
MEDIA_FOLDER="/Volumes/MOVIES_USB/Movies"
SHARE_NAME="Rafi-MEDIASERVER"

# -------------------------
# 1. Enable SMB File Sharing
# -------------------------
echo "📡 Enabling SMB file sharing..."
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.smbd.plist 2>/dev/null || true
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server SharingEnabled -bool true

# -------------------------
# 2. Share the Media Folder
# -------------------------
if [[ -d "$MEDIA_FOLDER" ]]; then
  echo "📁 Sharing $MEDIA_FOLDER as '$SHARE_NAME'..."
  sudo sharing -a "$MEDIA_FOLDER" -S "$SHARE_NAME" -s 100
else
  echo "⚠️ Folder $MEDIA_FOLDER does not exist. Please make sure the USB is mounted."
  exit 1
fi

# -------------------------
# 3. Grant SMB Access to Media User
# -------------------------
echo "👤 Granting SMB access to '$MEDIA_USER'..."
sudo dscl . -append /Groups/com.apple.access_smb GroupMembership "$MEDIA_USER"

# -------------------------
# 4. Get LAN IP and Hostname
# -------------------------
LAN_IP=$(ipconfig getifaddr en0)
HOSTNAME=$(scutil --get LocalHostName)
MAC_ADDR=$(ifconfig en0 | awk '/ether/{print $2}')

# -------------------------
# 5. Confirm the Share Exists
# -------------------------
echo
echo "🔍 Checking if share was created..."
sharing -l | grep "$SHARE_NAME" > /dev/null
if [[ $? -eq 0 ]]; then
  echo "✅ SMB share '$SHARE_NAME' is active."
else
  echo "❌ SMB share was not found. Something went wrong."
  exit 1
fi

# -------------------------
# 6. Final Info for Infuse Setup
# -------------------------
echo
echo "🚀 Your Mac mini media server is now ready to use with Infuse!"
echo "---------------------------------------------------------------"
echo "📺 Infuse Settings:"
echo "• Protocol:     SMB"
echo "• Address:      $LAN_IP or ${HOSTNAME}.local"
echo "• Share Name:   $SHARE_NAME"
echo "• Username:     $MEDIA_USER"
echo "• Password:     (the one you set earlier)"
echo
echo "🌐 Test in Finder: ⌘K → smb://${LAN_IP}/${SHARE_NAME}"
echo "🔗 Plex Web:       http://${LAN_IP}:32400/web"
echo "---------------------------------------------------------------"
