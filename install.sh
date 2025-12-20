#!/usr/bin/env bash
############################
# Dotfiles Installation Script
# This script orchestrates the installation of dotfiles and packages
# Supports both macOS and Linux
############################

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all helper scripts
source "${SCRIPT_DIR}/scripts/detect_os.sh"
source "${SCRIPT_DIR}/scripts/packages_common.sh"
source "${SCRIPT_DIR}/scripts/packages_macos.sh"
source "${SCRIPT_DIR}/scripts/packages_linux.sh"
source "${SCRIPT_DIR}/scripts/fonts.sh"
source "${SCRIPT_DIR}/scripts/symlinks.sh"

# Main installation flow
main() {
    echo "======================================"
    echo "  Dotfiles Installation Starting"
    echo "======================================"
    echo ""
    
    # Detect operating system
    detect_os
    echo ""
    
    # Install common packages (zsh, tmux, uv, ruff)
    install_common_packages
    echo ""
    
    # Install OS-specific packages
    if [[ "$OS" == "macos" ]]; then
        install_macos_packages
    else
        install_linux_packages
    fi
    echo ""
    
    # Install fonts
    install_fonts
    echo ""
    
    # Create symlinks
    create_symlinks
    echo ""
    
    echo "======================================"
    echo "  Installation Complete!"
    echo "======================================"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Verify font installation in your terminal settings"
    echo "  3. Enjoy your new setup! 🎉"
}

# Run main function
main "$@"
