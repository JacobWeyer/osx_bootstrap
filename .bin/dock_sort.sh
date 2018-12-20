#!/usr/bin/env bash

# set to the path of dockutil
dockutil="/usr/local/bin/dockutil"

${dockutil} --remove all --no-restart
sleep 2 # we add a delay so that the dock has time to inialize the removal

# Browser
${dockutil} --add /Applications/Google\ Chrome.app --no-restart

# Misc Work stuff
${dockutil} --add /Applications/iTerm.app --no-restart
${dockutil} --add /Applications/Slack.app --no-restart
${dockutil} --add /Applications/Paw.app --no-restart

# Code Editors
${dockutil} --add /Applications/DataGrip.app --no-restart
${dockutil} --add /Applications/GoLand.app --no-restart
${dockutil} --add /Applications/IntelliJ\ IDEA.app --no-restart
${dockutil} --add /Applications/PyCharm.app --no-restart
${dockutil} --add /Applications/PhpStorm.app --no-restart
${dockutil} --add /Applications/RubyMine.app --no-restart
${dockutil} --add /Applications/Webstorm.app --no-restart
${dockutil} --add /Applications/Visual\ Studio\ Code.app --no-restart

# Databases
${dockutil} --add /Applications/Sequel\ Pro.app --no-restart
${dockutil} --add /Applications/Postico.app --no-restart

# Music
${dockutil} --add /Applications/Spotify.app --no-restart

# Messaging
${dockutil} --add /Applications/Messages.app --no-restart

# System Preferences
${dockutil} --add /Applications/System\ Preferences.app