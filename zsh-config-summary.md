# Zsh 配置总结

> 生成时间: 2026-06-25 / macOS (darwin) / Shell: /bin/zsh

---

## 1. 框架与主题

| 项目 | 值 |
|------|-----|
| 框架 | **Oh My Zsh** (`$ZSH=$HOME/.oh-my-zsh`) |
| 主题 | **Powerlevel10k** (rainbow, nerdfont-v3, powerline 风格, 单行, angled separators) |
| 主题路径 | `~/.oh-my-zsh/custom/themes/powerlevel10k` |
| P10k 配置 | `~/.p10k.zsh` (2026-03-03 生成) |
| P10k 模式 | `nerdfont-v3`, 左: `dir` `vcs`, 右: `status` `command_execution_time` `background_jobs` 等 |

---

## 2. Oh My Zsh 插件

### .zshrc 中启用的插件

```zsh
plugins=(
  zsh-autosuggestions       # 历史命令灰色提示, 按 → 补全
  zsh-syntax-highlighting   # 命令语法高亮 (绿色=有效, 红色=无效)
  zsh-vi-mode               # vim 模式 (esc 进入 normal 模式, insert 模式编辑)
)
```

### 自定义插件 (已安装)

| 插件 | 路径 | 版本/日期 |
|------|------|-----------|
| `zsh-autosuggestions` | `~/.oh-my-zsh/custom/plugins/zsh-autosuggestions` | 2025-06-24 |
| `zsh-syntax-highlighting` | `~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting` | 2026-02-28 |
| `zsh-vi-mode` | `~/.oh-my-zsh/custom/plugins/zsh-vi-mode` | 2026-01-14 |

---

## 3. Homebrew 安装的 Zsh 相关包

| 包名 | 功能 |
|------|------|
| `fzf` | 模糊搜索 (Ctrl+T 文件, Ctrl+R 历史, Alt+C 目录) |
| `zsh-autocomplete` | 已安装但**未**在 .zshrc plugins 数组中启用 |

> 注: `fzf` 的 key-bindings 和 completion 文件位于 `/opt/homebrew/opt/fzf/shell/`, 但 .zshrc 中未显式 source。Oh My Zsh 有内置 `fzf` 插件但未启用。

---

## 4. 语言与工具版本管理器

| 工具 | 配置方式 |
|------|----------|
| **NVM** (Node) | `~/.nvm/nvm.sh`, .zshrc `plugins` 为 oh-my-zsh 内置 `nvm` (但 plugins 数组中没有列出 nvm) |
| **Go** | `GOROOT=~/go1.25.4`, `GOPATH=~/go`, PATH |
| **Rust/Cargo** | `~/.cargo/env`, PATH |
| **SDKMAN** (Java) | `~/.sdkman/bin/sdkman-init.sh`, 在 .zshrc 末尾加载 |
| **Python 3.8** | .zprofile 中 PATH (Framework) |
| **Python 3.11** | Homebrew, PATH |
| **bun** | `~/.bun/bin`, PATH + completions (`~/.bun/_bun`) |

---

## 5. PATH 配置汇总

```zsh
/opt/homebrew/bin
/opt/homebrew/opt/python@3.11/libexec/bin
/opt/homebrew/opt/mysql/bin
/opt/homebrew/Cellar/redis/8.6.3/bin
/Users/pr/.local/bin
/Users/pr/.cargo/bin
/Users/pr/.bun/bin
/Users/pr/.nvm/... (由 nvm 动态管理)
/Users/pr/go1.25.4/bin
/Users/pr/go/bin
/Users/pr/.lmstudio/bin
/Users/pr/.codeium/windsurf/bin
/Users/pr/llvm-15/bin
/Users/pr/.sdkman/... (由 sdkman 动态管理)
/Applications/Docker.app/Contents/Resources/bin
/Library/Frameworks/Python.framework/Versions/3.8/bin
```

---

## 6. 环境变量

```zsh
TABBY_WEBSERVER_JWT_TOKEN_SECRET=c17c166b-a6db-4924-bb9f-2d423b0ba173
GOROOT=/Users/pr/go1.25.4
GOPATH=$HOME/go
GOBIN=$GOPATH/bin
NVM_DIR="$HOME/.nvm"
BUN_INSTALL="$HOME/.bun"
SDKMAN_DIR="$HOME/.sdkman"
LDFLAGS=-L$HOME/llvm-15/lib
CPPFLAGS=-I$HOME/llvm-15/include
```

---

## 7. 别名

```zsh
alias gcc=gcc-15
alias g++=g++-15
alias zookeeper-server="brew services start zookeeper"
alias kafka-server="brew services start kafka"
alias kill-kafka="brew services stop kafka"
alias redis-server="brew services start redis"
alias mysql-server="brew services start mysql"
```

---

## 8. 其他配置项

| 配置 | 说明 |
|------|------|
| `unsetopt SHARE_HISTORY` | 禁用 zsh session 间的历史共享 |
| `unsetopt INC_APPEND_HISTORY` | 禁用增量追加历史 |
| `autoload -Uz compinit && compinit` | 启用自动补全 |
| `zsh-vi-mode` | vim 模态编辑 (esc 切换 normal/insert) |
| `bun completions` | `~/.bun/_bun` 自动补全 |
| `JetBrains vmoptions` | `~/.jetbrains.vmoptions.sh` |

---

## 9. 配置文件清单

| 文件 | 用途 |
|------|------|
| `~/.zshrc` | 主配置 (2900 bytes) |
| `~/.zshenv` | 环境变量 (uv, cargo) |
| `~/.zprofile` | 登录 shell (Python 3.8 PATH) |
| `~/.p10k.zsh` | Powerlevel10k 主题配置 (95KB) |
| `~/.zshrc.pre-oh-my-zsh` | 安装 Oh My Zsh 前的原始 .zshrc |
| `~/.oh-my-zsh/` | Oh My Zsh 框架目录 |
| `~/.oh-my-zsh/custom/plugins/` | 自定义插件目录 |
| `~/.oh-my-zsh/custom/themes/powerlevel10k` | P10k 主题 |
| `~/.zsh/completion/_tldr` | tldr 自定义补全 |
| `~/.zsh_sessions/` | macOS 终端 session 历史 |

---

## 10. 未使用的流行工具

| 工具 | 状态 |
|------|------|
| zinit | 未安装 |
| antidote | 未安装 |
| zplug | 未安装 |
| starship | 未安装 (使用 P10k) |
| pure prompt | 未安装 |
| spaceship | 未安装 |
