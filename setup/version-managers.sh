#!/bin/bash

# Version manager configuration: nvm, goenv, tfenv, uv

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

print_header "Configuring Version Managers"

# Configure nvm (Node.js)
print_step "Configuring nvm (Node.js)..."
if [ -f "$(brew --prefix nvm)/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
  
  # Add nvm to .zshrc if not present
  if ! grep -q "NVM_DIR" "$HOME/.zshrc" 2>/dev/null; then
    echo "" >> "$HOME/.zshrc"
    echo "# nvm" >> "$HOME/.zshrc"
    echo "export NVM_DIR=\"\$HOME/.nvm\"" >> "$HOME/.zshrc"
    echo "[ -s \"\$(brew --prefix nvm)/nvm.sh\" ] && \\. \"\$(brew --prefix nvm)/nvm.sh\"" >> "$HOME/.zshrc"
  fi
  
  # Install latest LTS Node.js
  print_step "Installing Node.js LTS..."
  nvm install --lts 2>/dev/null || print_warning "Node.js LTS installation may have failed"
  nvm alias default lts/* 2>/dev/null || true
  nvm use default 2>/dev/null || true
  print_success "Node.js LTS configured"
else
  print_warning "nvm not found. It will be installed from Brewfile."
fi

echo ""

# Configure goenv (Go)
print_step "Configuring goenv (Go)..."
if command -v goenv &> /dev/null || [ -f "$(brew --prefix goenv)/bin/goenv" ]; then
  # Set up goenv PATH if needed
  if [ -f "$(brew --prefix goenv)/bin/goenv" ]; then
    export PATH="$(brew --prefix goenv)/bin:$PATH"
  fi
  
  # Add goenv to .zshrc if not present
  if ! grep -q "goenv init" "$HOME/.zshrc" 2>/dev/null; then
    echo "" >> "$HOME/.zshrc"
    echo "# goenv" >> "$HOME/.zshrc"
    if [ -f "$(brew --prefix goenv)/bin/goenv" ]; then
      echo "export PATH=\"\$(brew --prefix goenv)/bin:\$PATH\"" >> "$HOME/.zshrc"
    fi
    echo 'eval "$(goenv init -)"' >> "$HOME/.zshrc"
  fi
  
  # Initialize goenv in current shell
  eval "$(goenv init -)" 2>/dev/null || true
  
  # Check current global version
  GO_CURRENT_GLOBAL=$(goenv global 2>/dev/null | tr -d '[:space:]' || echo "")
  
  if [ -n "$GO_CURRENT_GLOBAL" ] && [ "$GO_CURRENT_GLOBAL" != "system" ]; then
    print_info "Global Go version is already set to: $GO_CURRENT_GLOBAL"
    # Check if the global version is actually installed
    if goenv versions --bare | grep -q "^$GO_CURRENT_GLOBAL$"; then
      print_success "Go $GO_CURRENT_GLOBAL is installed and set as global"
    else
      print_warning "Global version $GO_CURRENT_GLOBAL is set but not installed. Installing..."
      if goenv install "$GO_CURRENT_GLOBAL" 2>&1; then
        print_success "Go $GO_CURRENT_GLOBAL installed"
      else
        print_warning "Failed to install $GO_CURRENT_GLOBAL. You may need to install build dependencies."
      fi
    fi
  else
    # No global version set, install and set latest stable
    print_step "Installing latest Go version and setting as global..."
    
    # Try to get the latest version - goenv install --list outputs versions with various formats
    # Filter for stable versions (x.y.z format, not beta/rc/alpha)
    GO_LATEST=$(goenv install --list 2>/dev/null | \
      grep -E '^\s+[0-9]+\.[0-9]+\.[0-9]+$' | \
      grep -v -E '(beta|rc|alpha|dev|pre)' | \
      tail -1 | \
      tr -d '[:space:]' || echo "")
    
    # If that didn't work, try a simpler approach - get the last version from the list (excluding pre-releases)
    if [ -z "$GO_LATEST" ]; then
      GO_LATEST=$(goenv install --list 2>/dev/null | \
        grep -E '^\s+[0-9]+\.[0-9]+\.[0-9]+' | \
        grep -v -E '(beta|rc|alpha|dev|pre)' | \
        tail -1 | \
        awk '{print $1}' | \
        tr -d '[:space:]' || echo "")
    fi
    
    # If still no version, try fetching from go.dev
    if [ -z "$GO_LATEST" ]; then
      GO_LATEST=$(curl -s https://go.dev/VERSION?m=text 2>/dev/null | sed 's/^go//' || echo "")
    fi
    
    if [ -n "$GO_LATEST" ]; then
      print_info "Installing Go version: $GO_LATEST"
      if goenv install "$GO_LATEST" 2>&1; then
        goenv global "$GO_LATEST" 2>/dev/null || true
        print_success "Go $GO_LATEST installed and set as global"
      else
        print_warning "Go installation failed. You may need to install build dependencies."
        print_info "On macOS, you may need: xcode-select --install"
      fi
    else
      print_warning "Could not determine latest Go version. You can install manually with: goenv install <version> && goenv global <version>"
    fi
  fi
else
  print_warning "goenv not found. It will be installed from Brewfile."
fi

echo ""

# Configure tfenv (Terraform)
print_step "Configuring tfenv (Terraform)..."
if command -v tfenv &> /dev/null; then
  # Install latest stable Terraform version (exclude alpha, beta, rc versions)
  print_step "Installing latest stable Terraform version..."
  # Filter out versions with alpha, beta, or rc suffixes
  TF_LATEST=$(tfenv list-remote 2>/dev/null | \
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | \
    grep -v -E '(alpha|beta|rc|dev|pre)' | \
    head -1 | \
    tr -d '[:space:]')
  
  if [ -z "$TF_LATEST" ]; then
    # Fallback: try to get the first version that looks like a stable release
    TF_LATEST=$(tfenv list-remote 2>/dev/null | \
      grep -E '^[0-9]+\.[0-9]+\.[0-9]+' | \
      grep -v -E '(alpha|beta|rc|dev|pre)' | \
      head -1 | \
      awk '{print $1}' | \
      tr -d '[:space:]')
  fi
  
  if [ -n "$TF_LATEST" ]; then
    print_info "Installing Terraform version: $TF_LATEST"
    tfenv install "$TF_LATEST" 2>/dev/null || print_warning "Terraform installation may have failed"
    tfenv use "$TF_LATEST" 2>/dev/null || true
    print_success "Terraform $TF_LATEST installed"
  else
    print_warning "Could not determine latest stable Terraform version"
  fi
else
  print_warning "tfenv not found. It will be installed from Brewfile."
fi

echo ""

# Configure uv (Python)
print_step "Configuring uv (Python)..."
if command -v uv &> /dev/null; then
  # Install latest Python LTS (3.12 or latest 3.x)
  print_step "Installing latest Python LTS..."
  PYTHON_VERSION="3.12"
  uv python install "$PYTHON_VERSION" 2>/dev/null || {
    # Try to get the latest available
    PYTHON_VERSION=$(uv python list 2>/dev/null | grep -E '^\s+3\.[0-9]+\.[0-9]+' | head -1 | awk '{print $1}' || echo "3.12")
    uv python install "$PYTHON_VERSION" 2>/dev/null || print_warning "Python installation may have failed"
  }
  print_success "Python $PYTHON_VERSION installed via uv"
else
  print_warning "uv not found. It will be installed from Brewfile."
fi

echo ""

print_info "Version managers configured. Restart your shell or run 'source ~/.zshrc' to use them."
echo ""

