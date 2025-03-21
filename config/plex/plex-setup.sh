#!/bin/bash

### CONFIGURATION ###
PLEX_APP="/Applications/Plex Media Server.app"
PLEX_BIN="$PLEX_APP/Contents/MacOS/Plex Media Server"
PLEX_SUPPORT_DIR="$HOME/Library/Application Support/Plex Media Server"
PLEX_LOG_DIR="$HOME/Library/Logs/Plex Media Server"

# Optional: Set claim token via environment or here
PLEX_CLAIM_TOKEN="${PLEX_CLAIM:-}"

### FUNCTIONS ###

function launch_plex_first_time() {
  echo "🚀 Launching Plex to generate config files..."
  open -a "Plex Media Server"
  sleep 10
  echo "🛑 Stopping Plex after initial config..."
  killall "Plex Media Server"
}

function inject_claim_token() {
  if [[ -n "$PLEX_CLAIM_TOKEN" ]]; then
    echo "🔐 Injecting claim token..."
    PLEX_CLAIM="$PLEX_CLAIM_TOKEN" "$PLEX_BIN" &
    sleep 10
    killall "Plex Media Server"
  else
    echo "⚠️ No claim token set. Skipping server claim. You can set one via export PLEX_CLAIM=..."
  fi
}

function configure_preferences() {
  echo "🔧 Applying basic preference tweaks..."

  PREFS_FILE="$PLEX_SUPPORT_DIR/Preferences.xml"

  if [[ -f "$PREFS_FILE" ]]; then
    # Example: Enable verbose logging
    /usr/libexec/PlistBuddy -c "Set :LogVerbose 1" "$PREFS_FILE" 2>/dev/null || true

    # Example: Disable DLNA
    /usr/libexec/PlistBuddy -c "Add :DlnaEnabled bool false" "$PREFS_FILE" 2>/dev/null || true

    echo "✅ Preferences updated."
  else
    echo "⚠️ Preferences file not found. Was Plex launched at least once?"
  fi
}

function launch_plex_final() {
  echo "🎬 Starting Plex Media Server..."
  open -a "Plex Media Server"
  echo "🌐 Once it's running, open: http://localhost:32400/web"
}

### RUN SETUP STEPS ###
launch_plex_first_time
inject_claim_token
configure_preferences
launch_plex_final
