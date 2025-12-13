#!/usr/bin/env bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# And also installs MacOS Software
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up VS Code
# And also installs and configures zsh
############################

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    OS="linux"
fi

echo "Detected OS: ${OS}"

# Install Homebrew on macOS
if [[ "$OS" == "macos" ]]; then
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
    
    # Run brew.sh for package installation on macOS
    if [[ -f "${HOME}/dotfiles/brew.sh" ]]; then
        echo "Running brew.sh for macOS package installation..."
        bash "${HOME}/dotfiles/brew.sh"
    else
        echo "⚠️  brew.sh not found. Skipping Homebrew package installation."
    fi
fi

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


## Keyboard repeat rate configuration
# if [[ "$OSTYPE" == "darwin"* ]]; then
#     # macOS
#     defaults write NSGlobalDomain KeyRepeat -int 1
#     defaults write NSGlobalDomain InitialKeyRepeat -int 15
# elif [[ -n "$DISPLAY" ]]; then
#     xset r rate 250 30
# elif [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
#     # Linux with Wayland (GNOME)
#     if command -v gsettings &> /dev/null; then
#         gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30
#         gsettings set org.gnome.desktop.peripherals.keyboard delay 250
#     fi
# fi

# dotfiles directory
dotfiledir="${HOME}/dotfiles"

# list of files/folders to symlink in ${homedir}
# Use zsh files for all systems now
files=(zshrc zprompt shared_prompt aliases) # Add this in later: zprofile

# change to the dotfiles directory
echo "Changing to the ${dotfiledir} directory"
cd "${dotfiledir}" || exit

# create symlinks (safer approach - checks before overwriting)
for file in "${files[@]}"; do
    source="${dotfiledir}/.${file}"
    target="${HOME}/.${file}"
    
    if [ -L "$target" ]; then
        echo "$target already exists as a symlink."
    elif [ -e "$target" ]; then
        echo "⚠️  $target already exists as a regular file. Skipping."
    else
        ln -s "$source" "$target"
        echo "✅ Created symlink: $target -> $source"
    fi
done


# list of config directories to symlink
configs=(nvim-lab kickstart ruff)

mkdir -p "${HOME}/.config"
# create symlinks for config directories (safer approach - checks before overwriting)
for config in "${configs[@]}"; do
    source="${dotfiledir}/${config}"
    target="${HOME}/.config/${config}"
    
    if [ -L "$target" ]; then
        echo "$target already exists as a symlink."
    elif [ -e "$target" ]; then
        echo "⚠️  $target already exists as a directory/file. Skipping."
    else
        ln -s "$source" "$target"
        echo "✅ Created symlink: $target -> $source"
    fi
done


# Run OS-specific scripts
if [[ "$OS" == "macos" ]]; then
    # Run the MacOS Script
    if [[ -f "./macOS.sh" ]]; then
        ./macOS.sh
    fi
    
    # Run the Homebrew Script
    if [[ -f "./brew.sh" ]]; then
        ./brew.sh
    fi
fi

# # Run VS Code Script
# if [[ -f "./vscode.sh" ]]; then
#     ./vscode.sh
# fi

# Install UV (Python package manager)
echo "Checking for UV installation..."
if command -v uv &> /dev/null; then
    echo "UV is already installed. Updating to latest version..."
    uv self update
else
    echo "UV not found. Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Install Ruff via UV
echo "Checking for Ruff installation..."
if command -v ruff &> /dev/null; then
    echo "Ruff is already installed. Updating to latest version..."
    uv tool upgrade ruff
else
    echo "Ruff not found. Installing Ruff..."
    uv tool install ruff@latest
fi

echo "UV and Ruff installation complete!"

echo "Installation Complete!"