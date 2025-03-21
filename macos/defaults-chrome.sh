#!/bin/bash

DRY_RUN=false

# Parse optional flag
while [[ "$1" =~ ^- ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    *) echo "❌ Unknown option: $1"; exit 1 ;;
  esac
  shift
done

echo "🌐 Applying Google Chrome preferences..."

run_defaults() {
  if [ "$DRY_RUN" = true ]; then
    echo "🧪 DRY RUN: defaults write $@"
  else
    defaults write "$@"
  fi
}

# Enable expanded print dialog by default
run_defaults com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
run_defaults com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

# Optional (uncomment to use):
# run_defaults com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
# run_defaults com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false
# run_defaults com.google.Chrome DisablePrintPreview -bool true
# run_defaults com.google.Chrome.canary DisablePrintPreview -bool true

echo "✅ Chrome defaults applied."
