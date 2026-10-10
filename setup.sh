#!/bin/env bash

# -e: Exit immediately on error.
# -x: Print each command before executing it (useful for debugging).
# -o pipefail: Make the script fail if any command in a pipeline fails.
set -exo pipefail

apt_update() {
  sudo apt update
}

apt_install() {
  sudo DEBIAN_FRONTEND=noninteractive apt install --install-recommends -y "$@"
}

snap_install() {
  sudo snap install "$@"
}

wget_download() {
  wget -O "$1" "$2"
}

apt_update

# Ubuntu repositories and Steam's 32-bit dependencies
apt_install software-properties-common
sudo add-apt-repository --yes --no-update universe
sudo add-apt-repository --yes --no-update multiverse
sudo dpkg --add-architecture i386
apt_update

sudo apt upgrade -y

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

OPT_DIR="$HOME/opt"
mkdir -p "$OPT_DIR"

# Wireshark: allow members of the wireshark group to capture packets
printf '%s\n' 'wireshark-common wireshark-common/install-setuid boolean true' | sudo debconf-set-selections

apt_install git keepassxc flameshot gnome-tweaks curl vlc btop apache2-utils docker.io \
  docker-compose-v2 virtualbox virtualbox-guest-additions-iso filezilla \
  build-essential pkg-config autoconf bison clang libssl-dev zlib1g-dev libyaml-dev libreadline-dev \
  libjemalloc2 libvips sqlite3 libsqlite3-0 libsqlite3-dev libmysqlclient-dev libbz2-dev libncurses-dev \
  libgdbm-dev liblzma-dev tk-dev libffi-dev python3-gpg \
  wireshark nmap steam-installer openttd vcmi ghostty

sudo usermod -aG wireshark "$USER"

# Git configuration
git config --global user.name 'Martynas Puronas'
git config --global user.email 'martynas@puronas.me'

snap_install firefox spotify localsend

echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc

# Herdr
curl -fsSL https://herdr.dev/install.sh -o /tmp/herdr-install.sh
HERDR_INSTALL_DIR="$LOCAL_BIN" sh /tmp/herdr-install.sh

# VS Code
wget_download /tmp/code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
apt_install /tmp/code.deb

# VS Code extensions
VSCODE_EXTENSIONS=(
  # Java
  vscjava.vscode-java-pack
  redhat.java
  vscjava.vscode-java-debug
  vscjava.vscode-java-test
  vscjava.vscode-java-dependency
  vscjava.vscode-maven
  vscjava.vscode-gradle
  # Python
  ms-python.python
  ms-python.vscode-pylance
  ms-python.debugpy
  ms-python.vscode-python-envs
  # Rust
  rust-lang.rust-analyzer
  vadimcn.vscode-lldb
  # Go
  golang.go
  # Bazel
  bazelbuild.vscode-bazel
  # Codex
  openai.chatgpt
  openai.codex-audio
)

for extension in "${VSCODE_EXTENSIONS[@]}"; do
  code --install-extension "$extension"
done

# ChatGPT Desktop
wget_download /tmp/chatgpt.deb 'https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb'
apt_install /tmp/chatgpt.deb

# MySQL Workbench
MYSQL_WORKBENCH_VERSION=26.7.0
wget_download /tmp/mysql-workbench.deb "https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench_${MYSQL_WORKBENCH_VERSION}-1_amd64.deb"
apt_install /tmp/mysql-workbench.deb

# Dropbox
wget_download /tmp/dropbox.deb https://linux.dropbox.com/packages/ubuntu/dropbox_2026.09.28_amd64.deb
apt_install /tmp/dropbox.deb

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

ln -sfn "$LOCAL_BIN/bazelisk" "$LOCAL_BIN/bazel"

# buildifier & buildozer
wget_download /tmp/buildifier "https://github.com/bazelbuild/buildtools/releases/latest/download/buildifier-linux-amd64"
mv /tmp/buildifier "$LOCAL_BIN/buildifier"
chmod +x "$LOCAL_BIN/buildifier"

wget_download /tmp/buildozer "https://github.com/bazelbuild/buildtools/releases/latest/download/buildozer-linux-amd64"
mv /tmp/buildozer "$LOCAL_BIN/buildozer"
chmod +x "$LOCAL_BIN/buildozer"

# VisualVM
wget_download /tmp/visualvm.zip https://github.com/oracle/visualvm/releases/download/2.2.2/visualvm_222.zip
unzip /tmp/visualvm.zip -d "$OPT_DIR/"

# ripgrep
RIPGREP_VERSION=$(curl -fsSL "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
wget_download /tmp/ripgrep.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar -xvf /tmp/ripgrep.tar.gz -C /tmp/
mv "/tmp/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl/rg" "$LOCAL_BIN/rg"
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
  cat <<EOF >> "$1"
export PYENV_ROOT="\$HOME/.pyenv"
[[ -d \$PYENV_ROOT/bin ]] && export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"
EOF
}

set_up_pyenv "$HOME/.bash_profile"
set_up_pyenv "$HOME/.bashrc"

echo "eval \"\$(pyenv virtualenv-init -)\"" >> "$HOME/.bashrc"

"$HOME/.pyenv/bin/pyenv" install 3.15.0
"$HOME/.pyenv/bin/pyenv" global 3.15.0

# SDKMAN & Java
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 25.0.4+1.1-zulu

export NVM_DIR="$HOME/.nvm"
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh -o /tmp/nvm-install.sh
PROFILE=/dev/null bash /tmp/nvm-install.sh

for shell_profile in "$HOME/.bash_profile" "$HOME/.bashrc"; do
  cat <<'EOF' >> "$shell_profile"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
EOF
done

source "$NVM_DIR/nvm.sh"
nvm install 24.21.0
nvm alias default 24.21.0
nvm use default

# Codex CLI & OpenCode
npm install -g @openai/codex@latest opencode-ai@latest

# Codex settings
echo "alias codex='codex --yolo'" >> "$HOME/.bashrc"
codex features disable worktrees

# Go
GO_VERSION=1.27.2
GO_INSTALL_DIR="$OPT_DIR/go$GO_VERSION"
wget_download /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
mkdir -p "$GO_INSTALL_DIR"
tar -xzf /tmp/go.tar.gz --strip-components=1 -C "$GO_INSTALL_DIR"
ln -sfnT "$GO_INSTALL_DIR" "$OPT_DIR/go"

# Rust
curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs -o /tmp/rustup-install.sh
sh /tmp/rustup-install.sh -y --default-toolchain stable --profile default --no-modify-path
source "$HOME/.cargo/env"

for shell_profile in "$HOME/.bash_profile" "$HOME/.bashrc"; do
  cat <<'EOF' >> "$shell_profile"

# Go & Rust
export PATH="$HOME/opt/go/bin:$HOME/go/bin:$PATH"
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
EOF
done

export PATH="$OPT_DIR/go/bin:$HOME/go/bin:$PATH"
go version
rustc --version
cargo --version

cat <<'EOF' >> "$HOME/.bashrc"

# Herdr autostart
if [[ $- == *i* && -t 0 && -t 1 && -z "${HERDR_ENV:-}" && -x "$HOME/.local/bin/herdr" ]]; then
  "$HOME/.local/bin/herdr"
fi
EOF

# Keyboard layouts (Lithuanian US first, matching the current laptop)
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'lt+us'), ('xkb', 'us')]"
gsettings set org.gnome.desktop.input-sources mru-sources "[('xkb', 'lt+us'), ('xkb', 'us')]"

# Switch layouts with Super+Space (Shift reverses direction), or the keyboard-layout key
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Super>space', 'XF86Keyboard']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift><Super>space', '<Shift>XF86Keyboard']"

# Battery, screen blanking, and AC power
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.session idle-delay 600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Privacy
gsettings set org.gnome.desktop.privacy remember-recent-files false

# Allow volume above 100%
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true

# Timezone
gsettings set org.gnome.desktop.datetime automatic-timezone false
sudo timedatectl set-timezone Europe/Vilnius

# Disable popup of apps after moving windows
gsettings set org.gnome.shell.extensions.tiling-assistant enable-tiling-popup false

# Move the dock to the bottom
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'

# Favourites
gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'com.mitchellh.ghostty.desktop', 'code.desktop', 'spotify_spotify.desktop', 'org.keepassxc.KeePassXC.desktop', 'localsend_localsend.desktop', 'filezilla.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.TextEditor.desktop']"

# Theme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface accent-color 'blue'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-purple'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru-purple'
gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/mizuno-as-Winter_Grand_Triangle.jpg'
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/mizuno-as-Winter_Grand_Triangle.jpg'
gsettings set org.gnome.desktop.background primary-color '#000000'
gsettings set org.gnome.desktop.background secondary-color '#000000'
gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/backgrounds/mizuno-as-Winter_Grand_Triangle.jpg'
gsettings set org.gnome.desktop.screensaver primary-color '#000000'
gsettings set org.gnome.desktop.screensaver secondary-color '#000000'
gsettings set org.gnome.mutter edge-tiling true

# Remove unused packages and clear the APT download cache.
sudo apt autoremove -y
sudo apt clean

echo "Done!"
