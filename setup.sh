#!/usr/bin/env bash

CURRENT_DIR=$(pwd)
HOME="~/"

cp ./.gitignore $HOME/.gitignore
cp ./templates/.editorconfig $HOME/.editorconfig
cp ./templates/.gitconfig $HOME/.gitconfig

# brew bundle install --file=$CURRENT_DIR/Brewfile

goenv install 1.24.2
goenv global 1.24.2

nvm install lts
nvm use lts

uv python install 3.11
