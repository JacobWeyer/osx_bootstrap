#!/usr/bin/env bash

echo "Creating an SSH key for you..."
ssh-keygen -t rsa -f jacob_github

echo "Please add this public key to Github \n"
echo "https://github.com/account/ssh \n"
read -p "Press [Enter] key after this..."

if [ ! -f "$HOME/.gitconfig" ]; then
  fancy_echo "Added .gitconfig"
  cp ./templates/.gitconfig $HOME/.gitconfig
else
  fancy_echo "It looks like your .gitconfig already exists"
fi

if [ ! -f "$HOME/.gitignore" ]; then
  fancy_echo "Added .gitignore"
  cp ./.gitignore $HOME/.gitignore
else
  fancy_echo "It looks like your global .gitignore already exists"
fi

if [ ! -f "$HOME/.editorconfig" ]; then
  echo 'Create .editorconfig'
  cp ./templates/.editorconfig $HOME/.editorconfig
fi