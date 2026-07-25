#!/bin/bash
set -euo pipefail

cd ~

# Helper function for checking for package manager
has_command() {
    command -v "$1" >/dev/null 2>&1
}

# Helper function for creating the random codes
mkcd() {
    mkdir "$1" && cd "$1"
}

# Works with ubuntu based distros
if has_command apt-get; then
    echo "Update the system"
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y

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
    rm -rf ~/.mozilla && rm -rf ~/.cache/mozilla

    echo "Installing neovim"
    sudo apt remove -y neovim || echo "no neovim present"
    curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    sudo mv /opt/nvim-linux-x86_64 /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    rm nvim-linux-x86_64.tar.gz || echo "ERROR: Couldn't remove the neovim tarball"

    echo "Installing lazyvim"
    mv ~/.config/nvim{,.bak} || echo "Can't backup nvim configs"
    mv ~/.local/share/nvim{,.bak} || echo "Can't backup nvim shares"
    mv ~/.local/state/nvim{,.bak} || echo "Can't backup nvim state"
    mv ~/.cache/nvim{,.bak} || echo "Can't backup nvim cache"
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git

    echo "Installing nerdfont"
    mkdir -p ~/.local/share/fonts
    wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
    fc-cache -fv || echo "ERROR: Couldn't build font cache"
    rm JetBrainsMono.zip || echo "ERROR: Couldn't remove nerd font zip"

    echo "Config git email and username"
    git config --global user.name "Gabriel Enrique Angulo Gonzalez"
    git config --global user.email "gaboangulo1@gmail.com"

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
    sudo apt install -y wget gpg apt-transport-https
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    rm packages.microsoft.gpg
    sudo apt update
    sudo apt install -y code

    #Now on making the random codes folders
    cd Desktop && mkcd "random-codes"
    mkcd "c++" && echo "#include<iostream>" >random_cplus.cpp && cd ..
    mkcd "python" && python3 -m venv random-virtual-environment && echo "source ./random-virtual-environment/bin/activate" >.envrc && echo "print('wassup')" >randompy.py && cd ~

    echo "Lastly install any drivers that might be missing (this only works for ubuntu, mint, and debian)"
    if has_command ubuntu-drivers; then
        sudo ubuntu-drivers install
    fi

    echo "One last update..."
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

    echo "Done! Now, here's what you want to do: 1) Restart the terminal 2) Load nvim to fully install lazyvim and wait for it to fully install (usually like 30 mins) and 3) Restart the terminal again"
fi

# Works with Fedora, Nobara, Rocky, and Alma
if has_command dnf; then
    echo "Hey, this bitch uses dnf... AYYY YOOO"

    sudo dnf upgrade -y && sudo dnf autoremove -y
fi

# Works with Arch btw, EndeavourOS, CachyOS, and Manjaro
if has_command pacman; then
    echo "Hey, this bitch uses pacman... AYYYYEEE YYYOOOOOO"

    sudo pacman -Sy && sudo pacman -Syu
fi
