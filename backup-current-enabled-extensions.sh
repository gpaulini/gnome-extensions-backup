#!/bin/bash
mkdir ~/temp-gnome-extensions
cd ~/temp-gnome-extensions
gnome-extensions list --enabled > ~/temp-gnome-extensions/extensions-list.txt

required_pkgs="tar jq wget curl dconf-editor git"
for pkg in $required_pkgs; do
  sudo apt install $pkg
done

while read extension; do
  url="https://extensions.gnome.org/extensions-query/?search=$extension"
  extension_info=$(curl -s $url | jq '.extensions[0]')
  download_url="https://extensions.gnome.org$(echo $extension_info | jq -r '.download_url')"
  wget -O "$extension.zip" "$download_url"
done < ~/extensions-list.txt

mkdir -p ~/temp-gnome-extensions/configs
dconf dump /org/gnome/shell/extensions/ > ~/temp-gnome-extensions/configs/extensions-config.dconf

tar -czvf ~/temp-gnome-extensions/gnome-extensions-backup.tar.gz -C ~/temp-gnome-extensions .

git init
git remote add origin git@github.com:gpaulini/gnome-extensions-backup.git
git add gnome-extensions-backup.tar.gz extensions-list.txt
git commit -m "backed up on $(date +'%m-%d-%Y at %H:%M:%S')"
git push -f origin master

sudo rm -rf ~/temp-gnome-extensions