#!/usr/bin/env bash

# Stop execution immediately on error
set -e

# Get the directory where this script is located (i.e., the sdd-skills submodule directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default target directory is the current working directory where the script is executed
TARGET_DIR="$(pwd)"

# Check if executed inside the submodule directory, remind user to run at repo root
if [ "$SCRIPT_DIR" = "$TARGET_DIR" ]; then
    echo "⚠️ WARNING: You are currently running this script inside the sdd-skills directory."
    echo "Please run this script from your project root (repo root)."
    echo "Example: ./sdd-skills/install.sh --agent claude"
    exit 1
fi

AGENT=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --agent) AGENT="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Check if agent parameter is valid
if [[ "$AGENT" != "gemini" && "$AGENT" != "claude" ]]; then
    echo "Usage: $0 --agent [gemini|claude]"
    exit 1
fi

echo "🚀 Starting SDD Skills installation (Target Agent: $AGENT)..."

if [[ "$AGENT" == "claude" ]]; then
    # Detect and create .claude folder
    if [ ! -d "$TARGET_DIR/.claude" ]; then
        echo "📁 Creating .claude directory..."
        mkdir -p "$TARGET_DIR/.claude"
    fi

    # Copy .claude/commands/* to repo's .claude/commands/
    echo "📦 Copying commands..."
    mkdir -p "$TARGET_DIR/.claude/commands"
    cp -R "$SCRIPT_DIR/.claude/commands/"* "$TARGET_DIR/.claude/commands/"

    # Copy agents/ to repo's .claude/agents/
    echo "🤖 Copying agents..."
    mkdir -p "$TARGET_DIR/.claude/agents"
    cp -R "$SCRIPT_DIR/agents/"* "$TARGET_DIR/.claude/agents/"

    # Copy skills/ to repo's .claude/skills/
    echo "🛠️ Copying skills..."
    mkdir -p "$TARGET_DIR/.claude/skills"
    cp -R "$SCRIPT_DIR/skills/"* "$TARGET_DIR/.claude/skills/"

    # Copy AGENT.md to repo root
    echo "📄 Copying AGENT.md to project root..."
    cp "$SCRIPT_DIR/AGENT.md" "$TARGET_DIR/AGENT.md"
    
    echo "✅ Claude Code installation complete!"

elif [[ "$AGENT" == "gemini" ]]; then
    # Detect and create .gemini folder
    if [ ! -d "$TARGET_DIR/.gemini" ]; then
        echo "📁 Creating .gemini directory..."
        mkdir -p "$TARGET_DIR/.gemini"
    fi

    # Gemini does not need agent, AGENT.md, commands use the outer ones
    echo "📦 Copying commands..."
    mkdir -p "$TARGET_DIR/.gemini/commands"
    # Use the outer commands folder
    cp -R "$SCRIPT_DIR/commands/"* "$TARGET_DIR/.gemini/commands/"

    # Copy skills/ to repo's .gemini/skills/ 
    # (skills similarly)
    echo "🛠️ Copying skills..."
    mkdir -p "$TARGET_DIR/.gemini/skills"
    cp -R "$SCRIPT_DIR/skills/"* "$TARGET_DIR/.gemini/skills/"

    echo "✅ Gemini installation complete!"
fi
