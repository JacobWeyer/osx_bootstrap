#!/usr/bin/env bash

set -e

################################################################################
# VARIABLE DECLARATIONS
################################################################################
export COMMANDLINE_TOOLS="/Library/Developer/CommandLineTools"
export DICTIONARY_DIR=$HOME/Library/Spelling
export BOOTSTRAP_REPO_URL="https://github.com/joshukraine/mac-bootstrap.git"

DEFAULT_COMPUTER_NAME="Jacob's Mac"
DEFAULT_HOST_NAME="jacobs-mac"
DEFAULT_TIME_ZONE="America/Kentucky/Louisville"

################################################################################
# Check for presence of command line tools if macOS
################################################################################

if [ ! -d "$COMMANDLINE_TOOLS" ]; then
  echo "Apple's command line developer tools must be installed before
running this script. To install them, just run 'xcode-select --install' from
the terminal and then follow the prompts. Once the command line tools have been
installed, you can try running this script again."
  xcode-select --install
  exit 1
fi

################################################################################
# Authenticate
################################################################################

sudo -v

# Keep-alive: update existing `sudo` time stamp until bootstrap has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

################################################################################
# Welcome and setup
################################################################################

echo
echo "*************************************************************************"
echo "*******                                                           *******"
echo "*******                 Lets Get Started!!                        *******"
echo "*******                                                           *******"
echo "*************************************************************************"
echo

printf "Before we get started, let's get some info about your setup.\\n"

printf "\\nEnter a name for your Mac. (Leave blank for default: %s)\\n" "$DEFAULT_COMPUTER_NAME"
read -r -p "> " COMPUTER_NAME
export COMPUTER_NAME=${COMPUTER_NAME:-$DEFAULT_COMPUTER_NAME}

printf "\\nEnter a host name for your Mac. (Leave blank for default: %s)\\n" "$DEFAULT_HOST_NAME"
read -r -p "> " HOST_NAME
export HOST_NAME=${HOST_NAME:-$DEFAULT_HOST_NAME}

printf "\\nEnter your desired time zone.
To view available options run \`sudo systemsetup -listtimezones\`
(Leave blank for default: %s)\\n" "$DEFAULT_TIME_ZONE"
read -r -p "> " TIME_ZONE
export TIME_ZONE=${TIME_ZONE:-$DEFAULT_TIME_ZONE}

printf "\\nLooks good. Here's what we've got.\\n"
printf "Computer name:    ==> [%s]\\n" "$COMPUTER_NAME"
printf "Host name:        ==> [%s]\\n" "$HOST_NAME"
printf "Time zone:        ==> [%s]\\n" "$TIME_ZONE"

echo
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
  echo "Exiting..."
  exit 1
fi

################################################################################
# Creating Default Files/Directories
################################################################################

if [ ! -f "$HOME/.bash_profile" ]; then
  touch .bash_profile
fi

if [ ! -d "$HOME/.bin/" ]; then
  mkdir -p "$HOME/.bin"
fi

if [ ! -d "$HOME/Projects" ]; then
  mkdir -p "~/Projects"
fi

if [ ! -d "$HOME/OpenSource" ]; then
  mkdir -p "~/OpenSource"
fi

################################################################################
# Clone mac-bootstrap repo
################################################################################

echo  "Fetching osx bootstrap repo..."
cd ~/Projects
curl -O -L https://github.com/JacobWeyer/osx_bootstrap/archive/updates.zip
ls -la
unzip updates.zip
rm -rf updates.zip
cd osx_bootstrap-updates
PROJECT_DIR=$(pwd)

source ./bin/lib/methods.sh

################################################################################
# Install Homebrew & Apps
################################################################################
cd $PROJECT_DIR
fancy_echo "Go Homebrew Go!"
source ./bin/homebrew.sh

################################################################################
# Install ZSH
################################################################################
cd $PROJECT_DIR
if [ ! -f "$HOME/.zshrc" ]; then
  fancy_echo "Install oh-my-zsh"
  wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
  fancy_echo "Adding .zshrc"
  wget https://raw.githubusercontent.com/dracula/zsh/master/dracula.zsh-theme -P ~/.oh-my-zsh/themes/
  rm $HOME/.zshrc
  cp ./templates/.zshrc $HOME/.zshrc
  chsh -s /bin/zsh
else
  fancy_echo ".oh-my-zsh already exists"
fi

################################################################################
# Install Node
################################################################################
cd $HOME
fancy_echo "Setup Node & NVM"
source ./bin/node.sh

################################################################################
# Run Chrome
################################################################################
cd $HOME
source ./bin/chrome.sh

################################################################################
# Set Up Git
################################################################################
cd $PROJECT_DIR
fancy_echo "Setup Git"
source ./bin/git.sh

################################################################################
# Set Up Dotfiles
################################################################################
cd $PROJECT_DIR
source ./bin/alias.sh

################################################################################
# Update System Options
################################################################################
cd $HOME
source ./bin/system.sh

echo
echo "**********************************************************************"
echo "**********************************************************************"
echo "****                                                              ****"
echo "**** Mac Bootstrap script complete! Please restart your computer. ****"
echo "****                                                              ****"
echo "**********************************************************************"
echo "**********************************************************************"
echo
