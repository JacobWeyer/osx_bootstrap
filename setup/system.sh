#!/bin/bash

# System preferences configuration

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

print_header "Configuring System Preferences"

# Show hidden files in Finder
print_step "Showing hidden files in Finder..."
defaults write com.apple.finder AppleShowAllFiles YES
killall Finder 2>/dev/null || true
print_success "Hidden files are now visible in Finder"

echo ""

# Prevent .DS_Store files on network volumes
print_step "Preventing .DS_Store files on network volumes..."
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
print_success ".DS_Store files will not be created on network volumes"

echo ""

# Make ~/Library directory visible
print_step "Making ~/Library directory visible..."
chflags nohidden ~/Library
print_success "~/Library directory is now visible"

echo ""

# Show battery percentage in menu bar
print_step "Enabling battery percentage in menu bar..."
defaults write com.apple.controlcenter BatteryShowPercentage -bool true 2>/dev/null || true
defaults write com.apple.menuextra.battery ShowPercent -string "YES" 2>/dev/null || true
killall SystemUIServer 2>/dev/null || killall ControlCenter 2>/dev/null || true
print_success "Battery percentage enabled in menu bar"

echo ""

# Enable dark mode
print_step "Enabling dark mode..."
defaults write -g AppleInterfaceStyleSwitchesAutomatically -bool false 2>/dev/null || true
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' 2>/dev/null || true
defaults write -g AppleInterfaceStyle -string "Dark" 2>/dev/null || true
print_success "Dark mode enabled"

echo ""

# Configure Raycast
print_step "Configuring Raycast to use ⌘+Space (replacing Spotlight)..."
if [ -d "/Applications/Raycast.app" ]; then
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 -dict \
    enabled -bool false \
    value -dict \
      type -int 0 \
      parameters -int 0 2>/dev/null || true
  
  RAYCAST_PREFS="$HOME/Library/Preferences/com.raycast.macos.plist"
  defaults write com.raycast.macos hotkey -dict \
    keyCode -int 49 \
    modifiers -int 1048840 2>/dev/null || true
  
  if command -v plutil &> /dev/null; then
    plutil -create "$RAYCAST_PREFS" 2>/dev/null || true
    plutil -insert hotkey -dictionary "$RAYCAST_PREFS" 2>/dev/null || true
    plutil -insert hotkey.keyCode -integer 49 "$RAYCAST_PREFS" 2>/dev/null || true
    plutil -insert hotkey.modifiers -integer 1048840 "$RAYCAST_PREFS" 2>/dev/null || true
  fi
  
  killall Raycast 2>/dev/null || true
  print_success "Raycast configured to use ⌘+Space"
  print_info "Spotlight's ⌘+Space hotkey has been disabled"
  
  # Configure Raycast window management with Rectangle preset
  print_step "Configuring Raycast window management with Rectangle preset..."
  RAYCAST_EXTENSIONS_DIR="$HOME/Library/Application Support/Raycast/Extensions"
  WINDOW_MGMT_DIR="$RAYCAST_EXTENSIONS_DIR/window-management"
  
  if [ -d "$WINDOW_MGMT_DIR" ]; then
    defaults write com.raycast.macos windowManagementPreset -string "rectangle" 2>/dev/null || true
    defaults write com.raycast.macos extensions.window-management.enabled -bool true 2>/dev/null || true
    print_success "Raycast window management configured with Rectangle preset"
    print_info "Window management extension enabled - use Raycast commands to manage windows"
  else
    print_info "Window management extension directory not found"
    print_info "You may need to install the Window Management extension from Raycast's store"
    print_info "Then set the preset to 'Rectangle' in Raycast preferences"
  fi
  
  print_info "You may need to open Raycast and confirm settings in its preferences"
else
  print_warning "Raycast is not installed. Skipping configuration."
  print_info "Raycast will be installed from Brewfile. Run this script again or configure manually."
fi

echo ""

