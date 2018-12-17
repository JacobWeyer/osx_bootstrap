#!/usr/bin/env bash

echo 'Create .aliases and source it in .bash_profile'
mkdir -p $HOME/.aliases
cp -r ./alias $HOME/.aliases