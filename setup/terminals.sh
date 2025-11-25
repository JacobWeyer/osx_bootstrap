#!/bin/bash

# Terminal font configuration

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

FONT_NAME="Maple Mono NF"

# Configure iTerm2 font
print_step "Configuring iTerm2 to use $FONT_NAME font..."
if fc-list | grep -qi "maple.*mono" || system_profiler SPFontsDataType 2>/dev/null | grep -qi "maple.*mono"; then
  if [ -d "/Applications/iTerm.app" ]; then
    defaults write com.googlecode.iterm2 "Normal Font" -string "$FONT_NAME"
    defaults write com.googlecode.iterm2 "Non Ascii Font" -string "$FONT_NAME"
    defaults write com.googlecode.iterm2 "Normal Font Size" -float 13
    print_success "iTerm2 configured to use $FONT_NAME"
    print_info "You may need to restart iTerm2 for changes to take effect"
  else
    print_warning "iTerm2 not found. Skipping iTerm2 font configuration."
  fi
else
  print_warning "$FONT_NAME font not found. Please install it first: brew install --cask font-maple-mono-nf"
fi

echo ""

# Configure Cursor terminal and editor font
print_step "Configuring Cursor terminal and editor to use $FONT_NAME font..."
CURSOR_SETTINGS_DIR="$HOME/Library/Application Support/Cursor/User"
CURSOR_SETTINGS_FILE="$CURSOR_SETTINGS_DIR/settings.json"

if fc-list | grep -qi "maple.*mono" || system_profiler SPFontsDataType 2>/dev/null | grep -qi "maple.*mono"; then
  if [ -d "$CURSOR_SETTINGS_DIR" ]; then
    if [ ! -f "$CURSOR_SETTINGS_FILE" ]; then
      mkdir -p "$CURSOR_SETTINGS_DIR"
      echo "{}" > "$CURSOR_SETTINGS_FILE"
    fi
    
    if command -v jq &> /dev/null; then
      jq '. + {
        "terminal.integrated.fontFamily": "Maple Mono NF",
        "terminal.integrated.fontSize": 13,
        "editor.fontFamily": "Maple Mono NF",
        "editor.fontSize": 12
      }' "$CURSOR_SETTINGS_FILE" > "$CURSOR_SETTINGS_FILE.tmp" && mv "$CURSOR_SETTINGS_FILE.tmp" "$CURSOR_SETTINGS_FILE"
      print_success "Cursor terminal and editor configured to use Maple Mono NF"
    else
      if ! grep -q "terminal.integrated.fontFamily" "$CURSOR_SETTINGS_FILE" 2>/dev/null || ! grep -q "editor.fontFamily" "$CURSOR_SETTINGS_FILE" 2>/dev/null; then
        python3 -c "
import json
import sys
try:
    with open('$CURSOR_SETTINGS_FILE', 'r') as f:
        settings = json.load(f)
except:
    settings = {}
settings['terminal.integrated.fontFamily'] = 'Maple Mono NF'
settings['terminal.integrated.fontSize'] = 13
settings['editor.fontFamily'] = 'Maple Mono NF'
settings['editor.fontSize'] = 12
with open('$CURSOR_SETTINGS_FILE', 'w') as f:
    json.dump(settings, f, indent=2)
" 2>/dev/null && print_success "Cursor terminal and editor configured to use Maple Mono NF" || \
          print_warning "Could not configure Cursor settings. jq or Python3 required."
      fi
      print_info "You may need to restart Cursor for changes to take effect"
    fi
  else
    print_warning "Cursor settings directory not found. Skipping Cursor font configuration."
  fi
else
  print_warning "$FONT_NAME font not found. Please install it first: brew install --cask font-maple-mono-nf"
fi

echo ""

