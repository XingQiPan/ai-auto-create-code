# AI Auto Create Code

**让 AI 自动完成软件开发的通用框架**

基于 [SamuelQZQ/auto-coding-agent-demo](https://github.com/SamuelQZQ/auto-coding-agent-demo) 二次开发，扩展为支持全技术栈的通用框架。

---

## 与原项目的区别

| 特性 | 原项目 | 本项目 |
|------|--------|--------|
| 技术栈 | Next.js 专用 | 全技术栈（Python/Go/Java/Rust/...） |
| 初始化 | 手动配置 | 智能识别自动生成 |
| 知识库 | 无 | 自动生成项目文档 |
| 技能包 | 无 | 6 个专业技能 |

---

## 快速开始

```bash
# 1. 克隆
git clone https://github.com/XingQiPan/ai-auto-create-code.git

# 2. 复制框架到你的项目
cp -r ai-auto-create-code/auto/* my-project/

# 3. 智能初始化（自动识别技术栈）
cd my-project
./init-project.sh "Python FastAPI + Vue.js 博客系统"

# 4. 编辑 task.json 添加任务

# 5. 启动自动开发
./run-automation.sh 50
```

---

## 核心功能

### 1. 智能初始化 `init-project.sh`
- 根据项目描述自动识别技术栈
- 自动生成定制的配置文件
- 支持：Python/Go/Java/TypeScript/Rust/Ruby

### 2. 全自动执行 `run-automation.sh`
- 循环调用 AI 完成任务
- 自动检测进度，完成即停止
- 详细日志记录

### 3. 知识库生成 `build-knowledge.sh`
- 自动分析代码库
- 生成项目文档（架构、模块、API、数据模型）
- AI 快速理解项目上下文

### 4. AI 技能包
| 技能 | 用途 |
|------|------|
| code-analysis | 代码库分析 |
| debug | 调试诊断 |
| testing | 测试生成 |
| api-design | API 设计 |
| architecture | 架构设计 |
| security | 安全审计 |

---

## 工作原理

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  读取任务     │ ──▶ │  实现功能     │ ──▶ │  测试验证     │
└──────────────┘     └──────────────┘     └──────────────┘
       ▲                                         │
       └─────────────────────────────────────────┘
                    重复直到完成
```

---

## 文件说明

| 文件 | 说明 |
|------|------|
| `CLAUDE.md` | AI 工作指令 |
| `task.json` | 任务定义 |
| `progress.txt` | 进度日志 |
| `init-project.sh` | 智能初始化 |
| `run-automation.sh` | 自动执行器 |
| `build-knowledge.sh` | 知识库生成 |
| `start.sh` | 统一启动器 |

### 统一启动器

```bash
./start.sh init              # 初始化环境
./start.sh run 50            # 运行自动化
./start.sh init-project      # 初始化新项目
./start.sh build-kb          # 构建知识库
```

---

## 前置要求

- [Claude Code](https://claude.ai/code)
- 可选：Playwright MCP（浏览器测试）

---

## Windows 环境安装指南

在 Windows 上使用本框架需要先安装以下组件：

### 1. 安装 WSL (Windows Subsystem for Linux)

```powershell
# 以管理员身份运行 PowerShell
wsl --install

# 安装完成后重启电脑
# 重启后会自动打开 Ubuntu 终端，设置用户名和密码
```

### 2. 安装 nvm (Node Version Manager)

```bash
# 在 WSL Ubuntu 终端中执行
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# 重新加载配置
source ~/.bashrc

# 验证安装
nvm --version
```

### 3. 安装 Node.js 和 npm

```bash
# 安装最新 LTS 版本
nvm install --lts

# 设为默认版本
nvm use --lts

# 验证安装
node --version
npm --version
```

### 4. 安装 Claude Code

```bash
# 使用 npm 全局安装
npm install -g @anthropic-ai/claude-code

# 验证安装
claude --version

# 首次使用需要登录
claude
```

### 5. 授予 Claude Code 最高权限

Claude Code 需要文件读写、执行命令等权限才能正常工作。

**方法一：启动时跳过权限检查（推荐）**

```bash
# 使用 --dangerously-skip-permissions 启动
claude --dangerously-skip-permissions
```

**方法二：在交互中授权**

```bash
# 正常启动
claude

# 首次运行时，Claude Code 会请求各种权限
# 选择 "Yes" 或 "Allow for all" 授予全部权限
```

**方法三：配置信任项目目录**

```bash
# 将项目目录添加到信任列表
claude config add-trusted-folder /path/to/your/project
```

> ⚠️ **安全提示**：`--dangerously-skip-permissions` 会跳过所有安全检查，请确保在可信环境中使用。

### 6. 克隆并使用项目

```bash
# 在 WSL 中克隆项目
git clone https://github.com/XingQiPan/ai-auto-create-code.git
cd ai-auto-create-code

# 后续步骤同快速开始
```

### 常见问题

| 问题 | 解决方案 |
|------|----------|
| WSL 安装失败 | 确保已启用虚拟化，BIOS 中开启 VT-x |
| nvm 命令找不到 | 执行 `source ~/.bashrc` 或重启终端 |
| npm 下载慢 | 设置淘宝镜像：`npm config set registry https://registry.npmmirror.com` |
| Claude Code 登录失败 | 检查网络代理设置 |

---

## 致谢

本项目基于 [SamuelQZQ/auto-coding-agent-demo](https://github.com/SamuelQZQ/auto-coding-agent-demo) 开发，感谢原作者的创意和实践。

---

## License

MIT
