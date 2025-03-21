#!/bin/bash

USERNAME="mediaserver"
FULLNAME="Media Server"
GROUPID="20"
HOMEDIR="/Users/$USERNAME"
USER_SHELL="/bin/bash"

# Automatically find an unused UID starting from 501
NEXT_UID=$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | awk '$1>=501' | tail -n 1)
USERID=$((NEXT_UID + 1))

# Check if user already exists
if id "$USERNAME" &>/dev/null; then
  echo "⚠️  User '$USERNAME' already exists. Skipping creation."
else
  echo "🛠️ Creating new user: $USERNAME"

  read -s -p "Enter password for '$USERNAME': " PASSWORD
  echo
  read -s -p "Confirm password: " PASSWORD_CONFIRM
  echo

  if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
    echo "❌ Passwords do not match. Aborting."
    exit 1
  fi

  # Create the user
  sudo dscl . -create /Users/$USERNAME
  sudo dscl . -create /Users/$USERNAME UserShell "$USER_SHELL"
  sudo dscl . -create /Users/$USERNAME RealName "$FULLNAME"
  sudo dscl . -create /Users/$USERNAME UniqueID "$USERID"
  sudo dscl . -create /Users/$USERNAME PrimaryGroupID "$GROUPID"
  sudo dscl . -create /Users/$USERNAME NFSHomeDirectory "$HOMEDIR"
  sudo dscl . -passwd /Users/$USERNAME "$PASSWORD"
fi

# Make sure home directory exists
if [ ! -d "$HOMEDIR" ]; then
  echo "📂 Creating home directory for $USERNAME..."
  sudo createhomedir -c -u "$USERNAME" > /dev/null
fi

# Fix permissions
sudo chown -R "$USERNAME:staff" "$HOMEDIR"

# Refresh directory cache
dscacheutil -flushcache

echo "✅ User '$USERNAME' is ready."
