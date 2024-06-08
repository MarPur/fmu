#!/bin/env bash

apt_update() {
  sudo apt update
}

apt_install() {
  sudo apt install --install-recommends -y "$@"
}

snap_install() {
  sudo snap install "$@"
}

wget_download() {
  wget -O "$1" "$2"
}

apt_update

apt_install git keepassxc flameshot gnome-tweak-tool curl vlc ripgrep btop apache2-utils docker.io \
  virtualbox virtualbox-guest-additions-iso \
  build-essential pkg-config autoconf bison clang libssl-dev zlib1g-dev libyaml-dev libreadline-dev \
  libjemalloc2 libvips sqlite3 libsqlite3-0 libmysqlclient-dev libbz2-dev libncurses5-dev libgdbm-dev \
  liblzma-dev tk-dev libffi-dev python3-gpg

snap_install spotify telegram-desktop discord
snap_install intellij-idea-community --classic
snap_install pycharm-community --classic

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# Chrome
wget_download /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt_install /tmp/chrome.deb
rm /tmp/chrome.deb

# VS Code
wget_download /tmp/code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
apt_install /tmp/code.deb
rm /tmp/code.deb

# # lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
wget_download /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xvf /tmp/lazygit.tar.gz -C /tmp/
mv /tmp/lazygit "$LOCAL_BIN/lazygit"
rm /tmp/lazygit.tar.gz

# # Docker configuration
sudo usermod -aG docker "${USER}"

# # Configure snapshot
FLAMESHOT_CONFIG="$HOME/.config/flameshot/flameshot.ini"
sed -i "/startupLaunch.*/d" "$FLAMESHOT_CONFIG"
line_after="[General]"
line_to_add="startupLaunch=true"

awk -v line_after="$line_after" -v line_to_add="$line_to_add" '
    {
        print
        if ($0 == line_after && !added) {
            print line_to_add
            added = 1
        }
    }
' "$FLAMESHOT_CONFIG" > /tmp/flameshotconfig && mv /tmp/flameshotconfig "$FLAMESHOT_CONFIG"

# pyenv
curl https://pyenv.run | bash

set_up_pyenv() {  
  if ! grep -qF "export PYENV_ROOT" "$1"; then
      cat <<EOF >> "$1"
export PYENV_ROOT="\$HOME/.pyenv"
[[ -d \$PYENV_ROOT/bin ]] && export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"
EOF
  fi
}

set_up_pyenv "$HOME/.bash_profile"
set_up_pyenv "$HOME/.bashrc"

if ! grep -qF "pyenv virtualenv-init" "$HOME/.bashrc"; then
  echo "eval \"\$(pyenv virtualenv-init -)\"" >> "$HOME/.bashrc"
fi

$HOME/.pyenv/bin/pyenv install 3.12

# SDKMAN & Java
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.2-graalce

# # Dropbox
wget_download /tmp/dropbox.deb https://linux.dropbox.com/packages/ubuntu/dropbox_2024.04.17_amd64.deb
apt_install /tmp/dropbox.deb
rm /tmp/dropbox.deb

# Veracrypt
wget_download /tmp/veracrypt.deb https://launchpad.net/veracrypt/trunk/1.26.7/+download/veracrypt-1.26.7-Ubuntu-24.04-amd64.deb
apt_install /tmp/veracrypt.deb
rm /tmp/veracrypt.deb

sudo apt upgrade -y

echo "Done!!!!!"