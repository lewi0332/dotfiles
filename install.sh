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



# Install and configure zsh on Linux
if [[ "$OS" == "linux" ]]; then
    echo "Checking for zsh installation..."
    if ! command -v zsh &> /dev/null; then
        echo "zsh not found. Installing zsh..."
        sudo apt update
        sudo apt install -y zsh
    else
        echo "zsh is already installed."
    fi
    
    # Check if zsh is already the default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        echo "Setting zsh as the default shell..."
        chsh -s "$(which zsh)"
        echo "zsh is now the default shell. You may need to log out and back in for this to take effect."
    else
        echo "zsh is already the default shell."
    fi
fi

# dotfiles directory
dotfiledir="${HOME}/dotfiles"

# list of files/folders to symlink in ${homedir}
# Use zsh files for all systems now
files=(zshrc zprompt aliases) # Add this in later: zprofile

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


# # Run OS-specific scripts
# if [[ "$OS" == "macos" ]]; then
#     # Run the MacOS Script
#     if [[ -f "./macOS.sh" ]]; then
#         ./macOS.sh
#     fi
    
#     # Run the Homebrew Script
#     if [[ -f "./brew.sh" ]]; then
#         ./brew.sh
#     fi
# fi

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