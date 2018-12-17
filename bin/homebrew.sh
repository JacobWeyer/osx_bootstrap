#!/usr/bin/env bash

if ! command -v brew >/dev/null; then
  fancy_echo "Installing Homebrew ..."
    curl -fsS \
      'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

    # shellcheck disable=SC2016
    append_to_file "$shell_file" 'export PATH="/usr/local/bin:$PATH"'
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
  brew install mas
fi

fancy_echo "Verifying the Homebrew installation..."
if brew doctor; then
  fancy_echo "Your Homebrew installation is good to go."
else
  fancy_echo "Your Homebrew installation reported some errors or warnings."
  echo "Review the Homebrew messages to see if any action is needed."
fi

fancy_echo "Installing formulas and casks from the Brewfile ..."

brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-indent --with-default-names
brew install gnu-which --with-default-names

# Install Applications
if brew bundle install --file $PROJECT_DIR/brew/Brewfile; then
  fancy_echo "All formulas were installed successfully."
else
  fancy_echo "Some formulas or casks failed to install."
  echo "This is usually due to one of the Mac apps being already installed,"
  echo "in which case, you can ignore these errors."
fi

if brew bundle install --file /brew/Caskfile; then
  fancy_echo "All Casks were installed successfully."
else
  fancy_echo "Some formulas or casks failed to install."
  echo "This is usually due to one of the Mac apps being already installed,"
  echo "in which case, you can ignore these errors."
fi

printf "\\nTo use the MAS CLI, enter your username. (Leave blank to skip: %s)\\n"
read -r -p "> " MAS_USERNAME

if [ $MAS_USERNAME != "" ]; then
    mas signin $MAS_USERNAME
    if brew bundle install --file $PROJECT_DIR/brew/MASfile; then
      fancy_echo "All Mac App Store Applications were installed successfully."
    else
      fancy_echo "Some formulas or casks failed to install."
      echo "This is usually due to one of the Mac apps being already installed,"
      echo "in which case, you can ignore these errors."
    fi
else
    fancy_echo "Skipped MAS CLI Install"
fi