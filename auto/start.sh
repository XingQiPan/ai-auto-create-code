#!/bin/bash

# =============================================================================
# start.sh - 统一启动脚本
# =============================================================================
# 提供统一的命令入口来管理项目
#
# 用法: ./start.sh [命令] [参数]
#
# 命令:
#   init          - 初始化项目环境（默认）
#   run           - 运行自动化任务
#   init-project  - 初始化新项目
#   build-kb      - 构建知识库
# =============================================================================

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# 显示系统信息
show_system_info() {
    echo ""
    echo -e "${MAGENTA}========================================${NC}"
    echo -e "${MAGENTA}  Auto Coding Agent - 统一启动器${NC}"
    echo -e "${MAGENTA}========================================${NC}"
    echo ""
    echo -e "${CYAN}系统信息:${NC}"
    echo "  工作目录: $(pwd)"
    echo ""
}

# 显示帮助
show_help() {
    echo ""
    echo -e "${CYAN}用法: ./start.sh [命令] [参数]${NC}"
    echo ""
    echo -e "${CYAN}命令:${NC}"
    echo "  init          - 初始化项目环境（默认）"
    echo "  run           - 运行自动化任务"
    echo "  init-project  - 初始化新项目"
    echo "  build-kb      - 构建知识库"
    echo ""
    echo -e "${CYAN}示例:${NC}"
    echo "  ./start.sh                    # 初始化环境"
    echo "  ./start.sh run 10             # 运行10次自动化"
    echo "  ./start.sh init-project       # 交互式创建新项目"
    echo "  ./start.sh init-project '描述' # 使用描述创建项目"
    echo "  ./start.sh build-kb           # 构建知识库"
    echo ""
}

# 执行脚本
execute_script() {
    local cmd=$1
    shift
    local args=("$@")

    # 命令映射
    local target_script=""
    case $cmd in
        init) target_script="init" ;;
        run) target_script="run-automation" ;;
        init-project) target_script="init-project" ;;
        build-kb) target_script="build-knowledge" ;;
        *) target_script=$cmd ;;
    esac

    local sh_script="$SCRIPT_DIR/${target_script}.sh"

    if [[ -f "$sh_script" ]]; then
        echo -e "${GREEN}执行: $sh_script${NC}"
        echo ""
        bash "$sh_script" "${args[@]}"
    else
        echo -e "${YELLOW}错误: 找不到脚本 $sh_script${NC}"
        exit 1
    fi
}

# 主入口
show_system_info

# 解析命令
COMMAND=${1:-init}
shift || true
ARGS=("$@")

if [[ "$COMMAND" == "help" ]] || [[ "$COMMAND" == "--help" ]] || [[ "$COMMAND" == "-h" ]]; then
    show_help
    exit 0
fi

case $COMMAND in
    init|run|init-project|build-kb)
        execute_script "$COMMAND" "${ARGS[@]}"
        ;;
    *)
        echo -e "${YELLOW}未知命令: $COMMAND${NC}"
        show_help
        exit 1
        ;;
esac
