#!/bin/bash

# =============================================================================
# init-project.sh - 项目智能初始化脚本
# =============================================================================
# 根据项目描述自动生成所有配置文件
#
# 用法 1: 交互式
#   ./init-project.sh
#
# 用法 2: 指定描述文件
#   ./init-project.sh project-description.md
#
# 用法 3: 直接描述
#   ./init-project.sh "这是一个 Python Flask 博客系统"
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "========================================"
echo "  Auto Coding Agent - 项目初始化器"
echo "========================================"
echo ""

# ============================================
# 获取项目描述
# ============================================

PROJECT_DESC=""

if [ -n "$1" ]; then
    if [ -f "$1" ]; then
        echo -e "${CYAN}从文件读取项目描述: $1${NC}"
        PROJECT_DESC=$(cat "$1")
    else
        echo -e "${CYAN}使用命令行描述${NC}"
        PROJECT_DESC="$1"
    fi
else
    # 交互式输入
    echo -e "${YELLOW}请描述你的项目（支持多行，空行结束）:${${NC}}"
    echo -e "${YELLOW}示例: 这是一个使用 Python FastAPI + Vue.js 的任务管理系统${NC}"
    echo ""

    while IFS= read -r line; do
        [ -z "$line" ] && break
        PROJECT_DESC="${PROJECT_DESC}${line}\n"
    done
fi

if [ -z "$PROJECT_DESC" ]; then
    echo "错误: 需要提供项目描述"
    exit 1
fi

echo ""
echo -e "${GREEN}项目描述:${NC}"
echo "$PROJECT_DESC"
echo ""

# ============================================
# 创建临时提示词
# ============================================

PROMPT_FILE=$(mktemp)

cat > "$PROMPT_FILE" << 'PROMPT_HEADER'
# 任务：初始化 Auto Coding Agent 项目配置

根据以下项目描述，生成完整的项目配置文件：

---
项目描述：
PROMPT_HEADER

echo "$PROJECT_DESC" >> "$PROMPT_FILE"

cat >> "$PROMPT_FILE" << 'PROMPT_FOOTER'
---

## 需要生成的文件

### 1. CLAUDE.md
生成完整的 Agent 工作指令文件，包括：
- 项目信息（根据描述推断技术栈）
- 知识库引用
- 技能引用
- 完整的工作流程
- 代码规范（根据技术栈定制）
- 测试要求（使用该技术栈的测试命令）

### 2. task.json
生成初始任务文件，包括：
- 项目基本信息
- 项目初始化任务（安装依赖、配置环境等）
- 基础架构搭建任务

### 3. progress.txt
生成初始进度文件模板

### 4. init.sh
生成环境初始化脚本，根据技术栈定制：
- 检测包管理器（npm/yarn/pnpm/pip/poetry/go mod 等）
- 安装依赖的命令
- 启动开发服务器的命令

### 5. technology.md（可选）
如果识别出技术栈，生成技术栈说明文件

## 技术栈识别

根据项目描述，识别以下信息：
- 前端框架（React/Vue/Angular/Svelte/纯HTML/无前端）
- 后端框架（Express/FastAPI/Django/Flask/Spring/Go/无后端）
- 数据库（PostgreSQL/MySQL/MongoDB/SQLite/无数据库）
- 语言（TypeScript/JavaScript/Python/Go/Java/Rust）
- 包管理器（npm/yarn/pnpm/pip/poetry/cargo/go mod）
- 测试框架（Jest/Vitest/pytest/JUnit/Go test）

## 输出要求

1. 每个文件用明确的分隔符标注
2. 文件内容完整，可直接使用
3. 根据识别的技术栈定制命令和规范
4. 如果描述不够具体，做出合理推断并标注

开始生成配置文件。
PROMPT_FOOTER

# ============================================
# 调用 Claude 生成配置
# ============================================

echo -e "${CYAN}正在分析项目描述并生成配置...${NC}"
echo ""

if command -v claude &> /dev/null; then
    claude -p \
        --dangerously-skip-permissions \
        --allowed-tools "Bash Read Write Glob Grep Edit" \
        < "$PROMPT_FILE"
else
    echo -e "${YELLOW}Claude CLI 未安装，请手动创建配置文件${NC}"
    echo ""
    echo "请将以下内容发送给 Claude 或其他 AI："
    echo "=========================================="
    cat "$PROMPT_FILE"
    echo "=========================================="
fi

# 清理
rm -f "$PROMPT_FILE"

echo ""
echo -e "${GREEN}初始化完成！${NC}"
echo ""
echo "下一步："
echo "1. 检查生成的配置文件"
echo "2. 编辑 task.json 添加具体任务"
echo "3. 运行 ./run-automation.sh 开始自动开发"
