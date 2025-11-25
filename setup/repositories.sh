#!/bin/bash

# Clone repositories from GitHub organizations

# Initialize if running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Running as script (not sourced)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
  export BOOTSTRAP_DIR
  source "$BOOTSTRAP_DIR/lib/colors.sh"
fi

print_header "Cloning GitHub Repositories"

# Load configuration from config file if it exists
# Check both config/ directory and root directory
CONFIG_FILE=""
if [ -f "${BOOTSTRAP_DIR}/config/repositories.conf" ]; then
  CONFIG_FILE="${BOOTSTRAP_DIR}/config/repositories.conf"
elif [ -f "${BOOTSTRAP_DIR}/repositories.conf" ]; then
  CONFIG_FILE="${BOOTSTRAP_DIR}/repositories.conf"
fi

if [ -n "$CONFIG_FILE" ]; then
  print_info "Loading configuration from $CONFIG_FILE"
  # Source the config file directly (it uses bash-compatible syntax)
  # This allows variable expansion and proper quoting
  set +e  # Temporarily disable exit on error for config loading
  source "$CONFIG_FILE" 2>/dev/null
  set -e  # Re-enable exit on error
else
  print_info "No configuration file found. Looking for repositories.conf in:"
  print_info "  - ${BOOTSTRAP_DIR}/config/repositories.conf"
  print_info "  - ${BOOTSTRAP_DIR}/repositories.conf"
  print_info "Using default values. Copy repositories.conf.example to one of the above locations to customize."
fi

# Set default values if not configured
GITHUB_ORG="${GITHUB_ORG:-}"
GIT_USER_NAME="${GIT_USER_NAME:-}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-}"
GIT_USER_USERNAME="${GIT_USER_USERNAME:-}"
CUTOFF_DATE="${CUTOFF_DATE:-2024-01-01T00:00:00Z}"
SSH_KEY_PATH="${SSH_KEY_PATH:-~/.ssh/github}"

# Expand ~ in SSH_KEY_PATH
SSH_KEY_PATH="${SSH_KEY_PATH/#\~/$HOME}"

# Determine target directory
if [ -z "$REPOSITORIES_DIR" ]; then
  # Default to $HOME/Projects if not set
  REPOSITORIES_DIR="$HOME/Projects"
fi
# Expand ~ in REPOSITORIES_DIR
REPOSITORIES_DIR="${REPOSITORIES_DIR/#\~/$HOME}"

print_info "Configuration:"
print_info "  Organization: $GITHUB_ORG"
print_info "  Target directory: $REPOSITORIES_DIR"
print_info "  Cutoff date: $CUTOFF_DATE"
print_info "  SSH key: $SSH_KEY_PATH"

# Ensure SSH agent is running and key is loaded
print_step "Setting up SSH agent and key..."
# Check if SSH agent is already running
if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l &>/dev/null; then
  eval "$(ssh-agent -s)" > /dev/null 2>&1
  export SSH_AUTH_SOCK
  export SSH_AGENT_PID
  print_info "Started SSH agent"
fi

# Load SSH key if it exists and isn't already loaded
if [ -f "$SSH_KEY_PATH" ]; then
  SSH_KEY_NAME=$(basename "$SSH_KEY_PATH")
  if ! ssh-add -l 2>/dev/null | grep -q "$SSH_KEY_NAME"; then
    if ssh-add --apple-use-keychain "$SSH_KEY_PATH" 2>/dev/null; then
      print_success "SSH key loaded from keychain"
    elif ssh-add "$SSH_KEY_PATH" 2>/dev/null; then
      print_success "SSH key loaded"
    else
      print_warning "Could not load SSH key (may require passphrase)"
    fi
  else
    print_info "SSH key already loaded"
  fi
else
  print_warning "SSH key not found at $SSH_KEY_PATH"
fi

# Check if organization is configured
if [ -z "$GITHUB_ORG" ]; then
  print_warning "GITHUB_ORG is not configured. Skipping repository cloning."
  if [ -n "$CONFIG_FILE" ]; then
    print_info "Set GITHUB_ORG in $CONFIG_FILE to clone repositories from a GitHub organization."
  else
    print_info "Create repositories.conf and set GITHUB_ORG to clone repositories from a GitHub organization."
  fi
  echo ""
  return 0 2>/dev/null || exit 0
fi

# Clone repositories from configured organization
print_step "Cloning $GITHUB_ORG organization repositories..."

mkdir -p "$REPOSITORIES_DIR"

if command -v gh &> /dev/null; then
  # Check if user is authenticated
  if gh auth status &> /dev/null; then
    print_step "Fetching repositories from $GITHUB_ORG organization (updated after $CUTOFF_DATE)..."
    
    # Get list of repositories from the organization that have been pushed to after the cutoff date
    # Using pushedAt field to check for code changes
    # ISO 8601 dates can be compared as strings
    print_info "Filtering repositories updated after: $CUTOFF_DATE"
    
    # Try to fetch repositories and capture any errors
    REPOS_OUTPUT=$(gh repo list "$GITHUB_ORG" --limit 1000 --json nameWithOwner,pushedAt 2>&1)
    REPOS_EXIT_CODE=$?
    
    if [ $REPOS_EXIT_CODE -ne 0 ]; then
      print_error "Failed to fetch repository list from $GITHUB_ORG organization"
      printf "${RED}Exit code: $REPOS_EXIT_CODE${NC}\n"
      printf "${RED}Error output:${NC}\n"
      echo "$REPOS_OUTPUT"
      print_info "Make sure you have access to the $GITHUB_ORG organization"
    else
      # Check if jq is available
      JQ_EXIT_CODE=0
      if ! command -v jq &> /dev/null; then
        print_error "jq is required but not installed. Install it with: brew install jq"
        print_warning "Skipping repository filtering"
        REPOS=""
      else
        REPOS=$(echo "$REPOS_OUTPUT" | jq -r ".[] | select(.pushedAt != null and .pushedAt >= \"$CUTOFF_DATE\") | .nameWithOwner" 2>&1)
        JQ_EXIT_CODE=$?
        
        if [ $JQ_EXIT_CODE -ne 0 ]; then
          print_error "Failed to parse repository list with jq"
          printf "${RED}jq error output:${NC}\n"
          echo "$REPOS"
          REPOS=""
        fi
      fi
      
      if [ -n "$REPOS" ] && [ "$REPOS" != "null" ] && [ "$JQ_EXIT_CODE" -eq 0 ]; then
        REPO_COUNT=$(echo "$REPOS" | wc -l | tr -d ' ')
        print_info "Found $REPO_COUNT repositories in $GITHUB_ORG organization updated after $CUTOFF_DATE"
        
        cd "$REPOSITORIES_DIR"
        
        # Display SAML SSO message once before cloning starts
        echo ""
        printf "${YELLOW}════════════════════════════════════════════════════════════════${NC}\n"
        printf "${YELLOW}⚠️  SAML SSO Authorization Required${NC}\n"
        printf "${YELLOW}════════════════════════════════════════════════════════════════${NC}\n"
        printf "${YELLOW}The '$GITHUB_ORG' organization has enabled or enforced SAML SSO.${NC}\n"
        printf "${YELLOW}To access this repository, you must use the HTTPS remote with a personal${NC}\n"
        printf "${YELLOW}access token or SSH with an SSH key and passphrase that has been${NC}\n"
        printf "${YELLOW}authorized for this organization.${NC}\n"
        printf "${YELLOW}Visit https://docs.github.com/articles/authenticating-to-a-github-organization-with-saml-single-sign-on/ for more information.${NC}\n"
        printf "${YELLOW}════════════════════════════════════════════════════════════════${NC}\n"
        echo ""
        
        CLONED_COUNT=0
        FAILED_COUNT=0
        
        for repo in $REPOS; do
          REPO_NAME=$(echo "$repo" | cut -d'/' -f2)
          REPO_PATH="$REPOSITORIES_DIR/$REPO_NAME"
          
          if [ -d "$REPO_PATH" ]; then
            print_info "Repository $REPO_NAME already exists, skipping..."
          else
            print_step "Cloning $repo via SSH..."
            # Use git clone with SSH URL directly to use SSH key
            # This bypasses gh's HTTPS default and uses SSH authentication
            set +e  # Don't exit on error
            CLONE_OUTPUT=$(git clone "git@github.com:$repo.git" "$REPO_PATH" 2>&1)
            CLONE_EXIT_CODE=$?
            set -e  # Re-enable exit on error
            
            if [ $CLONE_EXIT_CODE -eq 0 ]; then
              # Configure git user in the cloned repository if provided
              if [ -n "$GIT_USER_NAME" ] || [ -n "$GIT_USER_EMAIL" ] || [ -n "$GIT_USER_USERNAME" ]; then
                cd "$REPO_PATH"
                if [ -n "$GIT_USER_NAME" ]; then
                  git config user.name "$GIT_USER_NAME"
                fi
                if [ -n "$GIT_USER_EMAIL" ]; then
                  git config user.email "$GIT_USER_EMAIL"
                fi
                if [ -n "$GIT_USER_USERNAME" ]; then
                  git config user.username "$GIT_USER_USERNAME"
                fi
                cd "$REPOSITORIES_DIR"
              fi
              print_success "Cloned $REPO_NAME"
              CLONED_COUNT=$((CLONED_COUNT + 1))
            else
              print_warning "Failed to clone $repo"
              echo ""
              printf "${RED}════════════════════════════════════════${NC}\n"
              printf "${RED}Exit code: $CLONE_EXIT_CODE${NC}\n"
              printf "${RED}Repository: $repo${NC}\n"
              printf "${RED}Error output:${NC}\n"
              echo "$CLONE_OUTPUT"
              printf "${RED}════════════════════════════════════════${NC}\n"
              echo ""
              FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
          fi
        done
        
        echo ""
        print_success "Repository cloning complete: $CLONED_COUNT cloned, $FAILED_COUNT failed"
      else
        print_warning "No repositories found in $GITHUB_ORG organization updated after $CUTOFF_DATE"
        print_info "Make sure you have access to the $GITHUB_ORG organization"
      fi
    fi
  else
    print_warning "GitHub CLI not authenticated. Run 'gh auth login' first."
    print_info "Skipping repository cloning"
  fi
else
  print_warning "GitHub CLI (gh) not found. It will be installed from Brewfile."
  print_info "Skipping repository cloning"
fi

echo ""

