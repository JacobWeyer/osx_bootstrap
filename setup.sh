#!/usr/bin/env bash

set -e

################################################################################
# HELPER FUNCTIONS
################################################################################

source ./.bin/lib/helpers.sh

################################################################################
# VARIABLE DECLARATIONS IF NEEDED
################################################################################
export COMMANDLINE_TOOLS="/Library/Developer/CommandLineTools"
export CURRENT_DIR=$(pwd)

################################################################################
# Check for presence of command line tools if macOS
################################################################################

if [ ! -d "$COMMANDLINE_TOOLS" ]; then
  fancy_echo "Apple's command line developer tools must be installed before
running this script. To install them, just run 'xcode-select --install' from
the terminal and then follow the prompts. Once the command line tools have been
installed, you can try running this script again."
  xcode-select --install
  exit 1
fi

################################################################################
# AUTHENTICATE
################################################################################

sudo -v

# Keep-alive: update existing `sudo` time stamp until bootstrap has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

################################################################################
# WELCOME
################################################################################

echo
echo "*************************************************************************"
echo "*******                                                           *******"
echo "*******                 Lets Get Started!!                        *******"
echo "*******                                                           *******"
echo "*************************************************************************"
echo

echo "Lets set up your git settings first"
echo "Enter your first and last name (Ex: John Doe):"
read -r -p "> " GIT_FIRST_LAST
echo
echo "Enter your email associated with your Github account: "
read -r -p "> " GIT_EMAIL
echo
echo "Enter your Git username (Github, Gitlab, Bitbucket, etc): "
read -r -p "> " GIT_USERNAME
echo
echo "Do you want the dock sorted based on dock_sort.sh? (y/n)"
read -r -p "> " DOCK_SORT
echo
echo "If you'd like to run the MAS CLI tool and the Mac App Store Installer"
echo "Then enter your username below. (Leave blank to skip)"
echo "Enter your Apple ID: (Leave blank to skip)"
read -r -p "> " MAS_USERNAME

################################################################################
# Creating Default Files/Directories
################################################################################

fancy_echo "Creating default files and directories"

if [ ! -f "$HOME/.bash_profile" ]; then
  fancy_echo "Creating .bash_profile"
  touch $HOME/.bash_profile
  echo 'export PATH="/usr/local/sbin:$PATH"' >> $HOME/.bash_profile
fi

if [ ! -d "$HOME/.bin/" ]; then
  fancy_echo "Creating ~/.bin"
  mkdir -p "$HOME/.bin"
fi

if [ ! -d "$HOME/Projects" ]; then
  fancy_echo "Creating ~/Projects"
  mkdir -p "$HOME/Projects"
fi

if [ ! -d "$HOME/OpenSource" ]; then
  fancy_echo "Creating ~/OpenSource"
  mkdir -p "$HOME/OpenSource"
fi

if [ ! -d "$HOME/.bin" ]; then
  fancy_echo "Creating ~/.bin"
  mkdir -p "$HOME/.bin"
fi

if [ ! -d "/usr/local/sbin" ]; then
  fancy_echo "Creating /usr/local/sbin"
  sudo mkdir -p /usr/local/sbin
  sudo chown -R $(whoami) /usr/local/sbin
fi

################################################################################
# INSTALL AND UPDATE HOMEBREW
################################################################################

fancy_echo "Starting Homebrew..."

if ! command -v brew >/dev/null; then
  fancy_echo "Installing Homebrew ..."
    curl -fsS \
      'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

    # shellcheck disable=SC2016
    append_to_file "$HOME/.bash_profile" 'export PATH="/usr/local/bin:$PATH"'
else
  fancy_echo "Homebrew already installed. Skipping ..."
fi

# Remove brew-cask since it is now installed as part of brew tap caskroom/cask.
# See https://github.com/caskroom/homebrew-cask/releases/tag/v0.60.0
if brew_is_installed 'brew-cask'; then
  brew uninstall --force 'brew-cask'
fi

if tap_is_installed 'caskroom/versions'; then
  brew untap caskroom/versions
fi

fancy_echo "Updating Homebrew ..."
cd "$(brew --repo)" && git fetch && git reset --hard origin/master && brew update

# Install and sign into the app store
if ! brew_is_installed 'mas'; then
fancy_echo "Installing the Mac App Store CLI"
  brew install mas
fi

fancy_echo "Verifying the Homebrew installation..."
if brew doctor; then
  fancy_echo "Your Homebrew installation is good to go."
else
  fancy_echo "Your Homebrew installation reported some errors or warnings."
  echo "Review the Homebrew messages to see if any action is needed."
fi

################################################################################
# INSTALL BREWFILES AND MAS
################################################################################

fancy_echo "Installing updated core packages"

brew install gnu-sed --with-default-names ||
brew install gnu-tar --with-default-names ||
brew install gnu-indent --with-default-names ||
brew install gnu-which --with-default-names ||

fancy_echo "Installing Brew Formulas"

if brew bundle install --file=$CURRENT_DIR/brew/Brewfile; then
  fancy_echo "All formulas were installed successfully."
else
  fancy_echo "Some formulas failed to install."
  fancy_echo "This is usually due to something already installed,"
  fancy_echo "in which case, you can ignore these errors."
fi

fancy_echo "Installing Casks"

if brew bundle install --file=$CURRENT_DIR/brew/Caskfile; then
  fancy_echo "All Casks were installed successfully."
else
  fancy_echo "Some Casks failed to install."
  fancy_echo "This is usually due to something already installed,"
  fancy_echo "in which case, you can ignore these errors."
fi

if [ $MAS_USERNAME != "" ]; then
    fancy_echo "Attempting to sign into MAS. If you're already signed in then it should proceed"
    mas signin $MAS_USERNAME &&
    if brew bundle install --file=$PROJECT_DIR/brew/MASfile; then
      fancy_echo "All Mac App Store Applications were installed successfully."
    else
      fancy_echo "Some formulas or casks failed to install."
      echo "This is usually due to one of the Mac apps being already installed,"
      echo "in which case, you can ignore these errors."
    fi
else
    fancy_echo "Skipped MAS CLI Install"
fi

################################################################################
# INSTALL NODE AND COMMON GLOBAL PACKAGES
################################################################################

if [ ! -f "$HOME/.zshrc" ]; then
  fancy_echo "Install oh-my-zsh"
  wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
  fancy_echo "Adding .zshrc"
  wget https://raw.githubusercontent.com/dracula/zsh/master/dracula.zsh-theme -P ~/.oh-my-zsh/themes/
  rm $HOME/.zshrc
  cp $CURRENT_DIR/templates/.zshrc $HOME/.zshrc
  chsh -s /bin/zsh
else
  fancy_echo ".oh-my-zsh already exists"
fi

################################################################################
# INSTALL NODE AND COMMON GLOBAL PACKAGES
################################################################################

#fancy_echo "Installing N, the Node Version Manager"
#sudo n lts
#
#fancy_echo "Install global NPM Packages"
#sudo npm install -g chai eslint mocha nodemon serverless

################################################################################
# Set Up Git & Generate Git SSH KEY
################################################################################

#if [ ! -f "~/.ssh/github.pub" ]; then
#    echo "Creating an SSH key for you..."
#    ssh-keygen -t rsa -f $HOME/.ssh/github -b 4096 -C "$GIT_EMAIL"
#    ssh-add -K $HOME/.ssh/github
#
#    pbcopy < $HOME/.ssh/github.pub
#
#    echo "The Key has been copied to your clipboard. Please add this public key to Github"
#    echo "https://github.com/account/ssh"
#    read -p "Press [Enter] key after this..."
#fi
#
#if [ ! -f "$HOME/.gitignore" ]; then
#  fancy_echo "Added .gitignore"
#  cp $CURRENT_DIR/.gitignore $HOME/.gitignore
#fi
#
#if [ ! -f "$HOME/.editorconfig" ]; then
#  echo 'Create .editorconfig'
#  cp $CURRENT_DIR/templates/.editorconfig $HOME/.editorconfig
#fi
#
#if [ ! -f "$HOME/.gitconfig" ]; then
#  fancy_echo "Added .gitconfig"
#  cp $CURRENT_DIR/templates/.gitconfig $HOME/.gitconfig
#  echo "[user]" >> $HOME/.gitconfig
#  echo "    name = $GIT_FIRST_LAST"  >> $HOME/.gitconfig
#  echo "    email = $GIT_EMAIL"  >> $HOME/.gitconfig
#  echo "    username = $GIT_USERNAME"  >> $HOME/.gitconfig
#else
#  fancy_echo "It looks like your .gitconfig already exists"
#fi

################################################################################
# Copy .alias folder to home
################################################################################

cp -avf $CURRENT_DIR/.alias/. $HOME/.alias/

################################################################################
# Copy bin files to home folder
################################################################################

cp -avf $CURRENT_DIR/.bin/. $HOME/.bin/

################################################################################
# Dock Sort
################################################################################

if [ $DOCK_SORT == "y" ]; then
    fancy_echo "Sorting your dock"
    source $HOME/.bin/dock_sort.sh
else
    fancy_echo "Dock Sort skipped"
fi

################################################################################
# Update System Values
################################################################################

source $HOME/.bin/system_settings.sh

echo
echo "**********************************************************************"
echo "**********************************************************************"
echo "****                                                              ****"
echo "**** Mac Bootstrap script complete! Please restart your computer. ****"
echo "****                                                              ****"
echo "**********************************************************************"
echo "**********************************************************************"
echo
