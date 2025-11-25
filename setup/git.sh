#!/bin/bash

# Git configuration

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

print_header "Configuring Git"

# Check if user.name, user.email, and user.username are already set
EXISTING_GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
EXISTING_GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
EXISTING_GIT_USERNAME=$(git config --global user.username 2>/dev/null || echo "")

# Only set user.name and user.email if they're not already configured
if [ -z "$EXISTING_GIT_NAME" ]; then
  git config --global user.name "$GIT_USERNAME"
  print_info "Set Git user.name to: $GIT_USERNAME"
else
  print_info "Git user.name already set to: $EXISTING_GIT_NAME (not overwriting)"
fi

if [ -z "$EXISTING_GIT_EMAIL" ]; then
  git config --global user.email "$GIT_EMAIL"
  print_info "Set Git user.email to: $GIT_EMAIL"
else
  print_info "Git user.email already set to: $EXISTING_GIT_EMAIL (not overwriting)"
fi

# Set user.username if provided and not already configured
if [ -z "$EXISTING_GIT_USERNAME" ] && [ -n "$GIT_USER_USERNAME" ]; then
  git config --global user.username "$GIT_USER_USERNAME"
  print_info "Set Git user.username to: $GIT_USER_USERNAME"
elif [ -n "$EXISTING_GIT_USERNAME" ]; then
  print_info "Git user.username already set to: $EXISTING_GIT_USERNAME (not overwriting)"
fi

# Set other git configurations (these can be overwritten)
git config --global init.defaultBranch main
git config --global color.ui auto
git config --global core.pager "diff-so-fancy | less --tabs=4 -RF"
git config --global interactive.diffFilter "diff-so-fancy --patch"
git config --global push.autoSetupRemote true

echo ""
print_success "Git configured:"
printf "  ${BOLD}Default branch:${NC} main\n"
if [ -n "$EXISTING_GIT_NAME" ]; then
  printf "  ${BOLD}User name:${NC} $EXISTING_GIT_NAME (existing)\n"
else
  printf "  ${BOLD}User name:${NC} $GIT_USERNAME\n"
fi
if [ -n "$EXISTING_GIT_EMAIL" ]; then
  printf "  ${BOLD}User email:${NC} $EXISTING_GIT_EMAIL (existing)\n"
else
  printf "  ${BOLD}User email:${NC} $GIT_EMAIL\n"
fi
if [ -n "$EXISTING_GIT_USERNAME" ]; then
  printf "  ${BOLD}User username:${NC} $EXISTING_GIT_USERNAME (existing)\n"
elif [ -n "$GIT_USER_USERNAME" ]; then
  printf "  ${BOLD}User username:${NC} $GIT_USER_USERNAME\n"
fi
printf "  ${BOLD}Color UI:${NC} auto\n"
printf "  ${BOLD}Core pager:${NC} diff-so-fancy\n"
printf "  ${BOLD}Interactive diff filter:${NC} diff-so-fancy --patch\n"
printf "  ${BOLD}Auto setup remote:${NC} true\n"
echo ""

