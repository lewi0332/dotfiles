#!/usr/bin/env bash
# Linux-specific package installation

install_linux_packages() {
    echo "=== Linux Package Installation ==="

    # Install and select the Node.js version required by Copilot.
    echo "Checking for Node.js 22 or newer..."
    if ! command -v node &> /dev/null || [[ "$(node -p 'process.versions.node.split(".")[0]')" -lt 22 ]]; then
        export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
        if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
            echo "Installing nvm..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        fi

        # Load nvm in this installer process before installing the default runtime.
        # shellcheck source=/dev/null
        source "$NVM_DIR/nvm.sh"
        nvm install 22
        nvm alias default 22
        nvm use 22
    else
        echo "Node.js $(node --version) is already installed."
    fi
    
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

    # Install graphviz
    echo "Checking for graphviz installation..."
    if ! command -v dot &> /dev/null; then
        echo "graphviz not found. Installing graphviz..."
        sudo apt install -y graphviz
    else
        echo "graphviz is alread installed"
    fi
}
