#!/usr/bin/env bash
# Detect operating system

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="linux"
    fi
    echo "Detected OS: ${OS}"
    export OS
}
