#!/usr/bin/env bash
set -euo pipefail
PLUGIN_DIR="${HOME}/.vim/pack/plugins/start/template-tool"
TEMPLATES_DIR="${HOME}/.vim/template"
read -p "Uninstall template-tool plugin? (y/N): " -r confirm
if [[ "$confirm" =~ ^[Yy]$ ]] && [ -d "$PLUGIN_DIR" ]; then
    rm -rf "$PLUGIN_DIR"
    echo "Plugin code removed."
fi
