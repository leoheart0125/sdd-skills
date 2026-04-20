#!/usr/bin/env bash

# Stop execution immediately on error
set -e

# Default values
AGENT="both"
INSTALL_TYPE="local"
REPO_URL="https://github.com/leoheart0125/sdd-skills"
REPO_BRANCH="main"

# Detect if script is run via curl or locally
if [ -z "${BASH_SOURCE[0]}" ]; then
    echo "🌐 Running via curl. Fetching source from GitHub..."
    TMP_DIR=$(mktemp -d)
    curl -sL "$REPO_URL/archive/refs/heads/$REPO_BRANCH.tar.gz" | tar xz -C "$TMP_DIR" --strip-components=1
    SCRIPT_DIR="$TMP_DIR"
    TRAP_CLEANUP="true"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TRAP_CLEANUP="false"
fi

cleanup() {
    if [ "$TRAP_CLEANUP" == "true" ]; then
        rm -rf "$TMP_DIR"
    fi
}
trap cleanup EXIT

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --agent) 
            if [[ -n "$2" && ! "$2" == --* ]]; then
                AGENT="$2"
                shift
            else
                echo "❌ Error: --agent requires a value (claude, gemini, or both)"
                exit 1
            fi
            ;;
        --global) INSTALL_TYPE="global" ;;
        --local) INSTALL_TYPE="local" ;;
        -h|--help)
            echo "Usage: install.sh [--agent claude|gemini|both] [--global|--local]"
            exit 0
            ;;
        *) echo "❌ Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate AGENT
if [[ "$AGENT" != "claude" && "$AGENT" != "gemini" && "$AGENT" != "both" ]]; then
    echo "❌ Error: Invalid agent type '$AGENT'. Must be 'claude', 'gemini', or 'both'."
    exit 1
fi

TARGET_DIR="$(pwd)"
if [ "$INSTALL_TYPE" == "global" ]; then
    TARGET_DIR="$HOME"
fi

echo "🚀 Starting SDD Skills installation (Target: $INSTALL_TYPE, Agent: $AGENT)..."

# Function to install Claude resources
install_claude() {
    local dest="$TARGET_DIR/.claude"
    echo "📁 Preparing .claude directory at $dest..."
    mkdir -p "$dest/commands" "$dest/agents" "$dest/skills"

    echo "📦 Copying Claude resources..."
    cp -R "$SCRIPT_DIR/.claude/commands/"* "$dest/commands/"
    cp -R "$SCRIPT_DIR/.claude/agents/"* "$dest/agents/"
    cp -R "$SCRIPT_DIR/skills/"* "$dest/skills/"

    if [ "$INSTALL_TYPE" == "local" ]; then
        if [ -f "$SCRIPT_DIR/.claude/CLAUDE.md" ]; then
            echo "📄 Copying CLAUDE.md to project root..."
            cp "$SCRIPT_DIR/.claude/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
        fi
    fi
}

# Function to install Gemini resources
install_gemini() {
    local dest="$TARGET_DIR/.gemini"
    echo "📁 Preparing .gemini directory at $dest..."
    mkdir -p "$dest/commands" "$dest/agents" "$dest/skills"

    echo "📦 Copying Gemini resources..."
    cp -R "$SCRIPT_DIR/.gemini/commands/"* "$dest/commands/"
    cp -R "$SCRIPT_DIR/.gemini/agents/"* "$dest/agents/"
    cp -R "$SCRIPT_DIR/skills/"* "$dest/skills/"

    if [ "$INSTALL_TYPE" == "local" ]; then
        if [ -f "$SCRIPT_DIR/.gemini/GEMINI.md" ]; then
            echo "📄 Copying GEMINI.md to project root..."
            cp "$SCRIPT_DIR/.gemini/GEMINI.md" "$TARGET_DIR/GEMINI.md"
        fi
    fi
}

if [[ "$AGENT" == "claude" || "$AGENT" == "both" ]]; then
    install_claude
fi

if [[ "$AGENT" == "gemini" || "$AGENT" == "both" ]]; then
    install_gemini
fi

echo "✅ Installation complete!"
