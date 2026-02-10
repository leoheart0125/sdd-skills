#!/bin/bash

# SDD Initialization Script
# Creates the .sdd directory structure and initializes context

set -e

SDD_ROOT=".sdd"
SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Initializing SDD environment in $SDD_ROOT..."

# Create directory structure
directories=(
    "$SDD_ROOT/spec"
    "$SDD_ROOT/plan"
    "$SDD_ROOT/context"
    "$SDD_ROOT/data"
    "$SDD_ROOT/logs"
    "$SDD_ROOT/temp"
)

for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "Created directory: $dir"
    else
        echo "Directory exists: $dir"
    fi
done

# Copy templates
if [ ! -f "$SDD_ROOT/context/context.json" ]; then
    if [ -f "$SKILL_ROOT/templates/context.json" ]; then
        cp "$SKILL_ROOT/templates/context.json" "$SDD_ROOT/context/context.json"
        echo "Initialized context.json"
    else
        echo "Warning: Template context.json not found in $SKILL_ROOT/templates/"
    fi
else
    echo "context.json already exists"
fi

if [ ! -f "$SDD_ROOT/context/project_rules.md" ]; then
    if [ -f "$SKILL_ROOT/templates/project_rules.md" ]; then
        cp "$SKILL_ROOT/templates/project_rules.md" "$SDD_ROOT/context/project_rules.md"
        echo "Initialized project_rules.md"
    else
        echo "Warning: Template project_rules.md not found in $SKILL_ROOT/templates/"
    fi
else
    echo "project_rules.md already exists"
fi

echo "SDD initialization complete."
