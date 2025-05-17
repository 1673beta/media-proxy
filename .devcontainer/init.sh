#!/bin/bash

set -xe

sudo chown node node_modules
sudo apt-get update
sudo apt-get -y install libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libnss3 libxss1 libasound2 libxtst6 xauth xvfb
git config --global --add safe.directory /workspace
pnpm config set store-dir /home/node/.local/share/pnpm/store
pnpm install --frozen-lockfile
cp ./config.example.js ./config.js
pnpm build
