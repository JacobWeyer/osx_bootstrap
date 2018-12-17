#!/usr/bin/env bash

# Set up node
sudo n lts

fancy_echo "Install global NPM"
sudo npm install -g chai eslint mocha nodemon serverless