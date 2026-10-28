# ============================================
# Super Personal Terminal Workstation Config
# ============================================

# 环境变量
export NOTES_VAULT="${NOTES_VAULT:-$HOME/Notes}"
export EDITOR="nvim"
export VISUAL="nvim"

# PATH：typeset -U 让重复条目自动合并，避免多次 source 后越堆越多
typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/.cargo/bin" $path)

# 确保笔记目录存在
[[ ! -d "$NOTES_VAULT" ]] && mkdir -p "$NOTES_VAULT/Daily"

# ============================================
# Starship Prompt
# ============================================
eval "$(starship init zsh)"

# ============================================
# Zoxide (智能目录跳转)
# ============================================
eval "$(zoxide init zsh)"

# ============================================
# FZF (模糊搜索)
# ============================================
if command -v fzf &> /dev/null; then
    # FZF 键绑定
    source <(fzf --zsh) 2>/dev/null || true
    
    # FZF Catppuccin Mocha 主题
    export FZF_DEFAULT_OPTS=" \
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    
    # 使用 fd 替代 find
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
fi

# ============================================
# 别名 (Aliases)
# ============================================

# Eza (ls 替代品)
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza --icons --long --group-directories-first'
    alias la='eza --icons --long --all --group-directories-first'
    alias lt='eza --icons --tree --level=2 --group-directories-first'
    alias tree='eza --icons --tree --group-directories-first'
fi

# Bat (cat 替代品)
# 注意：不要 alias less='bat'。bat 不接受 less 的参数（less -R 会 exit 2），
# 会让所有 `xxx | less -R` 直接报错。
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
fi

# Zoxide (cd 替代品)
if command -v zoxide &> /dev/null; then
    alias cd='z'
fi

# Git (基础命令，lazygit 更推荐用于复杂操作)
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# 快速编辑配置
alias zshconfig="$EDITOR ~/.zshrc"
alias zshreload="source ~/.zshrc"
alias dotfiles="cd $(dirname $(readlink ~/.zshrc || echo ~/.zshrc))/.."

# ============================================
# 工作区函数
# ============================================

# 启动工作区

# 快速笔记：打开或追加今日日记
note() {
    local daily_note="$NOTES_VAULT/Daily/$(date +%Y-%m-%d).md"
    
    if [[ ! -f "$daily_note" ]]; then
        cat > "$daily_note" <<EOF
# $(date +%Y-%m-%d)

EOF
    fi
    
    if [[ -n "$1" ]]; then
        echo "- $(date +%H:%M) $*" >> "$daily_note"
        echo "✅ 已添加到 $(basename "$daily_note")"
    else
        $EDITOR "$daily_note"
    fi
}

# 新建笔记
new() {
    if [[ -z "$1" ]]; then
        echo "用法: new <标题>" >&2
        return 1
    fi
    
    local title="$*"
    local filename="$(date +%Y%m%d)-${title// /-}.md"
    local filepath="$NOTES_VAULT/$filename"
    
    if [[ -f "$filepath" ]]; then
        echo "⚠️  文件已存在，直接打开"
    else
        cat > "$filepath" <<EOF
# $title

$(date +%Y-%m-%d)

---

EOF
        echo "✅ 已创建: $filename"
    fi
    
    $EDITOR "$filepath"
}

# 搜索笔记
search() {
    if [[ -z "$1" ]]; then
        echo "用法: search <关键词>" >&2
        return 1
    fi
    
    if command -v rg &> /dev/null; then
        rg --color=always --heading --line-number "$1" "$NOTES_VAULT"
    else
        grep -r "$1" "$NOTES_VAULT"
    fi
}

# CTF writeup（可选功能）
ctf() {
    if [[ -z "$1" ]]; then
        echo "用法: ctf <题目名称>" >&2
        return 1
    fi
    
    local ctf_name="$1"
    local filename="$(date +%Y%m%d)-${ctf_name}.md"
    local filepath="$NOTES_VAULT/CTF/$filename"
    local template="$HOME/.config/templates/ctf-writeup.md"
    
    if [[ ! -f "$filepath" ]]; then
        if [[ -f "$template" ]]; then
            sed "s/{{TITLE}}/$ctf_name/g; s/{{DATE}}/$(date +%Y-%m-%d)/g" "$template" > "$filepath"
        else
            cat > "$filepath" <<EOF
# $ctf_name

**日期**: $(date +%Y-%m-%d)

## 题目

## 思路

## 解法

\`\`\`bash

\`\`\`

## Flag

\`\`\`
FLAG{}
\`\`\`
EOF
        fi
        echo "✅ 已创建: $filename"
    fi
    
    $EDITOR "$filepath"
    
    # 可选：启动 CTF 布局
    # zellij --layout ctf attach -c "ctf-$ctf_name" 2>/dev/null || true
}

# ============================================
# History 配置
# ============================================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE      # 以空格开头的命令不进历史（贴 token 时用）
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY       # 记录时间戳，方便 history 回溯
setopt SHARE_HISTORY

# ============================================
# 自动补全
# ============================================
# 额外补全定义（需要 brew install zsh-completions）
[[ -d /opt/homebrew/share/zsh-completions ]] && fpath=(/opt/homebrew/share/zsh-completions $fpath)

# zstyle 必须写在 compinit 之前，否则不生效
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*:approximate:*' max-errors 2
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*' squeeze-slashes true

setopt AUTO_MENU COMPLETE_IN_WORD ALWAYS_TO_END

autoload -Uz compinit
compinit

# ============================================
# 欢迎信息
# ============================================
if [[ "$TERM_PROGRAM" != "vscode" ]] && [[ -z "$ZELLIJ" ]]; then
    printf '\n  \e[3;38;2;180;190;254mWhereof one cannot speak, thereof one must be silent.\e[0m\n'
    printf '  \e[38;2;108;112;134m— Ludwig Wittgenstein\e[0m\n\n'
fi

# ============================================
# 插件：灰字建议（→ 采纳）+ 命令高亮（放最后）
# ============================================
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# eza: Catppuccin Mocha 24-bit 配色（不受终端 palette 影响）
export EZA_COLORS="\
di=1;38;2;137;180;250:fi=38;2;205;214;244:ex=1;38;2;166;227;161:\
ln=1;38;2;148;226;213:or=1;38;2;243;139;168:pi=38;2;249;226;175:\
so=1;38;2;245;194;231:bd=1;38;2;250;179;135:cd=1;38;2;250;179;135:\
mp=1;38;2;203;166;247:sc=38;2;180;190;254:do=38;2;249;226;175:\
co=1;38;2;250;179;135:tm=38;2;108;112;134:cm=38;2;127;132;156:\
bu=38;2;203;166;247:cr=1;38;2;243;139;168:im=1;38;2;245;194;231:\
vi=1;38;2;203;166;247:mu=38;2;137;220;235:lo=38;2;148;226;213:\
sp=38;2;166;173;200:xx=38;2;108;112;134:da=38;2;147;153;178:\
sn=38;2;166;227;161:sb=38;2;166;227;161:uu=1;38;2;249;226;175:\
un=38;2;205;214;244:gu=38;2;186;194;222:lc=38;2;127;132;156:\
hd=1;38;2;205;214;244:lp=38;2;148;226;213:xa=38;2;249;226;175"

# ============================================
# TUI 日常化入口
# ============================================
# yazi：退出时 cd 到你在里面浏览的目录（缺这段 yazi 就只是个查看器）
function y() {
    local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

