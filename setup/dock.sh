#!/bin/bash

# Dock configuration using dockutil

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

print_header "Configuring Dock"

# Check if dockutil is installed
if ! command -v dockutil &> /dev/null; then
  print_error "dockutil is not installed. Please install it first: brew install dockutil"
  exit 1
fi

# Remove all items from dock
print_step "Removing all items from dock..."
dockutil --remove all --no-restart
print_success "All items removed from dock"

# Add applications in specific order
print_step "Adding applications to dock..."

# Calendar
if [ -d "/System/Applications/Calendar.app" ]; then
  dockutil --add "/System/Applications/Calendar.app" --no-restart
  print_success "Added Calendar"
else
  print_warning "Calendar.app not found at /System/Applications/Calendar.app"
fi

# Chrome
if [ -d "/Applications/Google Chrome.app" ]; then
  dockutil --add "/Applications/Google Chrome.app" --no-restart
  print_success "Added Chrome"
else
  print_warning "Google Chrome.app not found at /Applications/Google Chrome.app"
fi

# ChatGPT
if [ -d "/Applications/ChatGPT.app" ]; then
  dockutil --add "/Applications/ChatGPT.app" --no-restart
  print_success "Added ChatGPT"
else
  print_warning "ChatGPT.app not found at /Applications/ChatGPT.app"
fi

# AptaKube
if [ -d "/Applications/AptaKube.app" ]; then
  dockutil --add "/Applications/AptaKube.app" --no-restart
  print_success "Added AptaKube"
else
  print_warning "AptaKube.app not found at /Applications/AptaKube.app"
fi

# Cursor
if [ -d "/Applications/Cursor.app" ]; then
  dockutil --add "/Applications/Cursor.app" --no-restart
  print_success "Added Cursor"
else
  print_warning "Cursor.app not found at /Applications/Cursor.app"
fi

# iTerm
if [ -d "/Applications/iTerm.app" ]; then
  dockutil --add "/Applications/iTerm.app" --no-restart
  print_success "Added iTerm"
else
  print_warning "iTerm.app not found at /Applications/iTerm.app"
fi

# Spotify
if [ -d "/Applications/Spotify.app" ]; then
  dockutil --add "/Applications/Spotify.app" --no-restart
  print_success "Added Spotify"
else
  print_warning "Spotify.app not found at /Applications/Spotify.app"
fi

# Slack
if [ -d "/Applications/Slack.app" ]; then
  dockutil --add "/Applications/Slack.app" --no-restart
  print_success "Added Slack"
else
  print_warning "Slack.app not found at /Applications/Slack.app"
fi

# Messages
if [ -d "/System/Applications/Messages.app" ]; then
  dockutil --add "/System/Applications/Messages.app" --no-restart
  print_success "Added Messages"
else
  print_warning "Messages.app not found at /System/Applications/Messages.app"
fi

# Visual Studio Code
if [ -d "/Applications/Visual Studio Code.app" ]; then
  dockutil --add "/Applications/Visual Studio Code.app" --no-restart
  print_success "Added Visual Studio Code"
else
  print_warning "Visual Studio Code.app not found at /Applications/Visual Studio Code.app"
fi

# Obsidian
if [ -d "/Applications/Obsidian.app" ]; then
  dockutil --add "/Applications/Obsidian.app" --no-restart
  print_success "Added Obsidian"
else
  print_warning "Obsidian.app not found at /Applications/Obsidian.app"
fi

# Postman
if [ -d "/Applications/Postman.app" ]; then
  dockutil --add "/Applications/Postman.app" --no-restart
  print_success "Added Postman"
else
  print_warning "Postman.app not found at /Applications/Postman.app"
fi

# Restart dock to apply changes
killall Dock

