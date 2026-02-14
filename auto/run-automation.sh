#!/bin/bash

# =============================================================================
# run-automation.sh - 全自动任务执行器
# =============================================================================
# 此脚本循环调用 Claude Code，自动完成 task.json 中定义的所有任务
#
# 用法: ./run-automation.sh <运行次数>
# 示例: ./run-automation.sh 10
#
# 工作原理:
# 1. 读取 task.json 中 passes: false 的任务数量
# 2. 调用 Claude Code 执行一个任务
# 3. 检查剩余任务数量
# 4. 重复直到所有任务完成或达到运行次数上限
# =============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================
# 配置区域 - 根据你的项目修改
# ============================================

# Claude Code 提示词模板
# 可以根据项目需要自定义
PROMPT_TEMPLATE='Please follow the workflow in CLAUDE.md:
1. Read task.json and select the next task with passes: false
2. Implement the task following all steps
3. Test thoroughly (run npm run lint and npm run build)
4. Update progress.txt with your work
5. Commit all changes including task.json update in a single commit

Start by reading task.json to find your task.
Please complete only one task in this session, and stop once you are done or if you encounter an unresolvable issue.'

# 日志目录
LOG_DIR="./automation-logs"

# ============================================
# 核心逻辑 - 通常不需要修改
# ============================================

# 创建日志目录
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/automation-$(date +%Y%m%d_%H%M%S).log"

# 日志函数
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" >> "$LOG_FILE"

    case $level in
        INFO)
            echo -e "${BLUE}[INFO]${NC} ${message}"
            ;;
        SUCCESS)
            echo -e "${GREEN}[SUCCESS]${NC} ${message}"
            ;;
        WARNING)
            echo -e "${YELLOW}[WARNING]${NC} ${message}"
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} ${message}"
            ;;
        PROGRESS)
            echo -e "${CYAN}[PROGRESS]${NC} ${message}"
            ;;
    esac
}

# 计算剩余任务数量
count_remaining_tasks() {
    if [ -f "task.json" ]; then
        local count=$(grep -c '"passes": false' task.json 2>/dev/null || echo "0")
        echo "$count"
    else
        echo "0"
    fi
}

# 检查参数
if [ -z "$1" ]; then
    echo "用法: $0 <运行次数>"
    echo "示例: $0 10"
    echo ""
    echo "说明: 脚本会循环运行 Claude Code，每次完成一个任务"
    echo "      所有任务完成后会自动提前结束"
    exit 1
fi

# 验证参数是数字
if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "错误: 参数必须是正整数"
    exit 1
fi

TOTAL_RUNS=$1

# 启动横幅
echo ""
echo "========================================"
echo "  Claude Code 自动化执行器"
echo "========================================"
echo ""

log "INFO" "开始自动化执行，最多运行 $TOTAL_RUNS 次"
log "INFO" "日志文件: $LOG_FILE"

# 检查必要文件
if [ ! -f "task.json" ]; then
    log "ERROR" "找不到 task.json！请在项目根目录运行此脚本。"
    exit 1
fi

if [ ! -f "CLAUDE.md" ]; then
    log "WARNING" "找不到 CLAUDE.md，Agent 可能无法正确执行任务"
fi

# 初始任务计数
INITIAL_TASKS=$(count_remaining_tasks)
log "INFO" "开始时剩余任务数: $INITIAL_TASKS"

if [ "$INITIAL_TASKS" -eq 0 ]; then
    log "SUCCESS" "所有任务已完成！无需执行。"
    exit 0
fi

# 主循环
for ((run=1; run<=TOTAL_RUNS; run++)); do
    echo ""
    echo "========================================"
    log "PROGRESS" "第 $run 次运行 / 共 $TOTAL_RUNS 次"
    echo "========================================"

    # 检查剩余任务
    REMAINING=$(count_remaining_tasks)

    if [ "$REMAINING" -eq 0 ]; then
        log "SUCCESS" "所有任务已完成！没有更多任务需要处理。"
        log "INFO" "自动化在第 $((run-1)) 次运行后提前结束"
        exit 0
    fi

    log "INFO" "本次运行前剩余任务: $REMAINING"

    # 记录运行开始时间
    RUN_START=$(date +%s)
    RUN_LOG="$LOG_DIR/run-${run}-$(date +%Y%m%d_%H%M%S).log"

    log "INFO" "启动 Claude Code 会话..."
    log "INFO" "运行日志: $RUN_LOG"

    # 创建临时提示词文件
    PROMPT_FILE=$(mktemp)
    echo "$PROMPT_TEMPLATE" > "$PROMPT_FILE"

    # 运行 Claude Code
    # --dangerously-skip-permissions: 跳过所有权限检查
    # --allowed-tools: 允许使用的工具列表
    if claude -p \
        --dangerously-skip-permissions \
        --allowed-tools "Bash Edit Read Write Glob Grep Task WebSearch WebFetch mcp__playwright__*" \
        < "$PROMPT_FILE" 2>&1 | tee "$RUN_LOG"; then

        RUN_END=$(date +%s)
        RUN_DURATION=$((RUN_END - RUN_START))

        log "SUCCESS" "第 $run 次运行完成，耗时 ${RUN_DURATION} 秒"
    else
        RUN_END=$(date +%s)
        RUN_DURATION=$((RUN_END - RUN_START))

        log "WARNING" "第 $run 次运行以非零退出码结束，耗时 ${RUN_DURATION} 秒"
    fi

    # 清理临时文件
    rm -f "$PROMPT_FILE"

    # 检查运行后的任务状态
    REMAINING_AFTER=$(count_remaining_tasks)
    COMPLETED=$((REMAINING - REMAINING_AFTER))

    if [ "$COMPLETED" -gt 0 ]; then
        log "SUCCESS" "本次运行完成的任务数: $COMPLETED"
    else
        log "WARNING" "本次运行没有任务被标记为完成"
        log "WARNING" "可能原因: 任务阻塞、需要人工介入、或 Agent 遇到错误"
    fi

    log "INFO" "第 $run 次运行后剩余任务: $REMAINING_AFTER"

    # 日志分隔
    echo "" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"

    # 运行间隔
    if [ $run -lt $TOTAL_RUNS ]; then
        log "INFO" "等待 2 秒后开始下一次运行..."
        sleep 2
    fi
done

# 最终总结
echo ""
echo "========================================"
log "SUCCESS" "自动化执行结束！"
echo "========================================"

FINAL_REMAINING=$(count_remaining_tasks)
TOTAL_COMPLETED=$((INITIAL_TASKS - FINAL_REMAINING))

log "INFO" "执行总结:"
log "INFO" "  - 总运行次数: $TOTAL_RUNS"
log "INFO" "  - 完成任务数: $TOTAL_COMPLETED"
log "INFO" "  - 剩余任务数: $FINAL_REMAINING"
log "INFO" "  - 日志目录: $LOG_DIR"

if [ "$FINAL_REMAINING" -eq 0 ]; then
    log "SUCCESS" "所有任务已完成！"
else
    log "WARNING" "仍有任务未完成。你可以再次运行脚本继续执行。"
    log "INFO" "运行命令: ./run-automation.sh $FINAL_REMAINING"
fi
