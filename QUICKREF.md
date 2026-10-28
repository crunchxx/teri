# 快速参考

## 安装命令

```bash
git clone <你的仓库> ~/dotfiles && cd ~/dotfiles && ./install.sh
```

## 核心命令

```bash
ws              # 启动工作区
note            # 打开今日笔记
note "想法"     # 快速追加
new "标题"      # 新建笔记
search "关键词" # 搜索笔记
```

## Zellij 快捷键

```
Ctrl+t      新标签页
Ctrl+w      关闭标签页
Ctrl+h/l    切换标签页
Ctrl+s      水平分割
Ctrl+v      垂直分割
Alt+hjkl    窗格导航
```

## 工作区布局

- **~** tab: 主工作区（干净的 shell）
- **notes** tab: Markdown 预览 + shell
- **code** tab: 编辑器 + lazygit

## 文件位置

- 配置: `~/dotfiles/config/`
- 笔记: `~/Notes/`
- 备份: `~/.dotfiles-backup-<日期>/`
