#!/usr/bin/env bash
# Font installation (cross-platform)

install_fonts() {
    echo "=== Installing Fonts ==="
    
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
        
        # Store current directory
        PREV_DIR=$(pwd)
        cd "$FONT_DIR" || exit
        
        # Download and install font
        if command -v wget &> /dev/null; then
            wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
        elif command -v curl &> /dev/null; then
            curl -L -o JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
        else
            echo "⚠️  Neither wget nor curl found. Cannot download font."
            cd "$PREV_DIR" || exit
            return 1
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
        
        cd "$PREV_DIR" || exit
    fi
}
