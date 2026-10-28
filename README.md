# ✨ 极简个人工作台

> 一个低摩擦的终端工作环境，专为日常笔记、轻松编码和浏览而设计

将你的 Mac 变成一个安静、优雅、键盘驱动的工作空间。没有复杂功能，只有你需要的核心工具。

## 🎯 设计理念

- **极简主义**: 只包含真正有用的工具
- **低摩擦**: 一条命令启动，零配置开始工作
- **键盘驱动**: 最小化鼠标使用
- **视觉统一**: Catppuccin Mocha 主题贯穿所有工具

## 📦 核心工具

- **Ghostty** - 现代 GPU 终端
- **Zellij** - 友好的终端多路复用器
- **Starship** - 极速提示符
- **Neovim + LazyVim** - 现代化编辑器
- **fzf / zoxide** - 模糊搜索和智能跳转
- **eza / bat / glow** - 美化日常命令
- **lazygit** - Git 可视化管理

## 🚀 快速开始

### 安装（三步）

```bash
# 1. 克隆仓库
git clone <你的仓库地址> ~/dotfiles
cd ~/dotfiles

# 2. 运行安装脚本
./install.sh

# 3. 重新加载配置
source ~/.zshrc
```

### 首次使用

```bash
# 启动 Ghostty，然后：
ws        # 启动极简工作区
```

首次打开 `nvim` 会自动安装插件，等待 1-2 分钟即可。

## 💡 日常使用

```bash
# 工作区
ws                    # 启动工作区（3 个标签页：主页、笔记、代码）

# 笔记
note                  # 打开今日笔记
note "记录一个想法"   # 快速追加到今日笔记
new "项目计划"        # 新建笔记
search "关键词"       # 搜索笔记

# 目录跳转（智能记忆）
z notes               # 跳转到笔记目录
z project             # 跳转到项目

# 美化命令
ls / ll / lt          # 美化列表 (eza)
cat file.md           # 高亮查看 (bat)
```

## 🎨 工作区布局

```
╭──────────────────────────────────────────╮
│  [~]  [notes]  [code]                    │
├──────────────────────────────────────────┤
│                                          │
│  ~ 标签页：干净的 shell                  │
│                                          │
│  notes 标签页：Markdown 预览 + shell    │
│                                          │
│  code 标签页：编辑器 + lazygit           │
│                                          │
╰──────────────────────────────────────────╯
```

安静、清爽、不繁忙。

## ⌨️ 关键快捷键

### Zellij

```
Ctrl + t        新标签页
Ctrl + w        关闭标签页
Ctrl + h/l      切换标签页
Ctrl + s/v      分割窗格
Alt + hjkl      窗格导航
```

### Neovim 入门

```
i               进入编辑模式
Esc             退出到普通模式
:w              保存
:q              退出
Space + e       文件树 (LazyVim)
Space + ff      查找文件 (LazyVim)
```

不熟悉 Vim？运行 `vimtutor` 学习基础（20 分钟）。

### lazygit

```
Space           Stage 文件
c               Commit
P               Push
Enter           查看详情
Tab             切换面板
q               退出
```

## 🔧 自定义

所有配置都通过符号链接，直接修改仓库文件即可：

```
~/dotfiles/
├── config/
│   ├── ghostty/config      # 终端外观
│   ├── zellij/config.kdl   # 布局和快捷键
│   ├── starship.toml       # 提示符
│   └── ...
└── zsh/.zshrc              # Shell 配置和命令
```

### 常见自定义

**更改笔记目录**:
```bash
# 编辑 ~/.zshrc
export NOTES_VAULT="$HOME/Documents/Notes"
```

**添加 AI 编码工具**:
```bash
# 编辑 Brewfile，取消注释：
brew "cursor"
# 或
brew "aider-chat/aider/aider"
```

**更改主题**: 统一使用 Catppuccin Mocha，如需更换需同步修改所有配置文件中的颜色。

## 📚 Git 基础

如果你不熟悉 git，这里是完整工作流：

### 首次推送到 GitHub

```bash
# 1. 在 GitHub 创建私有仓库（网页操作）

# 2. 关联并推送
cd ~/dotfiles
git remote add origin https://github.com/你的用户名/dotfiles.git
git add .
git commit -m "初始配置"
git push -u origin main
```

### 日常同步

```bash
# 修改配置后
cd ~/dotfiles
git add .
git commit -m "更新配置"
git push
```

### 在新电脑使用

```bash
git clone https://github.com/你的用户名/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## 🗑️ 卸载

安装脚本会自动备份原有配置到 `~/.dotfiles-backup-<日期>/`。

**恢复备份**:
```bash
ls -la ~ | grep dotfiles-backup
cp ~/.dotfiles-backup-XXXXXX/.zshrc ~/.zshrc
```

**完全移除**:
```bash
# 删除符号链接
rm ~/.zshrc
rm -rf ~/.config/{ghostty,zellij,starship.toml,yazi,lazygit,bat,nvim,templates}

# 卸载软件（可选）
brew bundle --file=~/dotfiles/Brewfile --force --cleanup

# 删除仓库
rm -rf ~/dotfiles
```

## 🐛 常见问题

**Neovim 插件未安装**: 首次打开 `nvim` 后等待自动安装，或手动运行 `:Lazy sync`

**字体显示异常**: 确保安装了 Nerd Font：`brew install --cask font-jetbrains-mono-nerd-font`

**Homebrew 找不到（Apple Silicon）**: 运行 `eval "$(/opt/homebrew/bin/brew shellenv)"`

## 🧩 可选功能

### CTF Writeup 工作流

如果你偶尔需要 CTF writeup，已内置支持：

```bash
ctf web-challenge    # 创建 writeup 模板
```

模板位于 `~/dotfiles/templates/ctf-writeup.md`，可自行修改。

---

**享受你的极简工作台** ✨

简单、安静、专注。
