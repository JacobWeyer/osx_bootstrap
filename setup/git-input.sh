#!/bin/bash

# Prompt for Git configuration (only if not already set)

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

print_header "Git Configuration"

# Check if git user.name and user.email are already configured
EXISTING_GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
EXISTING_GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
EXISTING_GIT_USERNAME=$(git config --global user.username 2>/dev/null || echo "")

if [ -n "$EXISTING_GIT_NAME" ] && [ -n "$EXISTING_GIT_EMAIL" ]; then
  print_info "Git user configuration already exists:"
  printf "  ${BOLD}Name:${NC} $EXISTING_GIT_NAME\n"
  printf "  ${BOLD}Email:${NC} $EXISTING_GIT_EMAIL\n"
  if [ -n "$EXISTING_GIT_USERNAME" ]; then
    printf "  ${BOLD}Username:${NC} $EXISTING_GIT_USERNAME\n"
  fi
  echo ""
  print_info "Using existing Git configuration (not overwriting)"
  GIT_USERNAME="$EXISTING_GIT_NAME"
  GIT_EMAIL="$EXISTING_GIT_EMAIL"
  if [ -n "$EXISTING_GIT_USERNAME" ]; then
    GIT_USER_USERNAME="$EXISTING_GIT_USERNAME"
  fi
else
  # Use values from repositories.conf if available, otherwise prompt
  if [ -z "$EXISTING_GIT_NAME" ]; then
    if [ -n "$GIT_USERNAME" ]; then
      print_info "Using Git username from configuration: $GIT_USERNAME"
    else
      read -p "$(printf "${CYAN}Git username [Jacob Weyer]:${NC} ")" GIT_USERNAME
      GIT_USERNAME=${GIT_USERNAME:-Jacob Weyer}
    fi
  else
    GIT_USERNAME="$EXISTING_GIT_NAME"
    print_info "Using existing Git username: $GIT_USERNAME"
  fi

  if [ -z "$EXISTING_GIT_EMAIL" ]; then
    if [ -n "$GIT_EMAIL" ]; then
      print_info "Using Git email from configuration: $GIT_EMAIL"
    else
      read -p "$(printf "${CYAN}Git email [jacobweyer@gmail.com]:${NC} ")" GIT_EMAIL
      GIT_EMAIL=${GIT_EMAIL:-jacobweyer@gmail.com}
    fi
  else
    GIT_EMAIL="$EXISTING_GIT_EMAIL"
    print_info "Using existing Git email: $GIT_EMAIL"
  fi

  # Handle username (optional)
  if [ -z "$EXISTING_GIT_USERNAME" ]; then
    if [ -n "$GIT_USER_USERNAME" ]; then
      print_info "Using Git user.username from configuration: $GIT_USER_USERNAME"
    else
      # Extract username from email if not provided
      if [ -z "$GIT_USER_USERNAME" ] && [ -n "$GIT_EMAIL" ]; then
        GIT_USER_USERNAME=$(echo "$GIT_EMAIL" | cut -d'@' -f1)
        print_info "Derived Git username from email: $GIT_USER_USERNAME"
      fi
    fi
  else
    GIT_USER_USERNAME="$EXISTING_GIT_USERNAME"
  fi

  echo ""
  print_info "Git will be configured with:"
  printf "  ${BOLD}Name:${NC} $GIT_USERNAME\n"
  printf "  ${BOLD}Email:${NC} $GIT_EMAIL\n"
  if [ -n "$GIT_USER_USERNAME" ]; then
    printf "  ${BOLD}Username:${NC} $GIT_USER_USERNAME\n"
  fi
  echo ""
fi

# Export for use in other scripts
export GIT_USERNAME
export GIT_EMAIL
if [ -n "$GIT_USER_USERNAME" ]; then
  export GIT_USER_USERNAME
fi

