#!/bin/bash

# =============================================================================
# build-knowledge.sh - 自动构建项目知识库
# =============================================================================
# 此脚本调用 Claude Code 分析项目代码，自动生成知识库文档
#
# 用法: ./build-knowledge.sh
#
# 生成的文件:
# - knowledge/SUMMARY.md      - 项目概览
# - knowledge/ARCHITECTURE.md - 架构设计
# - knowledge/MODULES.md      - 模块清单
# - knowledge/API.md          - API 文档
# - knowledge/DATA-MODELS.md  - 数据模型
# - knowledge/KEY-FLOWS.md    - 关键流程
# - knowledge/INDEX.json      - 结构化索引
# =============================================================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================
# 配置区域
# ============================================

KNOWLEDGE_DIR="./knowledge"
LOG_DIR="./knowledge-logs"

# ============================================
# 主逻辑
# ============================================

echo ""
echo "========================================"
echo "  项目知识库生成器"
echo "========================================"
echo ""

# 创建目录
mkdir -p "$KNOWLEDGE_DIR"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/build-$(date +%Y%m%d_%H%M%S).log"

echo -e "${YELLOW}将分析项目代码并生成知识库...${NC}"
echo "日志文件: $LOG_FILE"

# 检查必要文件
if [ ! -f "CLAUDE.md" ]; then
    echo -e "${YELLOW}警告: 找不到 CLAUDE.md${NC}"
fi

if [ ! -f "task.json" ]; then
    echo -e "${YELLOW}警告: 找不到 task.json${NC}"
fi

# 知识库生成提示词
cat > /tmp/knowledge-prompt.md << 'PROMPT_EOF'
# 任务：构建项目知识库

请分析当前项目的完整代码库，生成以下知识库文件：

## 1. knowledge/SUMMARY.md
生成项目概览，包括：
- 项目名称和简介
- 核心功能列表
- 技术栈概述
- 快速导航链接
- 开发指南（启动命令、常用命令）

## 2. knowledge/ARCHITECTURE.md
生成架构设计文档，包括：
- 系统架构图（使用 ASCII 图）
- 技术栈详情（前端、后端、数据库、外部服务）
- 目录结构说明
- 设计原则
- 关键设计决策

## 3. knowledge/MODULES.md
生成模块清单，包括：
- 所有页面/路由模块
- 所有组件（按功能分类）
- 所有 API 端点
- 数据访问层模块
- 工具模块
- 类型定义
- 模块依赖关系图

## 4. knowledge/API.md
生成 API 文档，包括：
- 所有 API 端点的详细信息
- 请求/响应格式
- 认证方式
- 错误处理格式

## 5. knowledge/DATA-MODELS.md
生成数据模型文档，包括：
- 数据库 ER 图（使用 ASCII 图）
- 所有表的字段说明
- TypeScript 类型定义
- Storage 结构（如有）

## 6. knowledge/KEY-FLOWS.md
生成关键流程文档，包括：
- 核心业务流程图
- 用户操作流程
- 数据流向

## 7. knowledge/INDEX.json
生成结构化索引，包括：
- 页面索引
- 组件索引
- API 索引
- 模块索引
- 类型索引
- 依赖关系

---

**要求：**
1. 仔细阅读所有源代码文件
2. 使用 ASCII 图表展示架构和流程
3. 提供具体的文件路径
4. 保持文档的准确性和完整性
5. 使用中文编写文档

**开始分析并生成知识库文件。**
PROMPT_EOF

echo ""
echo -e "${CYAN}正在调用 Claude Code 分析项目...${NC}"
echo ""

# 调用 Claude Code 生成知识库
if claude -p \
    --dangerously-skip-permissions \
    --allowed-tools "Bash Read Write Glob Grep Edit" \
    < /tmp/knowledge-prompt.md 2>&1 | tee "$LOG_FILE"; then

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  知识库生成完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "生成的文件："
    ls -la "$KNOWLEDGE_DIR/"
    echo ""
    echo -e "${BLUE}下一步：${NC}"
    echo "1. 查看生成的知识库文件"
    echo "2. 在 CLAUDE.md 中添加知识库引用："
    echo ""
    echo "   ## 项目知识库"
    echo "   在开始开发前，请先阅读："
    echo "   - @knowledge/SUMMARY.md"
    echo "   - @knowledge/ARCHITECTURE.md"
    echo "   - @knowledge/MODULES.md"
    echo ""
else
    echo ""
    echo -e "${YELLOW}知识库生成过程遇到问题，请检查日志文件：${NC}"
    echo "$LOG_FILE"
fi

# 清理临时文件
rm -f /tmp/knowledge-prompt.md
