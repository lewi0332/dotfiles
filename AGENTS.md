# Agent Guidelines for dotfiles Repository

This document provides coding agents with essential information about this dotfiles repository structure, commands, and conventions.

## Repository Overview

This is a personal dotfiles repository for managing shell configurations, Neovim setups, and development environment across macOS and Linux systems. The repository uses a modular structure with separate configurations for different tools and environments.

## Project Structure

```
dotfiles/
├── scripts/          # Modular installation scripts
├── kickstart/        # Kickstart.nvim configuration
├── nvim-lab/         # Custom Neovim configuration
├── ruff/             # Ruff Python linter configuration
├── snippets/         # Code snippets and reference materials
├── bin/              # Custom scripts (og, on)
├── install.sh        # Main installation orchestrator
├── brew.sh           # Homebrew packages for macOS
├── macOS.sh          # macOS system configuration
└── .* files          # Shell dotfiles (zshrc, aliases, tmux.conf, etc.)
```

## Installation & Testing Commands

### Full Installation
```bash
cd ~/dotfiles
chmod +x install.sh scripts/*.sh
./install.sh
```

### Test Individual Modules
```bash
# Test OS detection
source scripts/detect_os.sh && detect_os

# Test symlink creation only
source scripts/detect_os.sh && detect_os
source scripts/symlinks.sh && create_symlinks

# Test font installation only
source scripts/detect_os.sh && detect_os
source scripts/fonts.sh && install_fonts

# Test common packages installation
source scripts/detect_os.sh && detect_os
source scripts/packages_common.sh && install_common_packages
```

### Testing in Docker
```bash
# Test on Ubuntu
docker run -it --rm -v ~/dotfiles:/dotfiles ubuntu:latest bash
cd /dotfiles && ./install.sh
```

### Symlink Management
The repository creates symlinks for:
- **Home dotfiles**: .zshrc, .zprompt, .shared_prompt, .aliases, .tmux.conf
- **Config directories**: nvim-lab, kickstart, ruff
- **Config files**: starship.toml

Existing .zshrc is preserved as ~/.zshrc.local (auto-sourced by main .zshrc)

## Code Style Guidelines

### Shell Scripts (Bash/Zsh)

**File Structure:**
- Use `#!/usr/bin/env bash` shebang
- Set `set -e` for error handling in main scripts
- Group related functions in modular files under scripts/

**Naming Conventions:**
- Functions: `snake_case_with_verbs` (e.g., `install_common_packages`, `create_symlinks`)
- Variables: `lowercase_with_underscores` (e.g., `dotfiledir`, `config_files`)
- Constants/exports: `UPPERCASE` (e.g., `OS`, `SCRIPT_DIR`)

**Coding Standards:**
- Always quote variables: `"${variable}"` or `"$variable"`
- Use arrays for lists: `packages=("item1" "item2")`
- Check command existence: `if ! command -v tool &> /dev/null; then`
- Provide user feedback: echo status messages with ✅/⚠️ prefixes
- Use conditional checks before creating/overwriting files
- Change directory safely: `cd "${dir}" || exit`

**Error Handling:**
- Check if commands exist before using them
- Validate prerequisites before operations
- Provide clear error messages and recovery instructions
- Use symlink checks: `if [ -L "$target" ]` before `if [ -e "$target" ]`

### Python Code (via Ruff)

**Configuration:** See `ruff/ruff.toml`

**Linting & Formatting:**
```bash
# Format Python files
ruff format .

# Lint Python files
ruff check .

# Fix auto-fixable issues
ruff check --fix .

# Check specific file
ruff check path/to/file.py
```

**Import Conventions:**
- Use isort-compliant ordering (enforced by Ruff rule "I")
- Standard library → third-party → local imports
- Use conventional aliases (enforced by ICN rule):
  - `import numpy as np`
  - `import pandas as pd`

**Code Style:**
- Line length: No hard limit (E501 ignored), but be reasonable
- Use f-strings over .format() (enforced by FLY)
- Prefer pathlib over os.path (enforced by PTH)
- Type hints encouraged but not strictly required (ANN disabled)
- Docstrings: Not required for all functions (D1 ignored)
- Follow PEP 8 naming conventions (N rule enabled)

**Error Handling:**
- Avoid bare except statements (BLE rule)
- Use specific exception types
- Exception messages can be inline (EM101, TRY003 ignored)

**Security:**
- Be cautious with security issues (S rule enabled)
- Note: S311 ignored (standard random is acceptable for non-crypto use)

### Lua (Neovim Configs)

**Configuration:** See `kickstart/.stylua.toml`

**Formatting:**
```bash
# Format Lua files (requires stylua)
stylua kickstart/
stylua nvim-lab/
```

**Style Rules:**
- Column width: 160 characters
- Indentation: 2 spaces
- Quote style: Auto-prefer single quotes
- Call parentheses: None (use `require 'module'` not `require('module')`)
- Line endings: Unix (LF)

**Naming Conventions:**
- Variables: `snake_case`
- Plugin configs: Organized in separate files under `lua/plugins/`
- Config modules: Organized under `lua/config/`

### Git Workflow

**Branch Strategy:**
- Default branch: `main` (configured in brew.sh)
- Feature branches: Use descriptive names

**Commit Messages:**
- Use imperative mood: "Add feature" not "Added feature"
- Be specific: Reference affected modules/files
- Keep commits focused and atomic

**Git Configuration:**
The install scripts configure:
- Default branch name: main
- User name and email (interactive prompts on first install)

## Tool Installation

### Managed via UV (Python Package Manager)
```bash
# Install/update UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Python tools via UV
uv tool install ruff@latest
uv tool install pre-commit@latest

# Upgrade all UV tools
uv tool upgrade --all
```

### Managed via Homebrew (macOS)
```bash
# Update all Homebrew packages
brew update && brew upgrade && brew upgrade --cask && brew cleanup

# Or use alias (macOS only)
update_brew
```

## Common Aliases

**File Operations:**
- `ll`: `ls -alF` (detailed list)
- `la`: `ls -lahF` (all files with human-readable sizes)
- `vim`: aliased to `nvim`
- `python`: aliased to `python3`

**History Search:**
- `hg <pattern>`: grep command history
- `ch`: show git commit history

**Directory Navigation:**
- `cd`: Enhanced with zoxide (smart cd based on frecency)
- Auto-ls on directory change (zsh hook)
- Auto-activate .venv when entering Python projects (zsh hook)

## Shell Configuration Features

### Zsh (.zshrc)
- Plugin manager: zinit
- Plugins: syntax-highlighting, completions, autosuggestions, fzf-tab
- Prompt: starship
- History: 5000 lines with deduplication
- Integrations: fzf (fuzzy finder), zoxide (smart cd)
- Auto-activation: Virtual environments when .venv present

### Bash (.bashrc)
- Simpler configuration for compatibility
- Sources .bash_prompt, .aliases, .private (if present)
- GitHub Copilot CLI integration

### Tmux (.tmux.conf)
- Plugin manager: TPM (Tmux Plugin Manager)
- Install plugins: Press `Ctrl+Space` then `I` (capital i)

## Modifying the Repository

### Adding New Packages

**Cross-platform packages:**
Edit `scripts/packages_common.sh` and add to the installation logic

**macOS-only packages:**
Edit `scripts/packages_macos.sh` or add to `brew.sh` packages array

**Linux-only packages:**
Edit `scripts/packages_linux.sh`

### Adding New Symlinks

Edit `scripts/symlinks.sh` and add to appropriate array:
- `files`: Home directory dotfiles (without leading dot)
- `configs`: Config directories
- `config_files`: Individual config files

### Adding New Script Modules

1. Create `scripts/new_module.sh`
2. Define function: `function_name() { ... }`
3. Source it in `install.sh`: `source "${SCRIPT_DIR}/scripts/new_module.sh"`
4. Call function in `main()` function

## Important Notes for Agents

1. **Preserve existing configs**: The install script preserves existing .zshrc as .zshrc.local
2. **Check before overwriting**: Always check if files/symlinks exist before creating
3. **OS detection**: Use the OS detection pattern from scripts/detect_os.sh
4. **Cross-platform support**: Test changes on both macOS and Linux when possible
5. **User feedback**: Provide clear status messages with emoji indicators (✅/⚠️)
6. **No destructive operations**: Scripts should be idempotent and safe to re-run
7. **Path management**: UV and other tools install to ~/.local/bin (already in PATH)
8. **Shell restart required**: Many installations require sourcing ~/.zshrc or restarting shell
