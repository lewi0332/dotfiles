#!/usr/bin/env bash
# macOS-specific package installation

install_macos_packages() {
    echo "=== macOS Package Installation ==="
    
    # Install Homebrew
    echo "Checking for Homebrew installation..."
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo "Homebrew is already installed."
    fi
    
    # Run brew.sh for package installation
    if [[ -f "${HOME}/dotfiles/brew.sh" ]]; then
        echo "Running brew.sh for macOS package installation..."
        bash "${HOME}/dotfiles/brew.sh"
    else
        echo "⚠️  brew.sh not found. Skipping Homebrew package installation."
    fi

    # Run macOS system configuration
    if [[ -f "${HOME}/dotfiles/macOS.sh" ]]; then
        echo "Running macOS system configuration..."
        bash "${HOME}/dotfiles/macOS.sh"
    else
        echo "⚠️  macOS.sh not found. Skipping macOS configuration."
    fi
    
    # Install starship via Homebrew
    echo "Checking for starship installation..."
    if ! command -v starship &> /dev/null; then
        echo "Installing starship..."
        brew install starship
    else
        echo "starship is already installed."
    fi
}
