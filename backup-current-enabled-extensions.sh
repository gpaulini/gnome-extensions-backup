#!/bin/bash
local_repo=/var/www/gnome-extensions-backup #~/temp-gnome-extensions
mkdir -p $local_repo  
cd $local_repo

rm gnome-extensions-backup.tar.gz extensions-list.txt

gnome-extensions list --enabled > $local_repo/extensions-list.txt

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

mkdir -p $local_repo/configs
dconf dump /org/gnome/shell/extensions/ > $local_repo/configs/extensions-config.dconf

tar -czvf $local_repo/gnome-extensions-backup.tar.gz -C $local_repo .

git init
git remote add origin git@github.com:gpaulini/gnome-extensions-backup.git
git add .
git commit -m "backed up on $(date +'%m-%d-%Y at %H:%M:%S')"
git push -f origin main

# sudo rm -rf $local_repo