#!/bin/bash

# SSH configuration for GitHub

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

print_header "Configuring SSH for GitHub"

# Create .ssh directory
print_step "Setting up SSH directory..."
mkdir -p ~/.ssh
print_success "SSH directory ready"

# Generate SSH key for GitHub
GITHUB_KEY="$HOME/.ssh/github"
if [ ! -f "$GITHUB_KEY" ]; then
  print_step "Generating SSH key for GitHub..."
  ssh-keygen -t ed25519 -C "github" -f "$GITHUB_KEY" -N ""
  print_success "SSH key generated: $GITHUB_KEY"
else
  print_success "SSH key already exists: $GITHUB_KEY"
fi

# Configure SSH config file
SSH_CONFIG="$HOME/.ssh/config"
print_step "Configuring SSH config file..."

if [ ! -f "$SSH_CONFIG" ]; then
  touch "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
fi

if ! grep -q "^Host \*" "$SSH_CONFIG"; then
  cat >> "$SSH_CONFIG" << 'EOF'

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/github
EOF
  print_success "Added SSH config for Host *"
else
  if ! grep -A 10 "^Host \*" "$SSH_CONFIG" | grep -q "AddKeysToAgent yes" || \
     ! grep -A 10 "^Host \*" "$SSH_CONFIG" | grep -q "UseKeychain yes" || \
     ! grep -A 10 "^Host \*" "$SSH_CONFIG" | grep -q "IdentityFile ~/.ssh/github"; then
    sed -i '' '/^Host \*/a\
  AddKeysToAgent yes\
  UseKeychain yes\
  IdentityFile ~/.ssh/github
' "$SSH_CONFIG"
    print_success "Updated SSH config with required settings"
  else
    print_info "SSH config already contains required settings"
  fi
fi

# Add key to keychain
print_step "Adding SSH key to keychain..."
if ssh-add --apple-use-keychain ~/.ssh/github 2>/dev/null; then
  print_success "SSH key added to keychain"
else
  print_warning "Could not add SSH key to keychain (may already be added)"
fi

echo ""

# Authenticate with GitHub CLI
print_step "Authenticating with GitHub CLI..."
if command -v gh &> /dev/null; then
  if gh auth status &>/dev/null; then
    print_success "GitHub CLI is already authenticated"
  else
    print_info "Please follow the prompts to authenticate with GitHub..."
    gh auth login
    if gh auth status &>/dev/null; then
      print_success "GitHub CLI authentication successful"
    else
      print_warning "GitHub CLI authentication may have been cancelled or failed"
    fi
  fi
else
  print_warning "GitHub CLI (gh) is not installed. Skipping authentication."
  print_info "GitHub CLI will be installed from Brewfile. You can run 'gh auth login' manually afterwards."
fi

echo ""

