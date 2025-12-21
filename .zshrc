# If not running zsh, don't do anything
if [ -z "$ZSH_VERSION" ]; then
    return
fi

autoload -Uz colors && colors
setopt PROMPT_SUBST

# Don't ask if user is sure when running rm with wildcards (like bash)
setopt rmstarsilent

# If wildcard pattern has no matches, return an empty string (like bash)
setopt no_nomatch

# History
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory          # Share command history across all open sessions
setopt hist_ignore_space     # Ignore commands that start with a space
setopt hist_reduce_blanks    # Remove superfluous blanks
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups


# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"


# Load dotfiles:
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# GitHub Copilot CLI shell integration
# eval "$(gh copilot alias -- zsh)"

# Dircolors (Linux only)
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/bin:$PATH"

export NVIM_APPNAME="kickstart"

unset-upstream() {
  local current_branch=$(git branch --show-current 2>/dev/null)

  if [[ -z "$current_branch" ]]; then
    echo "Not in a git repository"
    return 1
  fi

  if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
    echo "Cannot unset upstream for $current_branch branch"
    return 1
  fi

  git branch --unset-upstream && echo "Unset upstream for branch: $current_branch"
}

# starship prompt
eval "$(starship init zsh)"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

# Shell integrations
# fzf - fuzzy finder
if command -v fzf &> /dev/null; then
    # Try modern flag first (fzf 0.48.0+), fallback to key-bindings
    if fzf --zsh &> /dev/null; then
        eval "$(fzf --zsh)"
    elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
        source /usr/share/doc/fzf/examples/completion.zsh
    elif [ -f ~/.fzf.zsh ]; then
        source ~/.fzf.zsh
    fi
fi

# zoxide - smart cd
command -v zoxide &> /dev/null && eval "$(zoxide init --cmd cd zsh)"
