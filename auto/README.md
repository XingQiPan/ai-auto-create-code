# Auto Coding Agent Framework

**让 AI 自动完成软件开发的框架**

支持任何技术栈：React / Vue / Python / Go / Java / Rust / ...

---

## 🚀 快速开始

### 最快启动方式

```bash
# 1. 复制框架到你的项目
cp -r auto/* my-project/
cd my-project

# 2. 用项目描述初始化（自动识别技术栈）
./init-project.sh "这是一个 Python FastAPI + Vue.js 的博客系统"

# 3. 启动自动开发
./run-automation.sh 50
```

### 统一启动器

```bash
./start.sh init              # 初始化环境
./start.sh run 50            # 运行50次自动化
./start.sh init-project      # 初始化新项目
./start.sh build-kb          # 构建知识库
```

### 详细教程

👉 **[查看快速启动教程](./QUICKSTART.md)**

---

## 核心理念

这套框架的核心是 **任务驱动 + 状态追踪 + 规范流程**：

```
┌─────────────────────────────────────────────────────────────────┐
│                      Agent 工作循环                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│   │ 读取任务  │ ─→ │ 实现功能  │ ─→ │ 测试验证  │ ─→ │ 更新状态  │ │
│   └──────────┘    └──────────┘    └──────────┘    └──────────┘ │
│        ↑                                               │        │
│        └───────────────────────────────────────────────┘        │
│                      重复直到所有任务完成                         │
└─────────────────────────────────────────────────────────────────┘
```

## 文件说明

| 文件 | 作用 | 谁读取/写入 |
|------|------|------------|
| `CLAUDE.md` | Agent 工作指令 | Agent 读取 |
| `task.json` | 任务定义 + 状态 | Agent 读取/写入 |
| `progress.txt` | 进度日志 | Agent 写入 |
| `init.sh` | 环境初始化脚本 | Agent 执行 |
| `run-automation.sh` | **全自动循环执行器** | 用户执行 |
| `start.sh` | **统一启动器** | 用户执行 |

## 快速开始

### 1. 复制框架文件

将 `auto/` 文件夹中的文件复制到你的项目根目录：

```bash
# 假设你的项目在 my-project/
cp -r auto/* my-project/

# 或者手动复制以下文件：
# - CLAUDE.md
# - task.json
# - progress.txt
# - init.sh
```

### 2. 配置 CLAUDE.md

编辑 `CLAUDE.md`，填写你的项目信息：

```markdown
## 项目信息
- **项目名称**: My Awesome App
- **技术栈**: Next.js 14, TypeScript, Tailwind CSS
- **描述**: 一个任务管理应用
```

添加你的代码规范：
```markdown
## 代码规范
- TypeScript strict mode
- 函数式组件 + React Hooks
- 使用 ESLint + Prettier
- 所有新功能需要写测试
```

### 3. 配置 init.sh

编辑 `init.sh`，设置你的项目配置：

```bash
PROJECT_NAME="My Awesome App"
PROJECT_DIR="my-app"        # 你的项目目录名
PACKAGE_MANAGER="npm"       # 或 yarn, pnpm
DEV_COMMAND="dev"           # 或 start, serve
DEV_PORT=3000               # 开发服务器端口
```

给脚本添加执行权限：
```bash
chmod +x init.sh
```

### 4. 定义任务（task.json）

编辑 `task.json`，拆解你的项目为具体任务：

```json
{
  "project": "My Awesome App",
  "description": "任务管理应用",
  "tasks": [
    {
      "id": 1,
      "title": "项目基础配置",
      "description": "配置项目基础设置",
      "priority": "high",
      "steps": [
        "安装所需依赖",
        "配置 ESLint 和 Prettier",
        "创建基础目录结构"
      ],
      "dependencies": [],
      "passes": false
    },
    {
      "id": 2,
      "title": "用户认证 - 登录",
      "description": "实现登录功能",
      "priority": "high",
      "steps": [
        "创建登录页面",
        "创建登录表单组件",
        "实现登录 API",
        "添加表单验证"
      ],
      "dependencies": [1],
      "passes": false
    }
  ]
}
```

### 5. 启动自动化（两种方式）

#### 方式一：手动单次执行

在 Claude Code 中：

```
请阅读 CLAUDE.md 并按照其中的工作流程开发这个项目。
```

Agent 会完成一个任务后停止。你需要手动再次运行来继续下一个任务。

#### 方式二：全自动无人值守执行（推荐）

**这是这套框架的核心能力！** 使用 `run-automation.sh` 实现：

```bash
# 给脚本执行权限
chmod +x run-automation.sh

# 自动运行 10 次（每次完成一个任务）
./run-automation.sh 10

# 或者运行足够多次完成所有任务
./run-automation.sh 100
```

**run-automation.sh 的工作原理：**

```
┌─────────────────────────────────────────────────────────────────┐
│                   run-automation.sh 工作流程                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. 检查 task.json 中剩余任务数（passes: false）           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                          │                                      │
│                          ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 2. 如果剩余任务 = 0，退出（所有任务完成）                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                          │                                      │
│                          ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 3. 调用 Claude Code 执行一个任务                          │  │
│  │    claude -p --dangerously-skip-permissions ...           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                          │                                      │
│                          ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 4. 检查任务是否完成（passes 变为 true）                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                          │                                      │
│                          ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 5. 等待 2 秒，返回步骤 1                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**日志输出示例：**

```
========================================
  Claude Code 自动化执行器
========================================

[INFO] 开始自动化执行，最多运行 10 次
[INFO] 开始时剩余任务数: 8

========================================
[PROGRESS] 第 1 次运行 / 共 10 次
========================================
[INFO] 本次运行前剩余任务: 8
[INFO] 启动 Claude Code 会话...
[SUCCESS] 第 1 次运行完成，耗时 45 秒
[SUCCESS] 本次运行完成的任务数: 1
[INFO] 第 1 次运行后剩余任务: 7

========================================
[PROGRESS] 第 2 次运行 / 共 10 次
========================================
...

[SUCCESS] 所有任务已完成！
[INFO] 执行总结:
[INFO]   - 总运行次数: 8
[INFO]   - 完成任务数: 8
[INFO]   - 剩余任务数: 0
```

**日志文件位置：**

```
automation-logs/
├── automation-20260214_120000.log    # 主日志
├── run-1-20260214_120001.log         # 第1次运行的详细日志
├── run-2-20260214_120050.log         # 第2次运行的详细日志
└── ...
```

## task.json 结构详解

```json
{
  "project": "项目名称",
  "description": "项目描述",
  "version": "1.0.0",
  "tasks": [
    {
      "id": 1,                          // 唯一 ID，按顺序
      "title": "任务标题",               // 简短标题
      "description": "详细描述",         // 详细说明
      "priority": "high",               // high, medium, low
      "steps": [                        // 具体步骤（关键！）
        "步骤 1：具体要做什么",
        "步骤 2：具体要做什么"
      ],
      "dependencies": [],               // 依赖的任务 ID
      "passes": false                   // 是否完成（由 Agent 更新）
    }
  ]
}
```

**关键字段说明：**

- `steps`: **最重要的字段**，越具体越好。Agent 会按步骤逐一实现。
- `dependencies`: 指定任务依赖，Agent 会先完成依赖任务。
- `passes`: 由 Agent 完成后更新为 `true`，不要手动修改。

## 任务拆解技巧

### 好的任务拆解

```json
{
  "id": 5,
  "title": "用户注册页面",
  "steps": [
    "创建 app/register/page.tsx 注册页面",
    "创建 components/auth/RegisterForm.tsx 表单组件",
    "实现邮箱、密码、确认密码输入框",
    "添加密码强度验证（至少8位，包含数字和字母）",
    "调用 POST /api/auth/register API",
    "注册成功后显示成功提示并跳转到登录页",
    "显示错误信息（网络错误、邮箱已存在等）"
  ]
}
```

### 不好的任务拆解

```json
{
  "id": 5,
  "title": "做注册功能",
  "steps": [
    "实现用户注册"
  ]
}
```

**区别：**
- ✅ 好：具体的文件路径、明确的功能点、可验证的步骤
- ❌ 不好：模糊的描述，缺少细节

### 任务粒度建议

| 任务类型 | 建议粒度 |
|---------|---------|
| 配置类 | 一个配置文件或一组相关配置 |
| 页面类 | 一个完整页面（包含组件） |
| API 类 | 一个 API 端点及其功能 |
| 组件类 | 一个可复用组件 |
| 功能类 | 一个完整的功能点 |

## 工作流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                      完整工作流程                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. 初始化环境                                                   │
│     │                                                           │
│     ▼                                                           │
│  2. 读取 task.json，选择 passes: false 的任务                    │
│     │                                                           │
│     ▼                                                           │
│  3. 读取任务步骤，逐一实现                                        │
│     │                                                           │
│     ▼                                                           │
│  4. 测试验证（lint, build, 浏览器测试）                           │
│     │                                                           │
│     ├── 失败 ─→ 修复问题 ─→ 返回步骤 4                           │
│     │                                                           │
│     ├── 阻塞 ─→ 记录到 progress.txt，输出阻塞信息，停止           │
│     │                                                           │
│     ▼ 成功                                                      │
│  5. 更新 task.json (passes: true)                               │
│     │                                                           │
│     ▼                                                           │
│  6. 更新 progress.txt 记录工作内容                               │
│     │                                                           │
│     ▼                                                           │
│  7. git commit 提交所有更改                                      │
│     │                                                           │
│     ▼                                                           │
│  8. 还有未完成任务？                                             │
│     │                                                           │
│     ├── 是 ─→ 返回步骤 2                                         │
│     │                                                           │
│     └── 否 ─→ 项目完成！                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 阻塞处理

当 Agent 遇到需要人工介入的情况时，会：

1. **不提交** - 不会执行 git commit
2. **不标记完成** - 不会将 passes 设为 true
3. **记录进度** - 在 progress.txt 中记录已完成的部分
4. **输出阻塞信息** - 明确告诉你需要做什么

示例输出：
```
🚫 任务阻塞 - 需要人工介入

**当前任务**: 用户认证 - 登录页面

**已完成的工作**:
- 创建了登录页面和表单组件
- 实现了表单验证逻辑

**阻塞原因**:
- 需要配置 Supabase 项目才能测试登录功能

**需要人工帮助**:
1. 创建 Supabase 项目
2. 获取 API 密钥
3. 在 .env.local 中配置 NEXT_PUBLIC_SUPABASE_URL 和 NEXT_PUBLIC_SUPABASE_ANON_KEY

**解除阻塞后**:
- 重新运行 Agent，它会继续完成测试
```

## 多 Agent 协作

如果任务很多，可以在多个 Agent 会话中并行处理：

**会话 A**：
```
请完成 task.json 中 id 为 1-5 的任务
```

**会话 B**：
```
请完成 task.json 中 id 为 6-10 的任务
```

注意：
- 确保任务之间没有代码冲突
- 或者让不同会话处理不同的模块

## 进阶技巧

### 1. 使用依赖关系

```json
{
  "id": 10,
  "title": "用户个人资料页面",
  "dependencies": [2, 5],  // 依赖登录和注册功能
  "passes": false
}
```

Agent 会先完成依赖任务。

### 2. 添加验收标准

在步骤中包含验收标准：

```json
{
  "steps": [
    "创建登录页面",
    "实现表单验证",
    "验收：输入错误密码时显示「密码错误」提示",
    "验收：登录成功后跳转到首页",
    "验收：未填写邮箱时禁用登录按钮"
  ]
}
```

### 3. 指定文件路径

在步骤中指定具体的文件路径：

```json
{
  "steps": [
    "创建 src/pages/login.tsx",
    "创建 src/components/auth/LoginForm.tsx",
    "创建 src/api/auth/login.ts"
  ]
}
```

### 4. 分阶段开发

将大项目分为多个阶段：

```json
{
  "tasks": [
    // 阶段 1: 基础设施 (id 1-5)
    // 阶段 2: 核心功能 (id 6-15)
    // 阶段 3: 优化完善 (id 16-25)
  ]
}
```

## 常见问题

### Q: Agent 跳过了某些步骤？

A: 步骤描述不够具体。添加更多细节和验收标准。

### Q: Agent 无法理解任务？

A: 确保任务描述清晰，步骤具体。可以在 CLAUDE.md 中添加更多上下文。

### Q: 多次运行会重复工作？

A: 不会。Agent 会检查 `passes` 字段，只处理未完成的任务。

### Q: 如何回滚任务？

A: 将 `passes` 改回 `false`，删除 progress.txt 中对应的记录，Agent 会重新执行。

## 实际案例

这个框架来自 [Spring FES Video](../) 项目，该项目使用此框架完成了 **31 个任务**，包括：

- 用户认证（登录、注册、登出）
- 数据库设计和 API 实现
- AI 服务集成
- 完整的前端 UI
- 响应式设计和错误处理

查看 [progress.txt](../progress.txt) 了解详细的任务完成记录。

## 总结

这套框架的核心价值：

1. **任务驱动** - 将大项目拆解为小任务，逐一完成
2. **状态追踪** - 清晰地知道哪些已完成，哪些待做
3. **规范流程** - 确保每个任务都经过测试和验证
4. **可恢复** - 任务中断后可以从上次进度继续
5. **可协作** - 多个 Agent 会话可以并行处理不同任务
6. **🚀 全自动执行** - 使用 `run-automation.sh` 实现 **无人值守** 的持续开发

---

## 完整使用流程

```bash
# ============================================
# 新项目：从零开始
# ============================================

# 1. 复制框架文件到新项目目录
cp auto/CLAUDE.md .
cp auto/task.json .
cp auto/progress.txt .
cp auto/init.sh .
cp auto/start.sh .
cp auto/run-automation.sh .
cp -r auto/knowledge .

# 2. 编辑配置文件
# - 编辑 CLAUDE.md：填写项目信息、代码规范
# - 编辑 init.sh：设置项目目录、启动命令
# - 编辑 task.json：拆解任务，写具体步骤

# 3. 给脚本执行权限
chmod +x init.sh start.sh run-automation.sh

# 4. 启动全自动开发！
./run-automation.sh 50
# 或使用统一启动器
./start.sh run 50

# ============================================
# 已有项目：接手继续开发
# ============================================

# 1. 复制框架文件到项目根目录
cp auto/CLAUDE.md .
cp auto/task.json .
cp auto/progress.txt .
cp auto/init.sh .
cp auto/start.sh .
cp auto/run-automation.sh .
cp auto/build-knowledge.sh .
cp -r auto/knowledge .

# 2. 给脚本执行权限
chmod +x init.sh start.sh run-automation.sh build-knowledge.sh

# 3. 📚 生成项目知识库（关键步骤！）
./build-knowledge.sh
# 或使用统一启动器
./start.sh build-kb
# 这会分析整个代码库，生成 AI 可读的项目文档

# 4. 编辑 task.json 定义新任务

# 5. 启动自动化开发
./run-automation.sh 50
# 或使用统一启动器
./start.sh run 50
```

然后你就可以：
- 去喝杯咖啡 ☕
- 看日志文件了解进度 📋
- 回来看到项目完成 ✅

---

## 框架完整文件清单

```
auto/
├── README.md                  # 完整使用教程
├── QUICKSTART.md              # 🚀 快速启动教程
├── CLAUDE.md                  # Agent 工作指令模板
├── task.json                  # 任务定义模板
├── progress.txt               # 进度日志模板
│
├── start.sh                   # 🌟 统一启动器
├── init-project.sh            # 🆕 项目智能初始化
├── init.sh                    # 环境初始化脚本
├── run-automation.sh          # 🔄 全自动循环执行器
├── build-knowledge.sh         # 📚 知识库生成器
│
├── knowledge/                 # 知识库目录
│   ├── SUMMARY.md
│   ├── ARCHITECTURE.md
│   ├── MODULES.md
│   ├── API.md
│   ├── DATA-MODELS.md
│   ├── KEY-FLOWS.md
│   └── INDEX.json
│
├── skills/                    # ⚡ AI 技能包（全技术栈）
│   ├── code-analysis/
│   │   ├── SKILL.md
│   │   └── patterns/
│   │       ├── api-patterns.md    # TS/React 模式
│   │       └── python-patterns.md # Python/Go/Java/Vue 模式
│   ├── debug/
│   ├── testing/
│   ├── api-design/
│   ├── architecture/
│   └── security/
│
└── examples/
    ├── nextjs-task.json       # Next.js 示例
    └── nextjs-init.sh         # Next.js 初始化
```

---

## 支持的技术栈

### 编程语言
- TypeScript / JavaScript
- Python
- Go
- Java / Kotlin
- Rust
- Ruby

### 前端框架
- React / Next.js / Remix
- Vue.js / Nuxt.js
- Angular
- Svelte / SvelteKit
- Solid.js

### 后端框架
- Node.js (Express / Fastify / NestJS / Koa)
- Python (FastAPI / Django / Flask)
- Go (Gin / Echo / Fiber)
- Java (Spring Boot)
- Rust (Actix / Axum)
- Ruby (Rails)

### 数据库
- PostgreSQL / MySQL / SQLite
- MongoDB
- Redis
- Supabase / Firebase

### 包管理器
- npm / yarn / pnpm
- pip / poetry / pipenv
- go mod
- cargo
- maven / gradle

---

## 📚 项目知识库（重要功能）

### 为什么需要知识库？

当 AI 接手一个已有项目时，需要：
1. **理解完整架构** - 知道项目是怎么组织的
2. **定位代码位置** - 快速找到要修改的文件
3. **理解依赖关系** - 知道模块之间如何关联
4. **遵循已有模式** - 保持代码风格一致

**知识库就是 AI 的「项目地图」！**

### 生成知识库

```bash
# 在已有项目根目录运行
./build-knowledge.sh
```

这会调用 Claude Code 分析整个代码库，生成：

| 文件 | 内容 | 用途 |
|------|------|------|
| `SUMMARY.md` | 项目概览 | 快速了解项目 |
| `ARCHITECTURE.md` | 架构设计 | 理解整体结构 |
| `MODULES.md` | 模块清单 | 查找代码位置 |
| `API.md` | API 文档 | 了解接口定义 |
| `DATA-MODELS.md` | 数据模型 | 理解数据结构 |
| `KEY-FLOWS.md` | 关键流程 | 理解业务逻辑 |
| `INDEX.json` | 结构化索引 | 快速检索 |

---

## ⚡ AI 技能包（增强能力）

### 可用技能

框架提供了多个技能包，用于增强 AI 在特定场景的能力：

| 技能 | 用途 | 调用时机 |
|------|------|----------|
| `code-analysis` | 代码库分析 | 理解项目结构时 |
| `debug` | 调试诊断 | 遇到 bug 时 |
| `testing` | 测试生成 | 需要写测试时 |
| `api-design` | API 设计 | 设计新 API 时 |
| `architecture` | 架构设计 | 设计架构时 |
| `security` | 安全审计 | 检查安全时 |

### 技能结构

```
skills/
├── code-analysis/
│   ├── SKILL.md           # 技能说明和流程
│   └── patterns/          # 代码模式和模板
├── debug/
│   └── SKILL.md           # 调试流程和检查清单
├── testing/
│   └── SKILL.md           # 测试模板和最佳实践
├── api-design/
│   └── SKILL.md           # API 设计规范
├── architecture/
│   └── SKILL.md           # 架构设计原则
└── security/
    └── SKILL.md           # 安全检查清单
```

### 使用技能

在 `CLAUDE.md` 中启用技能：

```markdown
## 可用技能

根据任务类型，调用对应的技能：

- **代码分析**: @skills/code-analysis/SKILL.md
- **调试修复**: @skills/debug/SKILL.md
- **编写测试**: @skills/testing/SKILL.md
- **设计 API**: @skills/api-design/SKILL.md
```

AI 会根据任务自动选择使用哪个技能：

```
任务：修复登录 bug
  → AI 读取 skills/debug/SKILL.md
  → 按照调试流程定位问题
  → 应用修复模式

任务：设计用户 API
  → AI 读取 skills/api-design/SKILL.md
  → 遵循 API 设计规范
  → 应用 RESTful 模式
```

### 技能详解

#### 1. Code Analysis Skill
- 快速分析项目结构
- 查找代码位置
- 分析依赖关系
- 提供代码模式

#### 2. Debug Skill
- 系统化调试流程
- 常见 bug 类型及修复
- 调试工具命令
- 调试检查清单

#### 3. Testing Skill
- 测试模板（组件/API/Hook）
- Mock 指南
- 覆盖率要求
- 测试最佳实践

#### 4. API Design Skill
- RESTful 设计原则
- API 模板（CRUD/动作）
- 请求/响应格式
- 状态码规范

#### 5. Architecture Skill
- 分层架构设计
- 目录结构模板
- 设计模式
- 架构决策记录

#### 6. Security Skill
- 安全检查清单
- 常见漏洞防护
- 敏感数据处理
- 权限控制模式

---

## 知识库维护

**自动更新时机：**
- 完成重要功能后，可以重新运行 `./build-knowledge.sh` 更新知识库

**手动更新：**
- 对于小的改动，可以只更新相关的知识库文件

### 工作流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                    完整的自动化开发流程                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐                                           │
│  │ 1. 复制框架文件  │                                           │
│  │    到项目根目录  │                                           │
│  └────────┬────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐     ┌─────────────────┐                   │
│  │ 2. 生成知识库    │────▶│ AI 分析代码库   │                   │
│  │ (已有项目)      │     │ 生成文档       │                   │
│  └────────┬────────┘     └─────────────────┘                   │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐                                           │
│  │ 3. 编辑 task.json │                                          │
│  │    定义开发任务   │                                          │
│  └────────┬────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐                                           │
│  │ 4. 启动自动化    │                                           │
│  │ ./run-automation │                                          │
│  └────────┬────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐                                           │
│  │ 5. AI 阅读知识库 │                                           │
│  │    理解项目上下文│                                           │
│  └────────┬────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐                                           │
│  │ 6. 执行任务      │                                           │
│  │    循环直到完成  │                                           │
│  └─────────────────┘                                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```
