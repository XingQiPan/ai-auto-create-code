# Code Analysis Skill

快速分析代码库结构和依赖关系的技能。

---

## 何时使用

- 接手新项目，需要快速理解代码结构
- 定位某个功能的实现位置
- 分析模块之间的依赖关系
- 评估代码改动的影响范围

---

## 技术栈识别

### 检测项目类型

```bash
# Node.js / JavaScript / TypeScript
[ -f "package.json" ] && echo "Node.js 项目"

# Python
[ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] && echo "Python 项目"

# Go
[ -f "go.mod" ] && echo "Go 项目"

# Java
[ -f "pom.xml" ] || [ -f "build.gradle" ] && echo "Java 项目"

# Rust
[ -f "Cargo.toml" ] && echo "Rust 项目"

# Ruby
[ -f "Gemfile" ] && echo "Ruby 项目"
```

### 检测框架

```bash
# 前端框架
grep -q "next" package.json && echo "Next.js"
grep -q "nuxt" package.json && echo "Nuxt.js"
grep -q "vue" package.json && echo "Vue.js"
grep -q "react" package.json && echo "React"
grep -q "angular" package.json && echo "Angular"
grep -q "svelte" package.json && echo "Svelte"

# 后端框架
grep -q "fastapi" requirements.txt && echo "FastAPI"
grep -q "django" requirements.txt && echo "Django"
grep -q "flask" requirements.txt && echo "Flask"
grep -q "gin" go.mod && echo "Gin"
grep -q "echo" go.mod && echo "Echo"
grep -q "spring" pom.xml && echo "Spring Boot"
```

---

## 分析流程

### 1. 项目结构分析

```bash
# Node.js / TypeScript
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) | head -50
find . -name "index.ts" -o -name "main.ts" -o -name "app.ts"

# Python
find . -type f -name "*.py" | head -50
find . -name "main.py" -o -name "app.py" -o -name "__init__.py" | head -20

# Go
find . -type f -name "*.go" | head -50
find . -name "main.go"

# Java
find . -type f -name "*.java" | head -50
find . -name "Application.java" -o -name "Main.java"
```

### 2. 依赖关系分析

```bash
# Node.js
cat package.json | grep -A 100 "dependencies"

# Python
cat requirements.txt
cat pyproject.toml | grep -A 50 "dependencies"

# Go
cat go.mod | grep -A 50 "require"

# Java
cat pom.xml | grep -A 50 "<dependencies>"
```

### 3. 代码模式分析

```bash
# TypeScript/React 组件
grep -r "export.*function\|export.*const.*=" --include="*.tsx" --include="*.ts" | head -20

# Python 类/函数
grep -r "^class \|^def \|^async def " --include="*.py" | head -30

# Go 函数/结构体
grep -r "^func \|^type .* struct" --include="*.go" | head -30

# Java 类
grep -r "^public class \|^class " --include="*.java" | head -20
```

---

## 快速分析命令

### 查找功能实现

```bash
# 认证相关
grep -r "login\|auth\|token\|session" --include="*.ts" --include="*.py" --include="*.go" -l

# API 端点
grep -r "@router\|@app\|@GetMapping\|@PostMapping\|router.\|app." --include="*.py" --include="*.java" --include="*.go" -l

# 数据库操作
grep -r "prisma\|sequelize\|sqlalchemy\|gorm\|jpa" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" -l
```

### 查找引用关系

```bash
# 查找某个模块被引用的位置
grep -r "from.*module_name\|import.*module_name" --include="*.ts" --include="*.py" --include="*.go"

# 查找某个函数被调用的位置
grep -r "functionName(" --include="*.ts" --include="*.py" --include="*.go"
```

---

## 项目结构模板

### Node.js / TypeScript

```
project/
├── src/
│   ├── app/           # 页面/路由
│   ├── components/    # 组件
│   ├── lib/           # 工具库
│   └── types/         # 类型定义
├── tests/
├── package.json
└── tsconfig.json
```

### Python / FastAPI

```
project/
├── app/
│   ├── api/           # API 路由
│   ├── models/        # 数据模型
│   ├── schemas/       # Pydantic 模型
│   ├── services/      # 业务逻辑
│   └── main.py        # 入口
├── tests/
├── requirements.txt
└── pyproject.toml
```

### Go

```
project/
├── cmd/               # 入口
├── internal/          # 内部代码
│   ├── handler/       # HTTP 处理
│   ├── service/       # 业务逻辑
│   └── repository/    # 数据访问
├── pkg/               # 公共代码
├── go.mod
└── go.sum
```

### Java / Spring

```
project/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   ├── controller/
│   │   │   ├── service/
│   │   │   ├── repository/
│   │   │   └── model/
│   │   └── resources/
│   └── test/
└── pom.xml
```

---

## 输出格式

分析完成后，输出结构化报告：

```json
{
  "language": "python",
  "framework": "fastapi",
  "database": "postgresql",
  "packageManager": "pip",
  "testFramework": "pytest",
  "entryPoints": ["app/main.py"],
  "modules": [
    {
      "name": "auth",
      "path": "app/api/auth",
      "exports": ["login", "register", "logout"]
    }
  ],
  "keyFiles": [
    "app/main.py - 应用入口",
    "app/config.py - 配置管理"
  ]
}
```
