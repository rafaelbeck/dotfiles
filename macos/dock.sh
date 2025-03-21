#!/bin/sh
dockutil="/usr/local/bin/dockutil"

dockutil --remove all --no-restart
dockutil --add "/Applications/Google Chrome.app" --no-restart
#dockutil --no-restart --add "/Applications/BraveBrowser.app"
dockutil --add "/Applications/Proton Mail.app" --no-restart
dockutil --add "/Applications/Figma.app" --no-restart
#dockutil --no-restart --add "/Applications/Atom.app"
#dockutil --no-restart --add "/Applications/Visual Studio Code.app"
#dockutil --no-restart --add "/Applications/iTerm.app"
dockutil --no-restart --add "/Applications/Slack.app"
#dockutil --no-restart --add "/Applications/Spotify.app"

killall Dock
