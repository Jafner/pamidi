#!/bin/bash

echo "Installing script..."
chmod +x pamidi.sh
cp pamidi.sh /usr/bin/pamidi
echo "Installing daemon..."
mkdir -p ~/.config/systemd/user/
cp pamidi.service ~/.config/systemd/user/
echo "Enabling systemd daemon..."
systemctl --user daemon-reload
systemctl --user enable pamidi.service
systemctl --user start pamidi.service

edho "Done!"