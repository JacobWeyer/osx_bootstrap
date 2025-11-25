#!/bin/bash

# Core tools installation: Homebrew, ZSH, Oh My Zsh

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

print_header "Installing Core Tools"

# Install Homebrew
if command -v brew &> /dev/null; then
  print_success "Homebrew is already installed"
  brew --version | head -n 1
else
  print_step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for Apple Silicon Macs
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  
  # Add Homebrew to PATH for Intel Macs
  if [[ -f "/usr/local/bin/brew" ]]; then
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  
  print_success "Homebrew installed successfully"
fi

echo ""

# Install ZSH
if command -v zsh &> /dev/null; then
  print_success "ZSH is already installed"
  zsh --version
else
  print_step "Installing ZSH via Homebrew..."
  brew install zsh
  
  if ! grep -q "$(which zsh)" /etc/shells; then
    print_step "Adding ZSH to /etc/shells (requires sudo)..."
    echo "$(which zsh)" | sudo tee -a /etc/shells
  fi
  
  print_success "ZSH installed successfully"
fi

echo ""

# Install Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
  print_success "Oh My Zsh is already installed"
else
  print_step "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  print_success "Oh My Zsh installed successfully"
fi

echo ""

