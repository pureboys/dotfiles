# Dotfiles

跨平台 Cursor / Windsurf 配置同步仓库，支持 macOS、Linux、Windows。

## 目录结构

```
dotfiles/
├── cursor/
│   ├── settings.json      # 编辑器设置
│   ├── keybindings.json   # 快捷键配置
│   └── extensions.txt     # 插件列表
├── windsurf/
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt
└── scripts/
    ├── install.sh         # macOS/Linux 安装脚本
    ├── install.ps1        # Windows 安装脚本
    ├── export.sh          # macOS/Linux 导出脚本
    └── export.ps1         # Windows 导出脚本
```

## 快速开始

### 新机器恢复配置

**macOS / Linux:**
```bash
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles/scripts
chmod +x install.sh
./install.sh              # 安装全部
./install.sh cursor       # 只安装 Cursor
./install.sh windsurf     # 只安装 Windsurf
```

**Windows (PowerShell):**
```powershell
git clone git@github.com:YOUR_USERNAME/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles\scripts
.\install.ps1             # 安装全部
.\install.ps1 -Target cursor    # 只安装 Cursor
.\install.ps1 -Target windsurf  # 只安装 Windsurf
```

### 导出当前配置

当你在某台机器上修改了配置，导出并同步：

**macOS / Linux:**
```bash
cd ~/dotfiles/scripts
./export.sh               # 导出全部
./export.sh cursor        # 只导出 Cursor

# 提交更改
cd ~/dotfiles
git add -A
git commit -m "update cursor config"
git push
```

**Windows (PowerShell):**
```powershell
cd $HOME\dotfiles\scripts
.\export.ps1
cd $HOME\dotfiles
git add -A
git commit -m "update cursor config"
git push
```

## 配置文件路径

| 系统 | Cursor | Windsurf |
|------|--------|----------|
| macOS | `~/Library/Application Support/Cursor/User/` | `~/Library/Application Support/Windsurf/User/` |
| Linux | `~/.config/Cursor/User/` | `~/.config/Windsurf/User/` |
| Windows | `%APPDATA%\Cursor\User\` | `%APPDATA%\Windsurf\User\` |

## CLI 安装

确保编辑器的 CLI 工具在 PATH 中：

- **Cursor**: 打开 Cursor → `Cmd/Ctrl+Shift+P` → "Install 'cursor' command in PATH"
- **Windsurf**: 打开 Windsurf → `Cmd/Ctrl+Shift+P` → "Install 'windsurf' command in PATH"

## 工作流

```
机器 A (修改配置)           GitHub              机器 B (同步配置)
      │                       │                       │
      │  ./export.sh          │                       │
      ├──────────────────────►│                       │
      │  git push             │                       │
      │                       │    git pull           │
      │                       │◄──────────────────────┤
      │                       │    ./install.sh       │
      │                       │                       │
```

## 注意事项

- 安装前会自动备份现有配置到 `*.backup.时间戳` 目录
- 插件安装失败不会中断整体流程
- 敏感信息（API keys 等）不要放在 settings.json 中
