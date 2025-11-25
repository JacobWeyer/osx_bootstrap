#!/bin/bash

# Initial setup: directories, SSH agent, starship configuration

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

print_header "macOS Development Environment Setup"

# Get bootstrap directory (parent of setup/) if not already set
BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export BOOTSTRAP_DIR

# Create necessary directories and files
print_step "Setting up directories and files..."
if [ ! -d "$HOME/.bin/" ]; then
  mkdir -p "$HOME/.bin"
  print_success "Created ~/.bin directory"
fi

if [ ! -f "$HOME/.zshrc" ]; then
  touch "$HOME/.zshrc"
  print_success "Created ~/.zshrc file"
fi

# Start SSH agent early
print_step "Starting SSH agent..."
# Check if SSH agent is already running
if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l &>/dev/null; then
  eval "$(ssh-agent -s)" > /dev/null
  export SSH_AUTH_SOCK
  export SSH_AGENT_PID
  print_success "SSH agent started"
else
  print_info "SSH agent already running"
fi

# Ensure .config directory and copy starship.toml
print_step "Setting up configuration directory..."
mkdir -p ~/.config
mkdir -p ~/.config/backup/zshrc
mkdir -p ~/.config/backup/starship

STARSHIP_SOURCE="$BOOTSTRAP_DIR/starship.toml"
STARSHIP_TARGET="$HOME/.config/starship.toml"
STARSHIP_BACKUP_DIR="$HOME/.config/backup/starship"

if [ -f "$STARSHIP_SOURCE" ]; then
  if [ -f "$STARSHIP_TARGET" ]; then
    BACKUP_FILE="$STARSHIP_BACKUP_DIR/starship.toml.backup.$(date +%Y%m%d_%H%M%S)"
    print_step "Backing up existing starship.toml to $BACKUP_FILE"
    cp "$STARSHIP_TARGET" "$BACKUP_FILE"
  fi
  
  print_step "Copying starship.toml from bootstrap directory..."
  cp "$STARSHIP_SOURCE" "$STARSHIP_TARGET"
  print_success "starship.toml copied to ~/.config"
else
  print_warning "starship.toml not found in bootstrap directory ($STARSHIP_SOURCE)"
  print_info "Creating empty starship.toml file instead"
  touch "$STARSHIP_TARGET"
fi

echo ""
