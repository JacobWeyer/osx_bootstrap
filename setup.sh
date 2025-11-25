#!/bin/bash

################################################################################
# macOS Development Environment Setup Script
# 
# This script sets up a complete development environment on macOS including:
# - Homebrew package manager
# - ZSH shell with Oh My Zsh
# - Development tools and applications
# - Git and SSH configuration
# - System preferences
# - Terminal and font configuration
#
# This script is idempotent - it can be run multiple times safely
#
# Usage:
#   ./setup.sh              # Run full setup
#   ./setup.sh --repositories-only  # Only clone repositories
################################################################################

set -e

# Parse command line arguments
REPOSITORIES_ONLY=false
if [[ "$1" == "--repositories-only" ]] || [[ "$1" == "-r" ]]; then
  REPOSITORIES_ONLY=true
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BOOTSTRAP_DIR="$SCRIPT_DIR"

# Source color functions
source "$SCRIPT_DIR/lib/colors.sh"

# If repositories-only flag is set, skip to repositories
if [ "$REPOSITORIES_ONLY" = true ]; then
  source "$SCRIPT_DIR/setup/repositories.sh"
  exit 0
fi

# Source all setup scripts in order
source "$SCRIPT_DIR/setup/initial.sh"
source "$SCRIPT_DIR/setup/git-input.sh"
source "$SCRIPT_DIR/setup/core-tools.sh"
source "$SCRIPT_DIR/setup/packages.sh"
source "$SCRIPT_DIR/setup/version-managers.sh"
source "$SCRIPT_DIR/setup/shell.sh"
source "$SCRIPT_DIR/setup/dotfiles.sh"
source "$SCRIPT_DIR/setup/git.sh"
source "$SCRIPT_DIR/setup/ssh.sh"
# Note: repositories.sh is only run with --repositories-only flag
source "$SCRIPT_DIR/setup/system.sh"
source "$SCRIPT_DIR/setup/terminals.sh"
source "$SCRIPT_DIR/setup/dock.sh"

################################################################################
# Completion
################################################################################

print_header "Installation complete!"
echo ""

# Change default shell to zsh
ZSH_PATH=$(which zsh)
if [ -n "$ZSH_PATH" ]; then
  print_step "Setting ZSH as default shell..."
  if [ "$SHELL" != "$ZSH_PATH" ]; then
    chsh -s "$ZSH_PATH"
    print_success "Default shell changed to ZSH"
    print_info "Please restart your terminal or run 'exec zsh' to start using ZSH"
  else
    print_info "ZSH is already your default shell"
  fi
else
  print_warning "ZSH not found in PATH. Please install ZSH first."
fi

echo ""
