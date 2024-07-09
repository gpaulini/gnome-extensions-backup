#!/bin/bash
required_pkgs="tar dconf-editor git"
for pkg in $required_pkgs; do
  sudo apt install $pkg
done

cd ~
git clone git@github.com:gpaulini/gnome-extensions-backup.git
cd ~/gnome-extensions-backup
tar -xzvf gnome-extensions-backup.tar.gz -C ~/.local/share/gnome-shell/extensions/
dconf load /org/gnome/shell/extensions/ < ~/.local/share/gnome-shell/extensions/configs/extensions-config.dconf

while read extension; do
  echo "enabling $extension"
  gnome-extensions enable "$extension"
done < extensions-list.txt

sudo rm -rf ~/gnome-extensions-backup

printf "\n\nPLEASE, LOG OUT TO APPLY CHANGES!\n\n"