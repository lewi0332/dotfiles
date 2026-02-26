#!/usr/bin/env bash
# Create symlinks for dotfiles and config directories

create_symlinks() {
    echo "=== Creating Symlinks ==="
    
    # dotfiles directory
    local dotfiledir="${HOME}/dotfiles"
    
    # list of files/folders to symlink in home directory
    local files=(zshrc zprompt shared_prompt aliases tmux.conf)
    
    # change to the dotfiles directory
    echo "Changing to the ${dotfiledir} directory"
    cd "${dotfiledir}" || exit
    
    # create symlinks for dotfiles (safer approach - checks before overwriting)
    echo "Creating home directory symlinks..."
    for file in "${files[@]}"; do
        local source="${dotfiledir}/.${file}"
        local target="${HOME}/.${file}"
        
        # Special handling for .zshrc: preserve existing configs in .zshrc.local
        if [ "$file" = "zshrc" ]; then
            if [ -L "$target" ]; then
                echo "$target already exists as a symlink."
            elif [ -e "$target" ]; then
                echo "⚠️  Found existing $target - preserving it as ~/.zshrc.local"
                mv "$target" "${HOME}/.zshrc.local"
                ln -s "$source" "$target"
                echo "✅ Created symlink: $target -> $source"
                echo "   Your original configs are now in ~/.zshrc.local (auto-sourced)"
            else
                ln -s "$source" "$target"
                echo "✅ Created symlink: $target -> $source"
            fi
        else
            # Standard handling for other dotfiles
            if [ -L "$target" ]; then
                echo "$target already exists as a symlink."
            elif [ -e "$target" ]; then
                echo "⚠️  $target already exists as a regular file. Skipping."
            else
                ln -s "$source" "$target"
                echo "✅ Created symlink: $target -> $source"
            fi
        fi
    done
    
    # list of config directories to symlink
    local configs=(nvim-lab kickstart ruff)
    
    mkdir -p "${HOME}/.config"
    
    # create symlinks for config directories
    echo "Creating config directory symlinks..."
    for config in "${configs[@]}"; do
        local source="${dotfiledir}/${config}"
        local target="${HOME}/.config/${config}"
        
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
    local config_files=(starship.toml)
    
    # create symlinks for config files
    echo "Creating config file symlinks..."
    for config_file in "${config_files[@]}"; do
        local source="${dotfiledir}/${config_file}"
        local target="${HOME}/.config/${config_file}"
        
        if [ -L "$target" ]; then
            echo "$target already exists as a symlink."
        elif [ -e "$target" ]; then
            echo "⚠️  $target already exists as a file. Skipping."
        else
            ln -s "$source" "$target"
            echo "✅ Created symlink: $target -> $source"
        fi
    done

    # create symlink for bin directory
    echo "Creating bin directory symlink..."
    local bin_source="${dotfiledir}/bin"
    local bin_target="${HOME}/bin"

    if [ -L "$bin_target" ]; then
        echo "$bin_target already exists as a symlink."
    elif [ -e "$bin_target" ]; then
        echo "⚠️  $bin_target already exists. Merging scripts..."
        # Create symlinks for individual scripts if ~/bin exists
        for script in "${bin_source}"/*; do
            local script_name=$(basename "$script")
            local script_target="${bin_target}/${script_name}"
            if [ -L "$script_target" ] || [ -e "$script_target" ]; then
                echo "  ${script_name} already exists, skipping."
            else
                ln -s "$script" "$script_target"
                echo "  ✅ Created symlink: ${script_name}"
            fi
        done
    else
        ln -s "$bin_source" "$bin_target"
        echo "✅ Created symlink: $bin_target -> $bin_source"
    fi

    # create IPython startup symlink for vd popup magic
    local ipython_startup_dir="${HOME}/.ipython/profile_default/startup"
    local vd_source="${dotfiledir}/scripts/vd_popup.py"
    local vd_target="${ipython_startup_dir}/vd_popup.py"

    mkdir -p "${ipython_startup_dir}"

    echo "Creating IPython startup symlink..."
    if [ -L "$vd_target" ]; then
        echo "$vd_target already exists as a symlink."
    elif [ -e "$vd_target" ]; then
        echo "⚠️  $vd_target already exists as a regular file. Skipping."
    else
        ln -s "$vd_source" "$vd_target"
        echo "✅ Created symlink: $vd_target -> $vd_source"
    fi
}
