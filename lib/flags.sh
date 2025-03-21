#!/bin/bash

# Default flag values
DRY_RUN=false
VERBOSE=false
SKIP_UPDATE=false
FORCE=false

print_flag_help() {
  echo "\n📖 Available Flags:"
  echo "  --dry-run       : Simulate actions without applying changes"
  echo "  --verbose       : Show detailed output during execution"
  echo "  --skip-update   : Skip dotfiles repo update check"
  echo "  --force         : Skip confirmations where possible"
  echo "  --help          : Show this help menu"
  echo
}

parse_flags() {
  for arg in "$@"; do
    case $arg in
      --dry-run) DRY_RUN=true ;;
      --verbose) VERBOSE=true ;;
      --skip-update) SKIP_UPDATE=true ;;
      --force) FORCE=true ;;
      --help) print_flag_help; exit 0 ;;
      *) echo "❌ Unknown option: $arg"; print_flag_help; exit 1 ;;
    esac
  done
}

run() {
  if [ "$DRY_RUN" = true ]; then
    echo "🧪 DRY RUN: $*"
  else
    [ "$VERBOSE" = true ] && echo "▶️ $*"
    eval "$@"
  fi
}

log() {
  [ "$VERBOSE" = true ] && echo "$@"
}
