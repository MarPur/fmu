#!/bin/env bash

# -e: Exit immediately on error.
# -x: Print each command before executing it (useful for debugging).
# -o pipefail: Make the script fail if any command in a pipeline fails.
set -exo pipefail

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

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

OPT_DIR="$HOME/opt"
mkdir -p "$OPT_DIR"

apt_update

apt_install git keepassxc flameshot gnome-tweak-tool curl vlc ripgrep btop apache2-utils docker.io \
  virtualbox virtualbox-guest-additions-iso alacritty filezilla \
  build-essential pkg-config autoconf bison clang libssl-dev zlib1g-dev libyaml-dev libreadline-dev \
  libjemalloc2 libvips sqlite3 libsqlite3-0 libsqlite3-dev libmysqlclient-dev libbz2-dev libncurses5-dev \
  libgdbm-dev liblzma-dev tk-dev libffi-dev python3-gpg

snap_install spotify 

echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc

# Chrome
wget_download /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt_install /tmp/chrome.deb

# VS Code
wget_download /tmp/code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
apt_install /tmp/code.deb

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
wget_download /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xvf /tmp/lazygit.tar.gz -C /tmp/
mv /tmp/lazygit "$LOCAL_BIN/lazygit"

# ghz
GHZ_VERSION=$(curl -s "https://api.github.com/repos/bojand/ghz/releases/latest" | grep -Po '"tag_name": "\Kv[^"]*')
wget_download /tmp/ghz.tar.gz "https://github.com/bojand/ghz/releases/download/${GHZ_VERSION}/ghz-linux-x86_64.tar.gz"
tar -xvf /tmp/ghz.tar.gz -C /tmp/
mv /tmp/ghz "$LOCAL_BIN/ghz"
mv /tmp/ghz-web "$LOCAL_BIN/ghz-web"

# oha
OHA_VERSION=$(curl -s "https://api.github.com/repos/hatoo/oha/releases/latest" | grep -Po '"tag_name": "\Kv[^"]*')
wget_download /tmp/oha "https://github.com/hatoo/oha/releases/download/${OHA_VERSION}/oha-linux-amd64"
mv /tmp/oha "$LOCAL_BIN/oha"
chmod +x "$LOCAL_BIN/oha"

# bazelisk
BAZELISK_VERSION=$(curl -s "https://api.github.com/repos/bazelbuild/bazelisk/releases/latest" | grep -Po '"tag_name": "\Kv[^"]*')
wget_download /tmp/bazelisk "https://github.com/bazelbuild/bazelisk/releases/download/${BAZELISK_VERSION}/bazelisk-linux-amd64"
mv /tmp/bazelisk "$LOCAL_BIN/bazelisk"
chmod +x "$LOCAL_BIN/bazelisk"

ln -s "$LOCAL_BIN/bazelisk" "$LOCAL_BIN/bazel"

# buildifier & buildozer
BUILDTOOLS_VERSION=$(curl -s "https://api.github.com/repos/bazelbuild/buildtools/releases/latest" | grep -Po '"tag_name": "\Kv[^"]*')
wget_download /tmp/buildifier "https://github.com/bazelbuild/buildtools/releases/download/${BUILDTOOLS_VERSION}/buildifier-linux-amd64"
mv /tmp/buildifier "$LOCAL_BIN/buildifier"
chmod +x "$LOCAL_BIN/buildifier"

wget_download /tmp/buildozer "https://github.com/bazelbuild/buildtools/releases/download/${BUILDTOOLS_VERSION}/buildozer-linux-amd64"
mv /tmp/buildozer "$LOCAL_BIN/buildozer"
chmod +x "$LOCAL_BIN/buildozer"

# zellij
ZELLIJ_VERSION=$(curl -s "https://api.github.com/repos/zellij-org/zellij/releases/latest" | grep -Po '"tag_name": "\Kv[^"]*')
wget_download /tmp/zellij.tar.gz "https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz"
tar -xvf /tmp/zellij.tar.gz -C /tmp/
mv /tmp/zellij "$LOCAL_BIN/zellij"
chmod +x "$LOCAL_BIN/zellij"

echo 'eval "$(zellij setup --generate-auto-start bash)"' >> ~/.bashrc

# VisualVM
wget_download /tmp/visualvm.zip https://github.com/oracle/visualvm/releases/download/2.1.10/visualvm_2110.zip
unzip /tmp/visualvm.zip -d "$OPT_DIR/"

# ripgrep
RIPGREP_VERSION=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\Kv[^"]*')
wget_download /tmp/ripgrep.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar -xvf /tmp/ripgrep.tar.gz -C /tmp/
mv /tmp/ripgrep/rg "$LOCAL_BIN/rg"
chmod +x "$LOCAL_BIN/rg"

# Docker configuration
sudo usermod -aG docker "${USER}"

# Configure flameshot
FLAMESHOT_CONFIG_DIR="$HOME/.config/flameshot"
FLAMESHOT_CONFIG="$FLAMESHOT_CONFIG_DIR/flameshot.ini"

mkdir -p "$FLAMESHOT_CONFIG_DIR"
cat <<EOL > "$FLAMESHOT_CONFIG"
[General]
startupLaunch=true
EOL

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
sdk install java 21.0.4-zulu

# Disable popup of apps after moving windows
gsettings set org.gnome.shell.extensions.tiling-assistant enable-tiling-popup false

# Move the dock to the bottom
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'

# Favourites
gsettings set org.gnome.shell favorite-apps "['google-chrome.desktop', 'Alacritty.desktop', 'code.desktop', 'spotify_spotify.desktop', 'org.keepassxc.KeePassXC.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.TextEditor.desktop']"

# Theme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-viridian-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru-viridian'
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/Rainbow_lightbulb_by_Daniel_Micallef.png'
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/Rainbow_lightbulb_by_Daniel_Micallef.png'
gsettings set org.gnome.desktop.background primary-color '#000000'
gsettings set org.gnome.desktop.background secondary-color '#000000'
gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/backgrounds/Rainbow_lightbulb_by_Daniel_Micallef.png'
gsettings set org.gnome.desktop.screensaver primary-color '#000000'
gsettings set org.gnome.desktop.screensaver secondary-color '#000000'
gsettings set org.gnome.mutter edge-tiling true

sudo apt upgrade -y

echo "Done!!!!!"
