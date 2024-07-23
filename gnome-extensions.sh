#!/bin/bash

# Blur my shell
wget -P /tmp https://extensions.gnome.org/extension-data/blur-my-shellaunetx.v62.shell-extension.zip
unzip -d /tmp/tmpdir /tmp/blur-my-shellaunetx.v62.shell-extension.zip
UUID=$(jq -r '.["uuid"]' < '/tmp/tmpdir/metadata.json')
cp tmp/tmpdir /usr/share/gnome-shell/extensions/${UUID}
rm /tmp/tmpdir
