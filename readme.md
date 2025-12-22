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
chmod +x install.sh scripts/*.sh
./install.sh
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

# Setup New Machine

This is my personal guide to setting up a new machine. It includes all the necessary steps and configurations to get necessary tools and environments up and running quickly.

## Todo

- Install Git
  - on mac - `xcode-select --install`
  - on linux - `sudo apt update && sudo apt install git`

  - Set up SSH keys
  - check for existing keys: `ls -al ~/.ssh`
  - generate key: `ssh-keygen -t ed25519 -C "name@email.com"`
  - SSH eval agent: `eval "$(ssh-agent -s)"`
  - SSH add: `ssh-add ~/.ssh/id_ed25519`
  - copy the public key: `cat ~/.ssh/id_ed25519.pub`
  - Add to GitHub/GitLab/Bitbucket
  - Configure global username and email
    - `git config --global user.name "Your Name"`
    - `git config --global user.email "your.email@example.com"`

- Install VSCode
  - Install extensions
    - Data Science
  - Settings sync

- Install Docker

- Configure system preferences
  - cursor speed
  - trackpad settings
  - keyboard repeat rate


### TMUX 

After installing... The tmux plugins need to be installed manually the first time.
- Launch tmux: `tmux`
- Press `prefix` + `I` (capital i, as in Install) to fetch the plugins.