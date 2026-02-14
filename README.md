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

---

## 前置要求

- [Claude Code](https://claude.ai/code)
- 可选：Playwright MCP（浏览器测试）

---

## 致谢

本项目基于 [SamuelQZQ/auto-coding-agent-demo](https://github.com/SamuelQZQ/auto-coding-agent-demo) 开发，感谢原作者的创意和实践。

---

## License

MIT
