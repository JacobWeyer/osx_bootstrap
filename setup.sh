#!/usr/bin/env bash

set -e

################################################################################
# HELPER FUNCTIONS
################################################################################

source ./lib/helpers.sh

################################################################################
# VARIABLE DECLARATIONS IF NEEDED
################################################################################
export CURRENT_DIR=$(pwd)

################################################################################
# Accept XCODE License
################################################################################

sudo xcodebuild -license accept

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
echo "Enter your Mac App Store Email"
read -r -p "> " APP_STORE_EMAIL
echo
echo "Enter your Mac App Store Password"
read -r -p "> " APP_STORE_PASSWORD

################################################################################
# Creating Default Files/Directories
################################################################################

fancy_echo "Creating default files and directories"

if [ ! -d "$HOME/Projects" ]; then
  fancy_echo "Creating ~/Projects"
  mkdir -p "$HOME/Projects"
fi

if [ ! -d "$HOME/OpenSource" ]; then
  fancy_echo "Creating ~/OpenSource"
  mkdir -p "$HOME/OpenSource"
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

mas signin $APP_STORE_EMAIL $APP_STORE_PASSWORD

if brew bundle install --file=$CURRENT_DIR/brew/MASfile; then
  fancy_echo "All Mac Apps were installed successfully."
else
  fancy_echo "Some Mac Apps failed to install."
  fancy_echo "This is usually due to something already installed,"
  fancy_echo "in which case, you can ignore these errors."
fi

################################################################################
# INSTALL NODE AND COMMON GLOBAL PACKAGES
################################################################################

fancy_echo "Installing N, the Node Version Manager"
sudo n lts

fancy_echo "Install global NPM Packages"
sudo npm install -g chai eslint mocha serverless

################################################################################
# INSTALL Oh My ZSH and Powershell 10k
################################################################################

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "source $(brew --prefix)/opt/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc

################################################################################
# Set Up Git & Generate Git SSH KEY
################################################################################

if [ ! -f "$HOME/.ssh/github.pub" ]; then
    echo "Creating an SSH key for you..."
    ssh-keygen -t rsa -f $HOME/.ssh/github -b 4096 -C "$GIT_EMAIL"
    ssh-add -K $HOME/.ssh/github

    pbcopy < $HOME/.ssh/github.pub

    echo "The Key has been copied to your clipboard. Please add this public key to Github"
    echo "https://github.com/account/ssh"
    read -p "Press [Enter] key after this..."
fi

if [ ! -f "$HOME/.gitignore" ]; then
  fancy_echo "Added .gitignore"
  cp $CURRENT_DIR/.gitignore $HOME/.gitignore
fi

if [ ! -f "$HOME/.editorconfig" ]; then
  echo 'Create .editorconfig'
  cp $CURRENT_DIR/templates/.editorconfig $HOME/.editorconfig
fi

if [ ! -f "$HOME/.gitconfig" ]; then
  fancy_echo "Added .gitconfig"
  cp $CURRENT_DIR/templates/.gitconfig $HOME/.gitconfig
  echo "[user]" >> $HOME/.gitconfig
  echo "    name = $GIT_FIRST_LAST"  >> $HOME/.gitconfig
  echo "    email = $GIT_EMAIL"  >> $HOME/.gitconfig
  echo "    username = $GIT_USERNAME"  >> $HOME/.gitconfig
else
  fancy_echo "It looks like your .gitconfig already exists"
fi

################################################################################
# Copy .alias folder to home
################################################################################

cp -avf $CURRENT_DIR/alias/. $HOME/.alias/

################################################################################
# Update System Values
################################################################################

source $CURRENT_DIR/bin/system_settings.sh

echo
echo "**********************************************************************"
echo "**********************************************************************"
echo "****                                                              ****"
echo "**** Mac Bootstrap script complete! Please restart your computer. ****"
echo "****                                                              ****"
echo "**********************************************************************"
echo "**********************************************************************"
echo
