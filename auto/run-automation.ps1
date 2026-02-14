# =============================================================================
# run-automation.ps1 - 全自动任务执行器 (PowerShell)
# =============================================================================
# 此脚本循环调用 Claude Code，自动完成 task.json 中定义的所有任务
#
# 用法: .\run-automation.ps1 -Runs <运行次数>
# 示例: .\run-automation.ps1 -Runs 10
#
# 工作原理:
# 1. 读取 task.json 中 passes: false 的任务数量
# 2. 调用 Claude Code 执行一个任务
# 3. 检查剩余任务数量
# 4. 重复直到所有任务完成或达到运行次数上限
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [int]$Runs
)

$ErrorActionPreference = "Stop"

# ============================================
# 配置区域 - 根据你的项目修改
# ============================================

# Claude Code 提示词模板
$PROMPT_TEMPLATE = @'
Please follow the workflow in CLAUDE.md:
1. Read task.json and select the next task with passes: false
2. Implement the task following all steps
3. Test thoroughly (run npm run lint and npm run build)
4. Update progress.txt with your work
5. Commit all changes including task.json update in a single commit

Start by reading task.json to find your task.
Please complete only one task in this session, and stop once you are done or if you encounter an unresolvable issue.
'@

# 日志目录
$LOG_DIR = ".\automation-logs"

# ============================================
# 核心逻辑 - 通常不需要修改
# ============================================

# 颜色函数
function Write-Log {
    param([string]$Level, [string]$Message)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    Add-Content -Path $script:LOG_FILE -Value $logEntry

    switch ($Level) {
        "INFO" { Write-ColorOutput Cyan "[INFO]" $Message }
        "SUCCESS" { Write-ColorOutput Green "[SUCCESS]" $Message }
        "WARNING" { Write-ColorOutput Yellow "[WARNING]" $Message }
        "ERROR" { Write-ColorOutput Red "[ERROR]" $Message }
        "PROGRESS" { Write-ColorOutput Cyan "[PROGRESS]" $Message }
    }
}

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# 计算剩余任务数量
function Get-RemainingTasks {
    if (Test-Path "task.json") {
        $content = Get-Content "task.json" -Raw
        $matches = [regex]::Matches($content, '"passes":\s*false')
        return $matches.Count
    }
    return 0
}

# 创建日志目录
if (-not (Test-Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$script:LOG_FILE = Join-Path $LOG_DIR "automation-$timestamp.log"

# 启动横幅
Write-Output ""
Write-Output "========================================"
Write-Output "  Claude Code 自动化执行器 (PowerShell)"
Write-Output "========================================"
Write-Output ""

Write-Log "INFO" "开始自动化执行，最多运行 $Runs 次"
Write-Log "INFO" "日志文件: $script:LOG_FILE"

# 检查必要文件
if (-not (Test-Path "task.json")) {
    Write-Log "ERROR" "找不到 task.json！请在项目根目录运行此脚本。"
    exit 1
}

if (-not (Test-Path "CLAUDE.md")) {
    Write-Log "WARNING" "找不到 CLAUDE.md，Agent 可能无法正确执行任务"
}

# 初始任务计数
$initialTasks = Get-RemainingTasks
Write-Log "INFO" "开始时剩余任务数: $initialTasks"

if ($initialTasks -eq 0) {
    Write-Log "SUCCESS" "所有任务已完成！无需执行。"
    exit 0
}

# 主循环
for ($run = 1; $run -le $Runs; $run++) {
    Write-Output ""
    Write-Output "========================================"
    Write-Log "PROGRESS" "第 $run 次运行 / 共 $Runs 次"
    Write-Output "========================================"

    # 检查剩余任务
    $remaining = Get-RemainingTasks

    if ($remaining -eq 0) {
        Write-Log "SUCCESS" "所有任务已完成！没有更多任务需要处理。"
        Write-Log "INFO" "自动化在第 $($run-1) 次运行后提前结束"
        exit 0
    }

    Write-Log "INFO" "本次运行前剩余任务: $remaining"

    # 记录运行开始时间
    $runStart = Get-Date
    $runTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $runLog = Join-Path $LOG_DIR "run-$run-$runTimestamp.log"

    Write-Log "INFO" "启动 Claude Code 会话..."
    Write-Log "INFO" "运行日志: $runLog"

    # 创建临时提示词文件
    $tempFile = Join-Path $env:TEMP "claude-prompt-$timestamp.txt"
    $PROMPT_TEMPLATE | Out-File -FilePath $tempFile -Encoding utf8

    # 运行 Claude Code
    try {
        $process = Start-Process -FilePath "claude" -ArgumentList @(
            "-p",
            "--dangerously-skip-permissions",
            '--allowed-tools', 'Bash Edit Read Write Glob Grep Task WebSearch WebFetch mcp__playwright__*'
        ) -RedirectStandardInput $tempFile -RedirectStandardOutput $runLog -NoNewWindow -PassThru -Wait

        $runEnd = Get-Date
        $runDuration = ($runEnd - $runStart).TotalSeconds

        if ($process.ExitCode -eq 0) {
            Write-Log "SUCCESS" "第 $run 次运行完成，耗时 $([int]$runDuration) 秒"
        }
        else {
            Write-Log "WARNING" "第 $run 次运行以非零退出码结束，耗时 $([int]$runDuration) 秒"
        }
    }
    catch {
        Write-Log "ERROR" "运行 Claude Code 时出错: $_"
    }

    # 清理临时文件
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }

    # 检查运行后的任务状态
    $remainingAfter = Get-RemainingTasks
    $completed = $remaining - $remainingAfter

    if ($completed -gt 0) {
        Write-Log "SUCCESS" "本次运行完成的任务数: $completed"
    }
    else {
        Write-Log "WARNING" "本次运行没有任务被标记为完成"
        Write-Log "WARNING" "可能原因: 任务阻塞、需要人工介入、或 Agent 遇到错误"
    }

    Write-Log "INFO" "第 $run 次运行后剩余任务: $remainingAfter"

    # 日志分隔
    Add-Content -Path $script:LOG_FILE -Value ""
    Add-Content -Path $script:LOG_FILE -Value "----------------------------------------"
    Add-Content -Path $script:LOG_FILE -Value ""

    # 运行间隔
    if ($run -lt $Runs) {
        Write-Log "INFO" "等待 2 秒后开始下一次运行..."
        Start-Sleep -Seconds 2
    }
}

# 最终总结
Write-Output ""
Write-Output "========================================"
Write-Log "SUCCESS" "自动化执行结束！"
Write-Output "========================================"

$finalRemaining = Get-RemainingTasks
$totalCompleted = $initialTasks - $finalRemaining

Write-Log "INFO" "执行总结:"
Write-Log "INFO" "  - 总运行次数: $Runs"
Write-Log "INFO" "  - 完成任务数: $totalCompleted"
Write-Log "INFO" "  - 剩余任务数: $finalRemaining"
Write-Log "INFO" "  - 日志目录: $LOG_DIR"

if ($finalRemaining -eq 0) {
    Write-Log "SUCCESS" "所有任务已完成！"
}
else {
    Write-Log "WARNING" "仍有任务未完成。你可以再次运行脚本继续执行。"
    Write-Log "INFO" "运行命令: .\run-automation.ps1 -Runs $finalRemaining"
}
