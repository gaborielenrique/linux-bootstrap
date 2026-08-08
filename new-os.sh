#!/bin/bash
set -euo pipefail

cd ~

# Helper function for checking for package manager
has_command() {
    command -v "$1" >/dev/null 2>&1
}

# Helper function for creating the random codes
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Here's the things that work regardless of distro
uni-distro() {
    echo "installing neovim"
    curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    sudo mv /opt/nvim-linux-x86_64 /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    rm nvim-linux-x86_64.tar.gz || echo "ERROR: Couldn't remove the neovim tarball"

    echo "installing lazyvim"
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git

    echo "getting nerdfont"
    mkdir -p ~/.local/share/fonts
    wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
    fc-cache -fv || echo "ERROR: Couldn't build font cache"
    rm JetBrainsMono.zip || echo "ERROR: Couldn't remove nerd font zip"

    echo "config git email and username"
    read -p "Enter your full name: " -t 30 FULL_NAME
    git config --global user.name "$FULL_NAME"
    read -p "Enter your email address: " -t 30 EMAIL
    git config --global user.email "$EMAIL"
    ssh-keygen -t ed25519 -C "$EMAIL" && eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519

    #Now on making the random codes folders
    cd Desktop && mkcd "random-codes"
    mkcd "c++" && echo "#include<iostream>" >random_cplus.cpp && cd ..
    mkcd "python" && mkcd "script" && python3 -m venv random-virtual-environment && echo "source ./random-virtual-environment/bin/activate" >.envrc && echo "print('wassup')" >randompy.py && cd ..
    mkcd "notebook" && python3 -m venv random-notebook-virtual-environment && echo "source ./random-notebook-virtual-environment/bin/activate" >.envrc && touch random-notebook.ipynb && cd ~

    echo "Setting up auto-updates"
    UPDATE_PATH="$HOME/Downloads/linux-bootstrap-main/auto-update.sh"
    sudo tee /etc/systemd/system/auto-update.service >/dev/null <<EOF
    [Unit]
    Description=Daily automatic package updates

    [Service]
    Type=oneshot
    ExecStart=$UPDATE_PATH
EOF
    sudo tee /etc/systemd/system/auto-update.timer >/dev/null <<EOF
    [Unit]
    Description=Automatic update of packages daily

    [Timer]
    OnCalendar=daily
    Persistent=true
    RandomizedDelaySec=30m

    [Install]
    WantedBy=timers.target
EOF
    sudo systemctl daemon-reload && sudo systemctl enable --now auto-update.timer
}

# Works with ubuntu based distros
if has_command apt-get; then
    echo "Update the system"
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

    echo "Installing some utilities"
    sudo apt install -y git curl htop build-essential cmake clangd gdb ripgrep fd-find tree tmux zip unzip python3 python3-pip python3-venv direnv

    # hooking direnv to the terminal
    grep -qxF 'eval "$(direnv hook bash)"' ~/.bashrc || echo 'eval "$(direnv hook bash)"' >>~/.bashrc

    # Installing brave browser
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    cd Desktop && sudo apt install -y brave-browser && cd ~ || echo "couldn't install brave browser"

    # Getting rid of firefox
    sudo apt purge -y firefox && rm -rf ~/.mozilla

    echo "Installing discord"
    if has_command snap; then
        sudo snap install discord
    elif has_command flatpak; then
        if ! flatpak remotes | grep -q "flathub"; then
            sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        fi
        flatpak install -y flathub com.discordapp.Discord
    else
        wget "https://discord.com/api/download?platform=linux&format=deb" -O discord.deb
        sudo apt install -y ./discord.deb
    fi

    echo "Installing vscode"
    sudo apt install -y apt-transport-https
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    rm packages.microsoft.gpg
    sudo apt update
    sudo apt install -y code

    uni-distro

    echo "Lastly install any drivers that might be missing (this only works for ubuntu, mint, and debian)"
    if has_command ubuntu-drivers; then
        sudo ubuntu-drivers install
    fi

    # One last update just in case
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
fi

# Works with Fedora, Nobara, Rocky, and Alma
if has_command dnf; then
    # Making it so dnf doesn't take ages to update
    sudo chmod 777 /etc/dnf/dnf.conf
    if ! grep -q "\[main\]" /etc/dnf/dnf.conf; then
        echo "[main]" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
    fi
    echo -e "fastestmirror=True\nmax_parallel_downloads=10\ndeltarpm=True" >>/etc/dnf/dnf.conf
    sudo chmod 644 /etc/dnf/dnf.conf

    echo "Update the system"
    sudo dnf upgrade -y && sudo dnf autoremove -y

    echo "Installing some utilities"
    sudo dnf install -y git curl htop gcc gcc-c++ make cmake clangd gdb tree tmux zip unzip python3 python3-pip

    # Hook direnv to terminal
    grep -qxF 'eval "$(direnv hook bash)"' ~/.bashrc || echo 'eval "$(direnv hook bash)"' >>~/.bashrc

    # Installing brave browser
    if ! dnf config-manager --help >/dev/null 2>&1; then
        sudo dnf install -y 'dnf5-command(config-manager)' dnf-plugins-core
    fi
    sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    cd Desktop/ && sudo dnf install -y brave-browser && cd ~ || echo "ERROR couldn't install brave browser" && cd ~

    # Getting rid of firefox
    sudo dnf remove -y firefox && rm -rf ~/.mozilla

    echo "installing vscode"
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    cd Desktop && sudo dnf install -y code && cd ~

    # Installing Discord
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO="$ID"
        VERSION="$VERSION_ID"
    fi
    sudo dnf install -y "https://mirrors.rpmfusion.org/nonfree/$DISTRO/rpmfusion-nonfree-release-$VERSION.noarch.rpm"
    sudo dnf makecache
    cd Desktop && sudo dnf install -y discord && cd ~

    uni-distro

    # Installing any missing drivers (aka nvidia proprietary drivers)
    sudo dnf install -y kernel-devel kernel-headers
    sudo dnf install -y "https://mirrors.rpmfusion.org/free/$DISTRO/rpmfusion-free-release-$VERSION.noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/$DISTRO/rpmfusion-nonfree-release-$VERSION.noarch.rpm"

    # One last update just in case
    sudo dnf update -y && sudo dnf autoremove -y
fi

# Works with Arch btw, EndeavourOS, CachyOS, and Manjaro
if has_command pacman; then
    # Update the system
    sudo pacman -Sy && sudo pacman -Syu

    # Getting rid of firefox
    sudo pacman -Rns firefox && rm -rf ~/.mozilla/firefox && rm -rf ~/.cache/mozilla

    uni-distro

    # Installing any missing drivers

    # One last update
    sudo pacman -Sy && sudo pacman -Syu
fi

echo "DONE! Now here's what you'll do: 1)Copy the public ssh key below and paste it wherever you want 2) restart the terminal 3) start nvim so that layvim can finish installing"
echo "ssh key:"
cat ~/.ssh/id_ed25519.pub
echo "If pasting on github, run the following command after pasting: ssh -T git@github.com, then enter: yes"
