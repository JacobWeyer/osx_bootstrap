#!/usr/bin/env bash

###############################################################################
# General UI/UX                                                               #
###############################################################################

#"Disabling OS X Gate Keeper"
#"(You'll be able to install any app you want from here on, not just Mac App Store apps)"
sudo spctl --master-disable
sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Expand "Save" and "Print" panels.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Use current directory as default search scope in Finder.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Show extensions in Finder.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path in Finder.
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Allow selecting text in Quick Look.
defaults write com.apple.finder QLEnableTextSelection -bool true

# Use OSX print dialog in Chrome.
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true

# Copy email addresses, not names, from Mail.
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Quit Printer app when complete.
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Ignore Quarantine of unknown apps.
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Open Finder at "~/" directory.
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Unhide "~/Library" folder.
chflags nohidden ~/Library

#"Setting Dock to not hide"
defaults write com.apple.dock autohide -bool false

#"Disable the sudden motion sensor as its not useful for SSDs"
sudo pmset -a sms 0

#"Speeding up wake from sleep to 24 hours from an hour"
# http://www.cultofmac.com/221392/quick-hack-speeds-up-retina-macbooks-wake-from-sleep-os-x-tips/
sudo pmset -a standbydelay 86400

#"Setting screenshots location to ~/Desktop"
defaults write com.apple.screencapture location -string "$HOME/Desktop"

#"Setting screenshot format to PNG"
defaults write com.apple.screencapture type -string "png"

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

###############################################################################
# SSD-specific tweaks                                                         #
###############################################################################

# Disable hibernation (speeds up entering sleep mode)
sudo pmset -a hibernatemode 0

# Remove the sleep image file to save disk space
sudo rm /private/var/vm/sleepimage
# Create a zero-byte file instead…
sudo touch /private/var/vm/sleepimage
# …and make sure it can’t be rewritten
sudo chflags uchg /private/var/vm/sleepimage

# Kill affected apps
for app in "Dock" "Finder"; do
  killall "${app}" > /dev/null 2>&1
done