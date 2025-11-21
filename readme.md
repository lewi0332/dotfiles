# Setup New Dev Machine

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
- Install Homebrew
  - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
  - 
- Install Node Version Manager (nvm)
  - sudo or brew install nvm

- Install UV
  - `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Install ruffn
  - `uv tool install ruff@latest`
  - 
- Install Python packages via pipx

  - `pipx install pre-commit`
  - `pipx install black`
  - `pipx install flake8`

- Install VSCode
  - Install extensions
    - Data Science
  - Settings sync

- Install Docker
- 
- Configure system preferences
  - cursor speed
  - trackpad settings
  - keyboard repeat rate

- zsh or bash setup
  - add to whichever shell is on the machine
  - add alias
    - `alias ll='ls -la'`
    - `alias gs='git status'`
    - `alias gp='git pull'`
    - `alias gc='git commit'`
    - `alias gco='git checkout'`
    - `alias gcm='git commit -m'`
    - `alias ..='cd ..'`
    - `alias ...='cd ../..'`
    - `alias c='clear'`
- Set up prompt theme

- create `bin` directory in home and add to PATH
  - `mkdir ~/bin`
  - add to bashrc or zshrc: `export PATH="$HOME/bin:$PATH"`
  - symlink custom scripts here for easy access



### notes 

- .zprofile?

.zprofile and `.bash_profile` are **login shell** configuration files. Here's when you'd want them:

**Purpose:**
- Run **once** when you log in (not for every new terminal window)
- Set up environment variables that should be available to all programs
- Configure PATH, system-wide settings, one-time initialization

**When they're loaded:**
- `.bash_profile` / .zprofile: Login shells (SSH login, initial terminal on macOS)
- .bashrc / .zshrc: Interactive non-login shells (every new terminal window/tab)

**Common use cases:**
- **PATH modifications** that should persist across all sessions
- **Environment variables** (API keys, default editors, language settings)
- **Starting SSH agents** or other background services once per login
- **macOS specific**: Terminal.app opens login shells by default, so .zprofile is often needed

**Do you need them?**
- **On Linux**: Usually not essential - most distros source .bashrc from `.bash_profile` already
- **On macOS**: More important - you might need .zprofile to set PATH and environment variables
- **Modern approach**: Many people put everything in .zshrc/.bashrc and skip the profile files

**For your dotfiles:** If you're keeping things simple and cross-platform, you might not need them. But if you have environment setup that should only run once per login session (not per terminal), they're useful.