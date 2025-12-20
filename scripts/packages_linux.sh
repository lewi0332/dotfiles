#!/usr/bin/env bash
# Linux-specific package installation

install_linux_packages() {
    echo "=== Linux Package Installation ==="
    
    # Install neovim from unstable PPA
    echo "Checking for neovim installation..."
    if ! command -v nvim &> /dev/null; then
        echo "neovim not found. Installing neovim from unstable PPA..."
        sudo apt update
        sudo apt install -y software-properties-common
        sudo add-apt-repository -y ppa:neovim-ppa/unstable
        sudo apt update
        sudo apt install -y neovim
    else
        echo "neovim is already installed."
    fi

    # # Install lazygit
    # echo "Checking for lazygit installation..."
    # if ! command -v lazygit &> /dev/null; then
    #     echo "lazygit not found. Installing lazygit..."
    #     sudo apt update
    #     sudo apt install -y lazygit
    # else
    #     echo "lazygit is already installed."
    # fi
    
    # Install starship via official installer
    echo "Checking for starship installation..."
    if ! command -v starship &> /dev/null; then
        echo "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        echo "starship is already installed."
    fi
}
