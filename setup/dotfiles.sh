#!/bin/bash

# Dotfiles installation and symlinking

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

print_header "Installing Dotfiles"

DOTFILES_SOURCE="$BOOTSTRAP_DIR/dotfiles"
DOTFILES_TARGET="$HOME/.config/dotfiles"

# Create .config/dotfiles directory
if [ ! -d "$DOTFILES_TARGET" ]; then
  print_step "Creating ~/.config/dotfiles directory..."
  mkdir -p "$DOTFILES_TARGET"
  print_success "Created ~/.config/dotfiles directory"
fi

# Copy dotfiles to ~/.config/dotfiles (including hidden files)
print_step "Copying dotfiles to ~/.config/dotfiles..."
# Enable dotglob to match hidden files
shopt -s dotglob
cp -r "$DOTFILES_SOURCE"/* "$DOTFILES_TARGET/" 2>/dev/null || {
  print_warning "Some files may not have been copied"
}
shopt -u dotglob
print_success "Dotfiles copied to ~/.config/dotfiles"

# Make all dotfiles executable
chmod +x "$DOTFILES_TARGET"/*

# Symlink .gitconfig
if [ -f "$DOTFILES_TARGET/.gitconfig" ]; then
  if [ ! -f "$HOME/.gitconfig" ] || [ -L "$HOME/.gitconfig" ]; then
    print_step "Symlinking .gitconfig..."
    ln -sf "$DOTFILES_TARGET/.gitconfig" "$HOME/.gitconfig"
    print_success ".gitconfig symlinked"
  else
    print_warning ".gitconfig already exists and is not a symlink. Skipping."
  fi
fi

# Symlink .tmux.conf
if [ -f "$DOTFILES_TARGET/.tmux.conf" ]; then
  if [ ! -f "$HOME/.tmux.conf" ] || [ -L "$HOME/.tmux.conf" ]; then
    print_step "Symlinking .tmux.conf..."
    ln -sf "$DOTFILES_TARGET/.tmux.conf" "$HOME/.tmux.conf"
    print_success ".tmux.conf symlinked"
  else
    print_warning ".tmux.conf already exists and is not a symlink. Skipping."
  fi
fi

# Symlink Docker config
if [ -f "$DOTFILES_TARGET/.docker/config.json" ]; then
  mkdir -p "$HOME/.docker"
  if [ ! -f "$HOME/.docker/config.json" ] || [ -L "$HOME/.docker/config.json" ]; then
    print_step "Symlinking Docker config..."
    ln -sf "$DOTFILES_TARGET/.docker/config.json" "$HOME/.docker/config.json"
    print_success "Docker config symlinked"
  else
    print_warning ".docker/config.json already exists and is not a symlink. Skipping."
  fi
fi

# Add source to .zshrc (as second to last line, before starship)
if [ -f "$HOME/.zshrc" ]; then
  DOTFILES_SOURCE_LINE="[ -f \"\$HOME/.config/dotfiles/.dotfiles\" ] && source \"\$HOME/.config/dotfiles/.dotfiles\""
  STARSHIP_LINE="eval \"\$(starship init zsh)\""
  
  print_step "Configuring ~/.zshrc with dotfiles and starship..."
  
  # Remove any existing dotfiles source lines
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' '/\.config\/dotfiles\/\.dotfiles/d' "$HOME/.zshrc"
    sed -i '' '/Source dotfiles/d' "$HOME/.zshrc"
    sed -i '' '/starship init zsh/d' "$HOME/.zshrc"
  else
    sed -i '/\.config\/dotfiles\/\.dotfiles/d' "$HOME/.zshrc"
    sed -i '/Source dotfiles/d' "$HOME/.zshrc"
    sed -i '/starship init zsh/d' "$HOME/.zshrc"
  fi
  
  # Add dotfiles source and starship at the end
  echo "" >> "$HOME/.zshrc"
  echo "# Source dotfiles" >> "$HOME/.zshrc"
  echo "$DOTFILES_SOURCE_LINE" >> "$HOME/.zshrc"
  echo "$STARSHIP_LINE" >> "$HOME/.zshrc"
  
  print_success "Configured ~/.zshrc: dotfiles (second to last) and starship (last)"
fi

# Add source to .bashrc
if [ -f "$HOME/.bashrc" ]; then
  DOTFILES_SOURCE_LINE="[ -f \"\$HOME/.config/dotfiles/.dotfiles\" ] && source \"\$HOME/.config/dotfiles/.dotfiles\""
  if ! grep -Fqs "$DOTFILES_SOURCE_LINE" "$HOME/.bashrc"; then
    print_step "Adding dotfiles source to ~/.bashrc..."
    echo "" >> "$HOME/.bashrc"
    echo "# Source dotfiles" >> "$HOME/.bashrc"
    echo "$DOTFILES_SOURCE_LINE" >> "$HOME/.bashrc"
    print_success "Added dotfiles source to ~/.bashrc"
  else
    print_info "Dotfiles already sourced in ~/.bashrc"
  fi
fi

# Add source to .bash_profile (for macOS)
if [ -f "$HOME/.bash_profile" ]; then
  DOTFILES_SOURCE_LINE="[ -f \"\$HOME/.config/dotfiles/.dotfiles\" ] && source \"\$HOME/.config/dotfiles/.dotfiles\""
  if ! grep -Fqs "$DOTFILES_SOURCE_LINE" "$HOME/.bash_profile"; then
    print_step "Adding dotfiles source to ~/.bash_profile..."
    echo "" >> "$HOME/.bash_profile"
    echo "# Source dotfiles" >> "$HOME/.bash_profile"
    echo "$DOTFILES_SOURCE_LINE" >> "$HOME/.bash_profile"
    print_success "Added dotfiles source to ~/.bash_profile"
  else
    print_info "Dotfiles already sourced in ~/.bash_profile"
  fi
fi

echo ""

