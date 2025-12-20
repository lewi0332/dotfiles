#!/usr/bin/env bash
# Common package installation (cross-platform)

install_common_packages() {
    echo "=== Installing Common Packages ==="
    
    # Install zsh
    echo "Checking for zsh installation..."
    if ! command -v zsh &> /dev/null; then
        echo "zsh not found. Installing zsh..."
        if [[ "$OS" == "macos" ]]; then
            brew install zsh
        else
            sudo apt update
            sudo apt install -y zsh
        fi
    else
        echo "zsh is already installed."
    fi

    # Set zsh as default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        echo "Setting zsh as the default shell..."
        chsh -s "$(which zsh)"
        echo "zsh is now the default shell. You may need to log out and back in for this to take effect."
    else
        echo "zsh is already the default shell."
    fi

    # Install tmux
    echo "Checking for tmux installation..."
    if ! command -v tmux &> /dev/null; then
        echo "tmux not found. Installing tmux..."
        if [[ "$OS" == "macos" ]]; then
            brew install tmux
        else
            sudo apt update
            sudo apt install -y tmux
        fi
    else
        echo "tmux is already installed."
    fi

    # Install fzf
    echo "Checking for fzf installation..."
    if ! command -v fzf &> /dev/null; then
        echo "fzf not found. Installing fzf..."
        if [[ "$OS" == "macos" ]]; then
            brew install fzf
        else
            sudo apt update
            sudo apt install -y fzf
        fi
    else
        echo "fzf is already installed."
    fi

    # Install zoxide
    echo "Checking for zoxide installation..."
    if ! command -v zoxide &> /dev/null; then
        echo "zoxide not found. Installing zoxide..."
        if [[ "$OS" == "macos" ]]; then
            brew install zoxide
        else
            sudo apt update
            sudo apt install -y zoxide
        fi
    else
        echo "zoxide is already installed."
    fi

    # Install UV (Python package manager)
    echo "Checking for UV installation..."
    if command -v uv &> /dev/null; then
        echo "UV is already installed. Updating to latest version..."
        uv self update
    else
        echo "UV not found. Installing UV..."
        curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --no-modify-path
        
        # Add UV to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"
        
        # Verify installation
        if command -v uv &> /dev/null; then
            echo "✅ UV installed successfully."
        else
            echo "⚠️  UV installation may require shell restart. Try: source ~/.zshrc"
        fi
    fi

    # Install Ruff via UV
    echo "Checking for Ruff installation..."
    if command -v uv &> /dev/null; then
        if uv tool list | grep -q "^ruff "; then
            echo "Ruff is already installed. Updating to latest version..."
            uv tool upgrade ruff
        else
            echo "Ruff not found. Installing Ruff..."
            uv tool install ruff@latest
        fi
    else
        echo "⚠️  UV not available. Skipping Ruff installation. Run script again after sourcing shell config."
    fi

    # Install pre-commit via UV
    echo "Checking for pre-commit installation..."
    if command -v uv &> /dev/null; then
        if uv tool list | grep -q "^pre-commit "; then
            echo "pre-commit is already installed. Updating to latest version..."
            uv tool upgrade pre-commit
        else
            echo "pre-commit not found. Installing pre-commit..."
            uv tool install pre-commit@latest
        fi
    else
        echo "⚠️  UV not available. Skipping pre-commit installation. Run script again after sourcing shell config."
    fi

    echo "UV, Ruff, and pre-commit installation complete!"
}
