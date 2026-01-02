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
    echo "Checking for lazygit installation..."
    if ! command -v lazygit &> /dev/null; then
        echo "lazygit not found. Installing lazygit..."
        if sudo apt install -y lazygit 2>/dev/null; then
            echo "✅ lazygit installed via apt."
        else
            echo "apt install failed, installing from GitHub..."
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf lazygit.tar.gz lazygit
            sudo install lazygit /usr/local/bin
            rm lazygit lazygit.tar.gz
            echo "✅ lazygit installed from GitHub."
        fi
    else
        echo "lazygit is already installed."
    fi
    
    # Install starship via official installer
    echo "Checking for starship installation..."
    if ! command -v starship &> /dev/null; then
        echo "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        echo "starship is already installed."
    fi
}
