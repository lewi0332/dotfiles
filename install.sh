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

    # Run macOS system configuration
    if [[ -f "${HOME}/dotfiles/macOS.sh" ]]; then
        echo "Running macOS system configuration..."
        bash "${HOME}/dotfiles/macOS.sh"
    else
        echo "⚠️  macOS.sh not found. Skipping macOS configuration."
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

# Install neovim (Linux only - macOS handled by brew.sh)
if [[ "$OS" == "linux" ]]; then
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
fi


if [[ "$OS" == "linux" ]]; then
    echo "Checking for lazygit installation..."
    if ! command -v lazygit &> /dev/null; then
        echo "lazygit not found. Installing lazygit..."
        sudo apt update
        sudo apt install -y lazygit
    else
        echo "lazygit is already installed."
    fi
fi

# Install JetBrains Mono Nerd Font
echo "Checking for JetBrains Mono Nerd Font installation..."
if [[ "$OS" == "macos" ]]; then
    FONT_DIR="${HOME}/Library/Fonts"
else
    FONT_DIR="${HOME}/.local/share/fonts"
fi

# Check if font is already installed
if command -v fc-list &> /dev/null && fc-list | grep -qi "JetBrainsMono"; then
    echo "JetBrains Mono Nerd Font is already installed."
elif [[ "$OS" == "macos" ]] && ls "$FONT_DIR"/JetBrainsMono*.ttf &> /dev/null 2>&1; then
    echo "JetBrains Mono Nerd Font is already installed."
else
    echo "Installing JetBrains Mono Nerd Font..."
    mkdir -p "$FONT_DIR"
    cd "$FONT_DIR" || exit
    
    # Download and install font
    if command -v wget &> /dev/null; then
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
    elif command -v curl &> /dev/null; then
        curl -L -o JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
    else
        echo "⚠️  Neither wget nor curl found. Cannot download font."
        cd - > /dev/null || exit
        exit 1
    fi
    
    if [[ -f JetBrainsMono.zip ]]; then
        unzip -q JetBrainsMono.zip
        rm JetBrainsMono.zip
        
        # Update font cache (primarily for Linux)
        if command -v fc-cache &> /dev/null; then
            fc-cache -fv > /dev/null 2>&1
        fi
        
        echo "✅ JetBrains Mono Nerd Font installed successfully."
    else
        echo "⚠️  Failed to download font."
    fi
    
    cd - > /dev/null || exit
fi

# Install starship
echo "Checking for starship installation..."
if ! command -v starship &> /dev/null; then
    echo "starship not found. Installing starship..."
    if [[ "$OS" == "macos" ]]; then
        brew install starship
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
else
    echo "starship is already installed."
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


# list of config files to symlink (single files, not directories)
config_files=(starship.toml)

# create symlinks for config files
for config_file in "${config_files[@]}"; do
    source="${dotfiledir}/${config_file}"
    target="${HOME}/.config/${config_file}"
    
    if [ -L "$target" ]; then
        echo "$target already exists as a symlink."
    elif [ -e "$target" ]; then
        echo "⚠️  $target already exists as a file. Skipping."
    else
        ln -s "$source" "$target"
        echo "✅ Created symlink: $target -> $source"
    fi
done




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
if uv tool list | grep -q "^ruff "; then
    echo "Ruff is already installed. Updating to latest version..."
    uv tool upgrade ruff
else
    echo "Ruff not found. Installing Ruff..."
    uv tool install ruff@latest
fi

echo "UV and Ruff installation complete!"

echo "Installation Complete!"