#!/usr/bin/env bash
# ============================================
# Super Personal Terminal Workstation Installer
# ============================================
# 幂等式安装脚本 - 可安全重复运行
# 支持 macOS (Apple Silicon & Intel)

set -euo pipefail

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ============================================
# 辅助函数
# ============================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# 检查是否为 macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "此脚本仅支持 macOS"
        exit 1
    fi
}

# 检查并安装 Homebrew
install_homebrew() {
    log_info "检查 Homebrew..."
    
    if command -v brew &> /dev/null; then
        log_success "Homebrew 已安装"
        return 0
    fi
    
    log_info "安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 配置 Homebrew 环境变量 (Apple Silicon)
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    fi
    
    log_success "Homebrew 安装完成"
}

# 安装 Homebrew 包
install_packages() {
    log_info "安装软件包..."
    
    if [[ ! -f "$SCRIPT_DIR/Brewfile" ]]; then
        log_error "Brewfile 未找到"
        exit 1
    fi
    
    brew bundle --file="$SCRIPT_DIR/Brewfile" || log_warning "部分软件包安装失败，继续..."
    
    # 尝试安装 carbonyl (可能不可用)
    if ! brew list carbonyl &> /dev/null; then
        log_info "尝试安装 carbonyl (终端浏览器)..."
        brew install carbonyl 2>/dev/null || log_warning "carbonyl 不可用，已安装 w3m 作为备选"
    fi
    
    log_success "软件包安装完成"
}

# 备份现有文件
backup_file() {
    local file="$1"
    
    if [[ -e "$file" ]] && [[ ! -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        local filename
        filename="$(basename "$file")"
        cp -r "$file" "$BACKUP_DIR/$filename"
        log_info "已备份: $file -> $BACKUP_DIR/$filename"
    fi
}

# 创建符号链接
create_symlink() {
    local source="$1"
    local target="$2"
    
    # 备份现有文件
    backup_file "$target"
    
    # 删除现有符号链接或文件
    if [[ -L "$target" ]]; then
        rm "$target"
    elif [[ -e "$target" ]]; then
        rm -rf "$target"
    fi
    
    # 创建目标目录
    mkdir -p "$(dirname "$target")"
    
    # 创建符号链接
    ln -sf "$source" "$target"
    log_success "已链接: $target -> $source"
}

# 配置符号链接
setup_symlinks() {
    log_info "配置符号链接..."
    
    # Ghostty
    create_symlink "$SCRIPT_DIR/config/ghostty" "$HOME/.config/ghostty"
    
    # Zellij
    create_symlink "$SCRIPT_DIR/config/zellij" "$HOME/.config/zellij"
    
    # Starship
    create_symlink "$SCRIPT_DIR/config/starship.toml" "$HOME/.config/starship.toml"
    
    # Yazi
    create_symlink "$SCRIPT_DIR/config/yazi" "$HOME/.config/yazi"
    
    # Lazygit
    create_symlink "$SCRIPT_DIR/config/lazygit" "$HOME/.config/lazygit"
    
    # Bat
    create_symlink "$SCRIPT_DIR/config/bat" "$HOME/.config/bat"
    
    # Zsh
    create_symlink "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
    
    # Templates
    create_symlink "$SCRIPT_DIR/templates" "$HOME/.config/templates"
    
    log_success "符号链接配置完成"
}

# 安装 LazyVim
install_lazyvim() {
    log_info "配置 Neovim (LazyVim)..."
    
    local nvim_config="$HOME/.config/nvim"
    
    if [[ -d "$nvim_config" ]]; then
        log_warning "Neovim 配置已存在，跳过安装"
        log_info "如需重新安装，请先备份并删除: $nvim_config"
        return 0
    fi
    
    log_info "安装 LazyVim starter..."
    backup_file "$nvim_config"
    
    git clone https://github.com/LazyVim/starter "$nvim_config"
    rm -rf "${nvim_config}/.git"
    
    log_success "LazyVim 安装完成"
    log_info "首次启动 nvim 时会自动安装插件"
}

# 创建笔记目录结构
setup_notes() {
    log_info "创建笔记目录..."
    
    local notes_dir="${NOTES_VAULT:-$HOME/Notes}"
    
    mkdir -p "$notes_dir/Daily"
    
    if [[ ! -f "$notes_dir/README.md" ]]; then
        cat > "$notes_dir/README.md" <<'EOF'
# 笔记

个人 Markdown 笔记库。

## 快速开始

```bash
note              # 打开今日笔记
note "想法"       # 快速追加
new "项目计划"    # 新建笔记
search "关键词"   # 搜索
```

EOF
    fi
    
    log_success "笔记目录创建完成: $notes_dir"
}

# 配置 Zsh
setup_zsh() {
    log_info "配置 Zsh..."
    
    # 设置 Zsh 为默认 Shell
    if [[ "$SHELL" != "$(command -v zsh)" ]]; then
        log_info "设置 Zsh 为默认 shell..."
        chsh -s "$(command -v zsh)"
        log_success "已设置 Zsh 为默认 shell (需要重新登录生效)"
    fi
}

# 安装 bat 主题
install_bat_themes() {
    log_info "配置 bat 主题..."
    
    # Bat 会自动下载主题，首次运行时构建缓存
    bat cache --build &> /dev/null || true
    
    log_success "bat 主题配置完成"
}

# 验证安装
verify_installation() {
    log_info "验证安装..."
    
    local missing_tools=()
    local tools=(ghostty zellij starship nvim yazi lazygit rg fd fzf bat eza zoxide glow btop)
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_warning "以下工具未安装: ${missing_tools[*]}"
        log_info "请检查 Homebrew 安装日志"
    else
        log_success "所有核心工具已安装"
    fi
}

# 打印完成信息
print_completion_message() {
    echo ""
    echo -e "${GREEN}✨ 极简工作台安装完成${NC}"
    echo ""
    echo -e "${BLUE}下一步:${NC}"
    echo ""
    echo -e "  1. 重启终端: ${YELLOW}source ~/.zshrc${NC}"
    echo -e "  2. 启动 Ghostty"
    echo -e "  3. 运行 ${YELLOW}ws${NC}"
    echo ""
    echo -e "${BLUE}常用命令:${NC}"
    echo ""
    echo -e "  ${YELLOW}ws${NC}              启动工作区"
    echo -e "  ${YELLOW}note [text]${NC}     今日笔记"
    echo -e "  ${YELLOW}new <title>${NC}     新建笔记"
    echo ""
    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "${BLUE}备份:${NC} $BACKUP_DIR"
        echo ""
    fi
    echo -e "文档: ${YELLOW}cat README.md${NC}"
    echo ""
}

# ============================================
# 主函数
# ============================================

main() {
    echo ""
    echo "🚀 Super Personal Terminal Workstation Installer"
    echo "=================================================="
    echo ""
    
    check_macos
    install_homebrew
    install_packages
    setup_symlinks
    install_lazyvim
    setup_notes
    setup_zsh
    install_bat_themes
    verify_installation
    print_completion_message
}

main "$@"
