#!/usr/bin/env bash

# Stop execution immediately on error
set -e

# Default values
AGENT="both"
INSTALL_TYPE="local"
TARGET_DIR="$(pwd)"
# Detect if script is run via curl or locally
if [ -n "$BASH_SOURCE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    # Fallback for piped execution (curl | bash)
    # This script assumes it's being run from a cloned repo or a specific directory
    SCRIPT_DIR="$(pwd)"
fi

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --agent) AGENT="$2"; shift ;;
        --global) INSTALL_TYPE="global"; ;;
        --local) INSTALL_TYPE="local"; ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

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
