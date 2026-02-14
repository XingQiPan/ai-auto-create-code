# 快速启动教程

5 分钟启动 AI 自动开发。

---

## 方式一：从项目描述初始化（推荐新项目）

### 1. 准备项目描述

创建一个 `project.md` 文件描述你的项目：

```markdown
# 项目名称：任务管理系统

## 技术栈
- 后端：Python FastAPI
- 前端：Vue.js 3 + TypeScript
- 数据库：PostgreSQL
- 缓存：Redis

## 核心功能
1. 用户认证（登录、注册、JWT）
2. 任务 CRUD
3. 任务分类和标签
4. 任务分配和协作
5. 实时通知

## API 设计
- RESTful API
- /api/auth/* - 认证接口
- /api/tasks/* - 任务接口
- /api/users/* - 用户接口

## 数据模型
- User: id, email, name, password_hash
- Task: id, title, description, status, assignee_id
- Category: id, name, user_id
```

### 2. 运行初始化

```bash
# 复制框架文件
cp -r auto/* my-project/
cd my-project

# 根据描述初始化（自动识别技术栈）
./init-project.sh project.md
```

AI 会自动：
- 识别技术栈（Python FastAPI + Vue.js）
- 生成定制的 CLAUDE.md
- 生成初始 task.json
- 生成 init.sh（pip install + npm install）
- 生成技术栈说明

### 3. 添加具体任务

编辑生成的 `task.json`，添加开发任务：

```json
{
  "tasks": [
    {
      "id": 1,
      "title": "初始化后端项目",
      "steps": [
        "创建 FastAPI 项目结构",
        "配置 SQLAlchemy 数据库连接",
        "创建 requirements.txt"
      ],
      "passes": false
    },
    {
      "id": 2,
      "title": "用户认证 API",
      "steps": [
        "创建 User 模型",
        "实现注册 API POST /api/auth/register",
        "实现登录 API POST /api/auth/login",
        "实现 JWT 认证中间件"
      ],
      "passes": false
    }
  ]
}
```

### 4. 启动自动开发

```bash
./run-automation.sh 50
```

---

## 方式二：从现有代码库初始化

### 1. 复制框架到项目

```bash
cp -r auto/* existing-project/
cd existing-project
```

### 2. 生成知识库

```bash
./build-knowledge.sh
```

AI 会分析你的代码库，生成：
- 项目架构文档
- 模块清单
- API 文档
- 数据模型文档

### 3. 交互式初始化

```bash
./init-project.sh
```

然后输入项目描述，AI 会根据现有代码和描述生成配置。

### 4. 定义新任务

编辑 `task.json` 添加你要开发的新功能。

### 5. 启动开发

```bash
./run-automation.sh 20
```

---

## 方式三：一行命令快速开始

```bash
# 直接传入描述
./init-project.sh "这是一个 Go 语言写的微服务，使用 Gin 框架，PostgreSQL 数据库，需要实现用户管理和订单系统"
```

---

## 技术栈自动识别

框架会自动识别以下技术栈：

### 前端
- React / Next.js / Remix
- Vue.js / Nuxt.js
- Angular
- Svelte / SvelteKit
- 纯 HTML/CSS/JS

### 后端
- Node.js (Express / Fastify / Koa / NestJS)
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

## 生成的文件说明

| 文件 | 内容 | 如何使用 |
|------|------|----------|
| `CLAUDE.md` | Agent 指令 | 根据你的技术栈定制 |
| `task.json` | 初始任务 | 添加更多开发任务 |
| `progress.txt` | 进度模板 | 无需修改 |
| `init.sh` | 初始化脚本 | 根据技术栈定制安装命令 |
| `technology.md` | 技术栈说明 | 记录技术选型 |

---

## 完整示例

### 示例 1：Python FastAPI + React

```bash
# 1. 创建项目描述
cat > project.md << 'EOF'
# 在线商城

后端: Python FastAPI + SQLAlchemy
前端: React + TypeScript + Tailwind
数据库: PostgreSQL
支付: Stripe API

功能:
- 商品管理
- 购物车
- 订单系统
- 用户认证
- 支付集成
EOF

# 2. 初始化
./init-project.sh project.md

# 3. 编辑 task.json 添加任务

# 4. 启动
./run-automation.sh 100
```

### 示例 2：Go 微服务

```bash
# 直接描述
./init-project.sh "Go 微服务项目，使用 Gin 框架，gRPC 通信，Redis 缓存，需要实现 API 网关、用户服务、订单服务"
```

### 示例 3：全栈 TypeScript

```bash
./init-project.sh "Next.js 14 全栈应用，Prisma ORM，PostgreSQL，Tailwind CSS，需要实现博客系统，包括文章、评论、标签功能"
```

---

## 常见问题

### Q: 技术栈识别错误？

A: 手动编辑 `CLAUDE.md` 和 `init.sh`，修改为正确的命令和规范。

### Q: 需要多语言项目？

A: 在描述中明确说明，如 "前端 React，后端 Python FastAPI"。

### Q: 生成的任务太少？

A: 编辑 `task.json` 继续添加更多任务，参考模板格式。

### Q: 想要修改代码规范？

A: 编辑 `CLAUDE.md` 中的「代码规范」部分。

---

## 下一步

初始化完成后：

1. **检查配置** - 确认 CLAUDE.md 和 init.sh 符合预期
2. **添加任务** - 在 task.json 中定义详细的开发任务
3. **配置环境** - 填写 .env 等配置文件
4. **启动开发** - 运行 `./run-automation.sh`
