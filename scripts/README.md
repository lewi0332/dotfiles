# Modular Install Script Structure

## Overview
This is a modular approach to the dotfiles installation script, breaking apart the monolithic `install.sh` into smaller, focused modules.

## File Structure

```
dotfiles/
├── install_modular.sh          # Main orchestrator (run this)
├── scripts/
│   ├── detect_os.sh            # OS detection
│   ├── packages_common.sh      # Cross-platform packages (zsh, tmux, uv, ruff)
│   ├── packages_macos.sh       # macOS-specific (Homebrew, brew.sh)
│   ├── packages_linux.sh       # Linux-specific (neovim PPA, lazygit)
│   ├── fonts.sh                # Font installation (JetBrains Mono)
│   └── symlinks.sh             # Dotfile and config symlinks
├── brew.sh                     # macOS Homebrew packages (called by packages_macos.sh)
├── macOS.sh                    # macOS system config (called by packages_macos.sh)
└── [existing dotfiles...]
```

## Usage

### To install using the modular approach:
```bash
cd ~/dotfiles
chmod +x install_modular.sh scripts/*.sh
./install_modular.sh
```

### To test individual modules:
```bash
# Test just symlinks
source scripts/detect_os.sh
detect_os
source scripts/symlinks.sh
create_symlinks

# Test just fonts
source scripts/detect_os.sh
detect_os
source scripts/fonts.sh
install_fonts
```

## Benefits of This Approach

### ✅ Pros:
- **Modular**: Each script has a single responsibility
- **Testable**: Can run individual modules independently
- **Readable**: ~60 lines per module vs 285 lines in one file
- **Maintainable**: Easy to find and update specific functionality
- **Reusable**: Can call individual functions from other scripts
- **Clear separation**: OS-specific vs cross-platform code is obvious

### ⚠️ Cons:
- More files to manage (7 files vs 1)
- Requires sourcing scripts (slight overhead)
- Need to keep `install.sh` in sync if you keep both

## Migration Path

### Option 1: Replace entirely
```bash
mv install.sh install_old.sh
mv install_modular.sh install.sh
```

### Option 2: Keep both (recommended during transition)
- Keep `install.sh` as-is
- Test `install_modular.sh` on fresh systems
- Switch when confident

### Option 3: Hybrid approach
Keep `install.sh` but have it call the modular scripts:
```bash
# In install.sh
source scripts/detect_os.sh
detect_os
# ... etc
```

## Adding New Functionality

### To add a new package:
1. Edit appropriate script:
   - Both platforms: `packages_common.sh`
   - macOS only: `packages_macos.sh`
   - Linux only: `packages_linux.sh`

### To add a new symlink:
1. Edit `scripts/symlinks.sh`
2. Add to appropriate array (`files`, `configs`, or `config_files`)

### To add a new script module:
1. Create `scripts/new_module.sh`
2. Add function: `do_something() { ... }`
3. Source it in `install_modular.sh`
4. Call function in `main()` function

## Testing

Test on a fresh system or Docker container:
```bash
# Ubuntu
docker run -it --rm -v ~/dotfiles:/dotfiles ubuntu:latest bash
cd /dotfiles && ./install_modular.sh

# macOS (on actual Mac)
# Create new user account or VM
```

## Recommendation

Given your current install.sh is ~285 lines and growing:
- **Use the modular approach** if you plan to add more OS-specific features
- **Keep current approach** if you rarely modify the install script
- **Try modular first** and fall back to original if you don't like it

The modular approach will scale better as you add more tools, configurations, and platforms.
