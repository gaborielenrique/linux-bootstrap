#!/bin/bash
set -euo pipefail
has_command() {
    command -v "$1" >/dev/null 2>&1
}

if has_command apt-get; then
    echo "Updating package list"
    apt-get update -qq
    echo "Checking for updates"
    if apt-get -s dist-upgrade | grep -q "^Inst "; then
        echo "Updates available. Installing"
        apt-get dist-upgrade -y && apt-get autoremove -y
        echo "Update complete"
    else
        echo "No updates available"
    fi
fi
if has_command dnf; then
    echo "Updating package list"
    dnf makecache --refresh -q
    echo "Checking for updates"
    if dnf check-updates >/dev/null 2>&1; then
        echo "No updates available"
    else
        echo "Updates available. Installing"
        dnf upgrade -y && dnf autoremove -y
    fi
fi
if has_command pacman; then
    echo "I haven't done this part yet... Don't know what to tell you :("
fi
echo "System up to date"
