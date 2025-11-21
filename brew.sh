#!/usr/bin/env zsh

#TODO: adjust path between linux and mac.
#TODO: decide if this is the right list of packages for brew to handle.



# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not installed. Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Attempt to set up Homebrew PATH automatically for this session
    if [ -x "/opt/homebrew/bin/brew" ]; then
        # For Apple Silicon Macs
        echo "Configuring Homebrew in PATH for Apple Silicon Mac..."
        export PATH="/opt/homebrew/bin:$PATH"
    fi
else
    echo "Homebrew is already installed."
fi

# Verify brew is now accessible
if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
fi

# Moving pipx install location for easy reference in VSCode Settings
if [ ! -d "/opt/pipx" ]; then
    echo "Creating /opt/pipx and setting up permissions..."
    sudo mkdir -p /opt/pipx/{bin,share/man}
    sudo chown -R $(whoami):admin /opt/pipx
    export PIPX_HOME="/opt/pipx"
    export PIPX_BIN_DIR="/opt/pipx/bin"
    export PIPX_MAN_DIR="/opt/pipx/share/man"
    export PATH="/opt/pipx/bin:$PATH"
else
    echo "/opt/pipx already exists. Skipping directory creation."
fi

# Update Homebrew and Upgrade any already-installed formulae
brew update
brew upgrade
brew upgrade --cask
brew cleanup

# Define an array of packages to install using Homebrew.
packages=(
    "python"
    "neovim"
    "tree"
    "node"
    "nvm"
    "pipx"
    # "gh"
    "ripgrep"
    "tealdeer"
)

# Loop over the array to install each application.
for package in "${packages[@]}"; do
    if brew list --formula | grep -q "^$package\$"; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        brew install "$package"
    fi
done

# Git config name
current_name=$(git config --global --get user.name)
if [ -z "$current_name" ]; then
    echo "Please enter your FULL NAME for Git configuration:"
    read git_user_name
    git config --global user.name "$git_user_name"
    echo "Git user.name has been set to $git_user_name"
else
    echo "Git user.name is already set to '$current_name'. Skipping configuration."
fi

# Git config email
current_email=$(git config --global --get user.email)
if [ -z "$current_email" ]; then
    echo "Please enter your EMAIL for Git configuration:"
    read git_user_email
    git config --global user.email "$git_user_email"
    echo "Git user.email has been set to $git_user_email"
else
    echo "Git user.email is already set to '$current_email'. Skipping configuration."
fi

# Github uses "main" as the default branch name
git config --global init.defaultBranch main

# Check if already authenticated with GitHub to avoid re-authentication prompt
if ! gh auth status &>/dev/null; then
    echo "You will need to authenticate with GitHub. Follow the prompts to login..."
    $(brew --prefix)/bin/gh auth login
else
    echo "Already authenticated with GitHub. Skipping login."
fi

# Install GitHub Copilot extension
# $(brew --prefix)/bin/gh extension install github/gh-copilot

# Define an array of applications to install using Homebrew Cask.
# apps=(
#     "visual-studio-code"
#     "docker"
# )

# Loop over the array to install each application.
# for app in "${apps[@]}"; do
#     if brew list --cask | grep -q "^$app\$"; then
#         echo "$app is already installed. Skipping..."
#     else
#         echo "Installing $app..."
#         brew install --cask "$app"
#     fi
# done

# Install fonts. Fonts are now available directly from Homebrew cask
fonts=(
    "font-source-code-pro"
    "font-lato"
    "font-montserrat"
    "font-nunito"
    "font-open-sans"
    "font-oswald"
    "font-poppins"
    "font-raleway"
    "font-roboto"
    "font-architects-daughter"
    "font-fontawesome"
    "font-varela-round"
    "font-quicksand"
)

for font in "${fonts[@]}"; do
    # Check if the font is already installed
    if brew list --cask | grep -q "^$font\$"; then
        echo "$font is already installed. Skipping..."
    else
        echo "Installing $font..."
        brew install --cask "$font"
    fi
done

# Once fonts are installed, import your Terminal Profile
echo "Import your terminal settings..."
echo "Terminal -> Settings -> Profiles -> Import..."
echo "Import from ${HOME}/dotfiles/settings/CMS.terminal"
echo "Press enter to continue..."
read

# Update and clean up again for safe measure
brew update
brew upgrade
brew upgrade --cask
brew cleanup