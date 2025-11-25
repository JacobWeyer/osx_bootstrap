#!/bin/bash

# Shell configuration: ZSH plugins

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

print_header "Installing ZSH Plugins"

ZSH_PLUGINS=(
  "1password"
  "argocd"
  "aws"
  "azure"
  "brew"
  "bun"
  "docker"
  "docker-compose"
  "dotenv"
  "gh"
  "git"
  "git-commit"
  "golang"
  "helm"
  "iterm2"
  "jira"
  "kubectl"
  "npm"
  "terraform"
  "zsh-autosuggestions"
  "zsh-syntax-highlighting"
)

EXTERNAL_PLUGINS=(
  "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
  "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
)

ZSHRC_FILE="$HOME/.zshrc"
BACKUP_DIR="$HOME/.config/backup/zshrc"

if [ -f "$ZSHRC_FILE" ]; then
  # Install external plugins
  CUSTOM_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
  mkdir -p "$CUSTOM_PLUGINS_DIR"

  print_step "Checking and installing external plugins..."
  for plugin_info in "${EXTERNAL_PLUGINS[@]}"; do
    IFS=':' read -r plugin_name plugin_url <<< "$plugin_info"
    plugin_path="$CUSTOM_PLUGINS_DIR/$plugin_name"
    
    if [ ! -d "$plugin_path" ]; then
      print_step "Installing $plugin_name..."
      git clone "$plugin_url" "$plugin_path" 2>/dev/null || {
        print_warning "Failed to clone $plugin_name from $plugin_url"
        print_warning "You may need to install it manually."
      }
    else
      print_success "$plugin_name is already installed"
    fi
  done
  echo ""

  # Backup .zshrc
  mkdir -p "$BACKUP_DIR"
  BACKUP_FILE="$BACKUP_DIR/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
  print_step "Creating backup: $BACKUP_FILE"
  cp "$ZSHRC_FILE" "$BACKUP_FILE"

  # Add zsh-autosuggestions configuration if not present
  if ! grep -q "ZSH_AUTOSUGGEST" "$ZSHRC_FILE" 2>/dev/null; then
    print_step "Adding zsh-autosuggestions configuration..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "/^plugins=(/i\\
# Autosuggest settings\\
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=\"fg=#663399,standout\"\\
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=\"20\"\\
ZSH_AUTOSUGGEST_USE_ASYNC=1\\
" "$ZSHRC_FILE"
    else
      sed -i "/^plugins=(/i\\# Autosuggest settings\nZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=\"fg=#663399,standout\"\nZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=\"20\"\nZSH_AUTOSUGGEST_USE_ASYNC=1" "$ZSHRC_FILE"
    fi
    print_success "Added zsh-autosuggestions configuration"
  fi

  # Update plugins array
  if grep -q "^plugins=(" "$ZSHRC_FILE"; then
    print_info "Found existing plugins array in $ZSHRC_FILE"
    
    # Extract existing plugins from multi-line array
    # Get everything between plugins=( and the closing )
    CURRENT_PLUGINS=$(sed -n '/^plugins=(/,/^)/p' "$ZSHRC_FILE" | grep -v "^plugins=(" | grep -v "^)" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | grep -v '^$')
    
    # Convert to array
    EXISTING_PLUGINS=()
    while IFS= read -r plugin; do
      if [[ -n "$plugin" ]]; then
        EXISTING_PLUGINS+=("$plugin")
      fi
    done <<< "$CURRENT_PLUGINS"
    
    ALL_PLUGINS=("${EXISTING_PLUGINS[@]}")
    for plugin in "${ZSH_PLUGINS[@]}"; do
      if [[ ! " ${ALL_PLUGINS[@]} " =~ " ${plugin} " ]]; then
        ALL_PLUGINS+=("$plugin")
      fi
    done
    
    # Create new plugins array (single line format)
    PLUGINS_LINE="plugins=($(IFS=' '; echo "${ALL_PLUGINS[*]}"))"
    
    # Replace the entire multi-line plugins array block
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS sed: delete from plugins=( to the closing ) and replace
      sed -i '' '/^plugins=(/,/^)/c\
'"$PLUGINS_LINE"'
' "$ZSHRC_FILE"
    else
      # Linux sed
      sed -i '/^plugins=(/,/^)/c\'"$PLUGINS_LINE" "$ZSHRC_FILE"
    fi
    
    print_success "Updated existing plugins array with new plugins"
  else
    print_info "No plugins array found. Adding new plugins array..."
    
    if grep -q "^ZSH_THEME=" "$ZSHRC_FILE"; then
      PLUGINS_LINE="plugins=($(IFS=' '; echo "${ZSH_PLUGINS[*]}"))"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^ZSH_THEME=/a\\
$PLUGINS_LINE
" "$ZSHRC_FILE"
      else
        sed -i "/^ZSH_THEME=/a\\$PLUGINS_LINE" "$ZSHRC_FILE"
      fi
    else
      echo "" >> "$ZSHRC_FILE"
      echo "plugins=($(IFS=' '; echo "${ZSH_PLUGINS[*]}"))" >> "$ZSHRC_FILE"
    fi
    
    print_success "Added new plugins array"
  fi

  echo ""
  print_success "Successfully configured the following plugins:"
  for plugin in "${ZSH_PLUGINS[@]}"; do
    printf "  ${GREEN}•${NC} $plugin\n"
  done
  echo ""
  print_info "Backup saved to: $BACKUP_FILE"
else
  print_warning "$ZSHRC_FILE not found. Skipping plugin installation."
fi

echo ""

# Configure Granted (AWS profile management)
print_step "Configuring Granted shell integration..."
if command -v assume &> /dev/null || command -v granted &> /dev/null; then
  if [ -f "$ZSHRC_FILE" ]; then
    # Add Granted initialization if not present
    if ! grep -q "granted" "$ZSHRC_FILE" 2>/dev/null; then
      print_step "Adding Granted initialization to ~/.zshrc..."
      echo "" >> "$ZSHRC_FILE"
      echo "# Granted (AWS profile management)" >> "$ZSHRC_FILE"
      # Granted provides shell completion and the 'assume' command
      # The assume command is typically available after installation
      if command -v assume &> /dev/null; then
        # Add completion if available
        if [ -f "$(brew --prefix)/share/zsh/site-functions/_assume" ] || [ -f "$(brew --prefix)/etc/bash_completion.d/assume" ]; then
          echo "# Granted completion" >> "$ZSHRC_FILE"
          echo "autoload -Uz compinit && compinit" >> "$ZSHRC_FILE"
        fi
      fi
      print_success "Granted initialization added to ~/.zshrc"
      print_info "Run 'granted configure' to set up your AWS profiles"
    else
      print_info "Granted already configured in ~/.zshrc"
    fi
  fi
else
  print_info "Granted not yet installed. It will be available after installation from Brewfile."
  print_info "After installation, run 'granted configure' to set up your AWS profiles"
fi

echo ""

