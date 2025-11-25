#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Color functions
print_header() {
  printf "${CYAN}${BOLD}==========================================${NC}\n"
  printf "${CYAN}${BOLD}$1${NC}\n"
  printf "${CYAN}${BOLD}==========================================${NC}\n"
  echo ""
}

print_success() {
  printf "${GREEN}✓${NC} $1\n"
}

print_warning() {
  printf "${YELLOW}⚠${NC} $1\n"
}

print_error() {
  printf "${RED}✗${NC} $1\n"
}

print_info() {
  printf "${BLUE}ℹ${NC} $1\n"
}

print_step() {
  printf "${CYAN}➜${NC} $1\n"
}

