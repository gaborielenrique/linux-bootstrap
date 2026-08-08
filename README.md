# linux-bootstrap
A collection of shell scripts that automate the setup and maintenance of a fresh Linux installation.

The goal of this project is simple: after installing a new Linux distribution, I should be able to run a single script that installs my development environment, common applications, editor configuration, fonts, and other utilities without manually repeating the same steps every time.

The repository currently contains two scripts:

new-os.sh — bootstraps a fresh Linux installation.
auto-update.sh — performs automatic system updates when updates are available.
Features
new-os.sh

The setup script currently supports:

Debian/Ubuntu-based distributions (apt)
Fedora/RHEL-based distributions (dnf)
Partial support for Arch-based distributions (pacman)

The script automates tasks such as:

Updating the system
Installing development tools
- Git
- C/C++ toolchain
- CMake
- GDB
- Clangd
- Python
- Direnv
- Tmux
- Ripgrep
- fd
- Tree
- Zip utilities
- Installing Neovim
- Installing the LazyVim starter configuration
- Installing JetBrains Mono Nerd Font
- Installing Brave Browser
- Installing Visual Studio Code
- Installing Discord
- Configuring Git
- Enabling direnv
- Creating a starter development workspace with example C++ and Python projects
- Performing a final system update

auto-update.sh

A lightweight maintenance script that:

- Checks whether updates are available
- Runs a system upgrade only when necessary
- Removes unused packages

Currently this script supports distributions that have either apt or dnf.

Usage

download the zip file, and then unzip it:

unzip linux-bootstrap-main.zip
cd linux-bootstrap

Make the scripts executable:

chmod +x new-os.sh auto-update.sh

Run the setup script:

./new-os.sh

The update script is intended to be executed automatically (for example through cron or a systemd timer), although configuring this is currently left to the user.

Future Improvements

- Complete Arch Linux support
- Better modularization of package installation
- User-selectable software profiles
- Optional desktop environments
- Improved error handling and logging
- Support for additional package managers

Why I Built This

I frequently install Linux on different machines and found myself repeating the same installation process every time.

This project automates that workflow so a new system can be transformed into a fully configured development machine in just a few minutes.

Rather than serving as a universal Linux installer, it reflects my preferred development environment while remaining easy to modify for other workflows.
