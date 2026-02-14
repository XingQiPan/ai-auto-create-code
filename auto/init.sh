#!/bin/bash

# =============================================================================
# init.sh - 项目初始化脚本模板
# =============================================================================
# 每次 Agent 会话开始时运行此脚本，确保环境正确设置。
# =============================================================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ============================================
# 配置区域 - 根据你的项目修改以下变量
# ============================================

PROJECT_NAME="你的项目名称"
PROJECT_DIR="你的项目目录"  # 如: "my-app", "frontend", "src"
PACKAGE_MANAGER="npm"       # npm, yarn, pnpm
DEV_COMMAND="dev"           # dev, start, serve
DEV_PORT=3000               # 开发服务器端口

# ============================================
# 初始化逻辑 - 通常不需要修改
# ============================================

echo -e "${YELLOW}正在初始化 ${PROJECT_NAME}...${NC}"

# 检查项目目录是否存在
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}错误: 项目目录 '$PROJECT_DIR' 不存在${NC}"
    echo "请修改 init.sh 中的 PROJECT_DIR 变量"
    exit 1
fi

# 安装依赖
echo "正在安装依赖..."
cd "$PROJECT_DIR"
$PACKAGE_MANAGER install
cd ..

# 启动开发服务器（后台运行）
echo "正在启动开发服务器..."
cd "$PROJECT_DIR"
$PACKAGE_MANAGER run $DEV_COMMAND &
SERVER_PID=$!
cd ..

# 等待服务器就绪
echo "等待服务器启动..."
sleep 5

# 检查服务器是否启动成功
if curl -s "http://localhost:$DEV_PORT" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 初始化完成！${NC}"
    echo -e "${GREEN}✓ 开发服务器运行在 http://localhost:$DEV_PORT (PID: $SERVER_PID)${NC}"
else
    echo -e "${YELLOW}⚠ 服务器可能还在启动中，请稍候...${NC}"
    echo -e "${YELLOW}⚠ 如果服务器未能启动，请手动检查${NC}"
fi

echo ""
echo "准备就绪，可以开始开发。"
echo ""
echo "下一步："
echo "1. 查看 task.json 了解任务列表"
echo "2. 选择一个 passes: false 的任务开始"
echo "3. 按照 CLAUDE.md 中的工作流程执行"
