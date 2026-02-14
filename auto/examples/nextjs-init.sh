#!/bin/bash

# =============================================================================
# init.sh - Next.js Todo App 示例初始化脚本
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_NAME="Todo App"
PROJECT_DIR="todo-app"
DEV_PORT=3000

echo -e "${YELLOW}正在初始化 ${PROJECT_NAME}...${NC}"

# 检查是否已存在项目目录
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}项目目录已存在，跳过创建...${NC}"
else
    echo "创建 Next.js 项目..."
    npx create-next-app@latest "$PROJECT_DIR" --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --no-git
fi

# 安装额外依赖
echo "安装额外依赖..."
cd "$PROJECT_DIR"
npm install zustand uuid
npm install -D @types/uuid
cd ..

# 创建目录结构
echo "创建目录结构..."
mkdir -p "$PROJECT_DIR/src/components"
mkdir -p "$PROJECT_DIR/src/hooks"
mkdir -p "$PROJECT_DIR/src/types"
mkdir -p "$PROJECT_DIR/src/store"

# 启动开发服务器
echo "正在启动开发服务器..."
cd "$PROJECT_DIR"
npm run dev &
SERVER_PID=$!
cd ..

sleep 5

echo ""
echo -e "${GREEN}✓ 初始化完成！${NC}"
echo -e "${GREEN}✓ 开发服务器运行在 http://localhost:$DEV_PORT${NC}"
echo ""
echo "项目结构已创建："
echo "  todo-app/src/components/  - 组件目录"
echo "  todo-app/src/hooks/       - Hooks 目录"
echo "  todo-app/src/types/       - 类型定义目录"
echo "  todo-app/src/store/       - 状态管理目录"
echo ""
echo "下一步："
echo "1. 复制 examples/nextjs-task.json 的内容到 task.json"
echo "2. 运行 Agent 开始开发"
