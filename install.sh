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


echo "Installation Complete!"