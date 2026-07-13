cat << 'EOF' > ~/.vim/pack/plugins/start/template-tool/doc/template-tool.txt
*template-tool.txt*  A Python-backed template engine with dynamic nesting support.
==============================================================================
TEMPLATES-TOOL MANUAL                                         *template-tool*
An automated templating engine leveraging the +python3 interface for fast,
clean variable evaluation and macro expansions.
                                CONTENTS |template-tool-contents|
        1. Setup & Layout...................|template-tool-paths|
        2. Automatic Buffers................|template-tool-auto|
        3. Hotkey Header Macro..............|template-tool-hotkey|
        4. Dynamic Custom Nesting...........|template-tool-nesting|
==============================================================================
1. SETUP & LAYOUT                                       *template-tool-paths*
All skeleton layout configuration template are evaluated directly out of:
   ~/.vim/template/
Priority fallback check rules match exact filenames, then generic extensions:
1. template/filename.ext (e.g. main.c)
2. template/%.ext (e.g. %.c)
==============================================================================
2. AUTOMATIC BUFFERS                                     *template-tool-auto*
When opening a matching clean file layout workspace, these variables resolve:
   <[user]>        Active system user environment identification string
   <[date]>        Current operational timestamp (YYYY-MM-DD HH:MM:SS)
   <[filename]>    Name of the current working file target
   <[CURSOR]>      Sets the precise cursor position and boots Insert mode
==============================================================================
2.1 DIAGNOSTICS INSPECTOR                              *template-tool-status*
To quickly verify configuration mapping arrays, run the diagnostic dashboard:
   :TemplatesToolStatus
==============================================================================
3. HOTKEY HEADER MACRO                                 *template-tool-hotkey*
Normal mode: Pressing <ALT-h> replaces the active line with a multi-line
comment box layout, matching structural nested leading tabs or spaces natively.
==============================================================================
4. DYNAMIC CUSTOM NESTING                             *template-tool-nesting*
Insert Mode: Typing custom macros pulls fragments dynamically out of
~/.vim/template/%.ext.custom files, resolving nesting variables.
==============================================================================
vim:tw=78:ts=8:ft=help:norl:
EOF

cat << 'EOF' > ~/.vim/pack/plugins/start/template-tool/README.md
# Templates Tool for Vim
A fast, lightweight file templating system built natively using Vim's Python 3 interface.
EOF

cat << 'EOF' > ~/.vim/pack/plugins/start/template-tool/install.sh
#!/usr/bin/env bash
set -euo pipefail
TARGET_PLUGIN_DIR="${HOME}/.vim/pack/plugins/start/template-tool"
TARGET_TEMPLATES_DIR="${HOME}/.vim/template"
mkdir -p "$TARGET_PLUGIN_DIR" "$TARGET_TEMPLATES_DIR"
if [ -d "doc" ] && command -v vim &> /dev/null; then
    vim -u NONE -c "helptags doc/" -c "q"
fi
echo "Setup complete! Workspace ready inside $TARGET_TEMPLATES_DIR"
EOF

cat << 'EOF' > ~/.vim/pack/plugins/start/template-tool/uninstall.sh
#!/usr/bin/env bash
set -euo pipefail
PLUGIN_DIR="${HOME}/.vim/pack/plugins/start/template-tool"
TEMPLATES_DIR="${HOME}/.vim/template"
read -p "Uninstall template-tool plugin? (y/N): " -r confirm
if [[ "$confirm" =~ ^[Yy]$ ]] && [ -d "$PLUGIN_DIR" ]; then
    rm -rf "$PLUGIN_DIR"
    echo "Plugin code removed."
fi
EOF

chmod +x ~/.vim/pack/plugins/start/template-tool/install.sh
chmod +x ~/.vim/pack/plugins/start/template-tool/uninstall.sh
echo "Part 2 successfully written!"
