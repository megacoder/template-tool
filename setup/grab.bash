mkdir -p ~/.vim/pack/plugins/start/template-tool/plugin \
         ~/.vim/pack/plugins/start/template-tool/doc \
         ~/.vim/pack/plugins/start/template-tool/.github/workflows \
         ~/.vim/pack/plugins/start/template-tool/.github/release-drafter \
         ~/.vim/pack/plugins/start/template-tool/.github/issue_template \
         ~/.vim/template

cat << 'EOF' > ~/.vim/pack/plugins/start/template-tool/plugin/template_tool.vim
" vint: -ProhibitCommandWithUserDefinedPrefix
" vint: -ProhibitCommandRelyOnUserDefinedPrefix

if exists('g:loaded_template_tool') || !has('python3')
    finish
endif
let g:loaded_template_tool = 1

function! s:LoadTemplate()
    if line('$') > 1 || getline(1) != '' || &buftype != ''
        return
    endif
    python3 << EOP
import vim
from pathlib import Path
filename = vim.eval("expand('%:t')")
ext = vim.eval("expand('%:e')")
template_dir = Path("~/.vim/template/").expanduser()
exact = template_dir / filename
fallback = template_dir / f"%.{ext}"
target = exact if exact.exists() else (fallback if fallback.exists() else None)
if target:
    vim.command(f"silent execute '0read ' . fnameescape('{target}')")
    if vim.current.buffer[-1] == '':
        del vim.current.buffer[-1]
    vim.command("call s:ProcessPlaceholders()")
EOP
endfunction

function! s:ProcessPlaceholders()
    python3 << EOP
import vim, os, time
user = os.environ.get('USER') or os.environ.get('USERNAME') or 'Unknown'
date = time.strftime('%Y-%m-%d %H:%M:%S')
filename = vim.eval("expand('%:t')")
weather_report = "Unknown (Offline)"
if any('<[weather_live]>' in l for l in vim.current.buffer):
    try:
        import urllib.request
        with urllib.request.urlopen("https://wttr.in", timeout=2) as response:
            weather_report = response.read().decode('utf-8').strip()
    except Exception:
        weather_report = "Weather unavailable (Timeout)"
for i, line in enumerate(vim.current.buffer):
    line = line.replace('<[weather_live]>', weather_report)
    line = line.replace('<[user]>', user).replace('<[date]>', date).replace('<[filename]>', filename)
    vim.current.buffer[i] = line
for i, line in enumerate(vim.current.buffer):
    if '<[CURSOR]>' in line:
        col_idx = line.index('<[CURSOR]>')
        vim.current.buffer[i] = line.replace('<[CURSOR]>', '')
        vim.current.window.cursor = (i + 1, col_idx)
        vim.command("startinsert")
        break
EOP
endfunction

nnoremap <A-h> :call <SID>InjectHeaderBlock()<CR>
function! s:InjectHeaderBlock()
    python3 << EOP
import vim
row, col = vim.current.window.cursor
line = vim.current.line
indent = line[:len(line) - len(line.lstrip())]
del vim.current.buffer[row - 1]
block = [
    f"{indent}/*",
    f"{indent} *************************************************************",
    f"{indent} * ",
    f"{indent} *************************************************************",
    f"{indent} */"
]
baseline = max(0, row - 1)
vim.current.buffer.append(block, baseline)
vim.current.window.cursor = (baseline + 3, len(indent) + 3)
vim.command("startinsert")
EOP
endfunction

inoremap > ><Esc>:call <SID>CheckDynamicExpansion()<CR>
function! s:CheckDynamicExpansion()
    python3 << EOP
import vim, os, time, re
from pathlib import Path
line = vim.current.line
row, col = vim.current.window.cursor
col_offset = col - 1
match = re.search(r'<\[([^\]]+)\]>$', line[:col_offset])
if not match:
    vim.command("execute 'normal! a'")
else:
    match_str = match.group(0)
    var_name = match.group(1)
    ext = vim.eval("expand('%:e')")
    exp_file = Path(f"~/.vim/template/%.{ext}.{var_name}").expanduser()
    if not exp_file.exists():
        vim.command("execute 'normal! a'")
    else:
        exp_lines = exp_file.read_text().splitlines()
        user = os.environ.get('USER') or os.environ.get('USERNAME') or 'Unknown'
        date = time.strftime('%Y-%m-%d %H:%M:%S')
        filename = vim.eval("expand('%:t')")
        exp_lines = [l.replace('<[user]>', user).replace('<[date]>', date).replace('<[filename]>', filename) for l in exp_lines]
        cursor_row, cursor_col = -1, -1
        for i, l in enumerate(exp_lines):
            if '<[CURSOR]>' in l:
                cursor_row = i
                cursor_col = l.index('<[CURSOR]>')
                exp_lines[i] = l.replace('<[CURSOR]>', '')
                break
        start_idx = col_offset - len(match_str)
        prefix = line[:start_idx]
        suffix = line[col_offset:]
        indent = line[:len(line) - len(line.lstrip())]
        exp_lines = prefix + exp_lines
        if len(exp_lines) > 1:
            for i in range(1, len(exp_lines)):
                exp_lines[i] = indent + exp_lines[i]
        exp_lines[-1] = exp_lines[-1] + suffix
        vim.current.buffer[row - 1] = exp_lines
        if len(exp_lines) > 1:
            vim.current.buffer.append(exp_lines[1:], row - 1)
        if cursor_row != -1:
            f_line = row + cursor_row
            f_col = (len(prefix) + cursor_col) if cursor_row == 0 else (len(indent) + cursor_col)
        else:
            f_line = row + len(exp_lines) - 1
            f_col = len(exp_lines[-1]) - len(suffix)
        vim.current.window.cursor = (f_line, f_col)
        vim.command("startinsert")
EOP
endfunction

augroup PackTemplatesTool
    autocmd!
    autocmd BufNewFile,BufReadPost,BufEnter * call s:LoadTemplate()
    autocmd BufWinEnter * if expand('%') == '' | call s:LoadTemplate() | endif
augroup END

command! TemplatesToolStatus call s:PrintDiagnosticReport()
function! s:PrintDiagnosticReport()
    python3 << EOP
import vim, os
from pathlib import Path
user = os.environ.get('USER') or os.environ.get('USERNAME') or 'Unknown'
t_dir = Path("~/.vim/template/").expanduser()
ext = vim.eval("expand('%:e')")
filename = vim.eval("expand('%:t')")
print("==================================================")
print("       TEMPLATES-TOOL SYSTEM DIAGNOSTICS          ")
print("==================================================")
print(f"Runtime Engine:  Python {os.sys.version.split()} via Vim +python3")
print(f"Active User:     {user}")
print(f"Templates Path:  {t_dir} " + ("(FOUND)" if t_dir.exists() else "(MISSING!)"))
if t_dir.exists():
    all_files = list(t_dir.glob("*"))
    print(f"Total Snippets:  {len(all_files)} files loaded in directory")
    if filename:
        exact = t_dir / filename
        fallback = t_dir / f"%.{ext}" if ext else None
        print(f"Current File:    {filename}")
        if exact.exists():
            print(f"Matching Rule:   EXACT MATCH ({exact.name})")
        elif fallback and fallback.exists():
            print(f"Matching Rule:   FALLBACK MATCH ({fallback.name})")
        else:
            print("Matching Rule:   NONE (Buffer will remain empty)")
    else:
        print("Current File:    Unsaved/Unnamed Buffer")
print("==================================================")
EOP
endfunction
EOF
echo "Part 1 successfully written!"
