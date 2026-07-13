#!/usr/bin/env bash
set -euo pipefail
TARGET_PLUGIN_DIR="${HOME}/.vim/pack/plugins/start/template-tool"
TARGET_TEMPLATES_DIR="${HOME}/.vim/template"
mkdir -p "$TARGET_PLUGIN_DIR" "$TARGET_TEMPLATES_DIR"
if [ -d "doc" ] && command -v vim &> /dev/null; then
    vim -u NONE -c "helptags doc/" -c "q"
fi
echo "Setup complete! Workspace ready inside $TARGET_TEMPLATES_DIR"
