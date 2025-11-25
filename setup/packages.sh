#!/bin/bash

# Package installation from Brewfile

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

# Use BOOTSTRAP_DIR if set, otherwise calculate it
BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export BOOTSTRAP_DIR

BREWFILE_PATH="$BOOTSTRAP_DIR/Brewfile"
if [ -f "$BREWFILE_PATH" ]; then
  print_header "Installing packages from Brewfile"
  print_step "Updating Homebrew formulae..."
  brew update --force # https://github.com/Homebrew/brew/issues/1151
  echo ""
  print_step "Running: brew bundle install --file=\"$BREWFILE_PATH\""
  brew bundle install --file="$BREWFILE_PATH"
  echo ""
  print_success "Brewfile installation complete"
  
  # Launch Raycast if it was installed
  if [ -d "/Applications/Raycast.app" ]; then
    print_step "Launching Raycast..."
    open -a Raycast
    print_success "Raycast launched"
  fi
else
  print_warning "Brewfile not found at $BREWFILE_PATH"
  print_warning "Skipping brew bundle install"
fi

echo ""

