# =============================================================================
# init-project.ps1 - 项目智能初始化脚本 (PowerShell)
# =============================================================================
# 根据项目描述自动生成所有配置文件
#
# 用法 1: 交互式
#   .\init-project.ps1
#
# 用法 2: 指定描述文件
#   .\init-project.ps1 -DescriptionFile "project-description.md"
#
# 用法 3: 直接描述
#   .\init-project.ps1 -Description "这是一个 Python Flask 博客系统"
# =============================================================================

param(
    [string]$DescriptionFile,
    [string]$Description
)

$ErrorActionPreference = "Stop"

# 颜色函数
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Green { Write-ColorOutput Green $args }
function Write-Yellow { Write-ColorOutput Yellow $args }
function Write-Cyan { Write-ColorOutput Cyan $args }

Write-Output ""
Write-Output "========================================"
Write-Output "  Auto Coding Agent - 项目初始化器"
Write-Output "========================================"
Write-Output ""

# ============================================
# 获取项目描述
# ============================================

$projectDesc = ""

if ($DescriptionFile) {
    if (Test-Path $DescriptionFile) {
        Write-Cyan "从文件读取项目描述: $DescriptionFile"
        $projectDesc = Get-Content $DescriptionFile -Raw
    }
    else {
        Write-Output "错误: 文件 '$DescriptionFile' 不存在"
        exit 1
    }
}
elseif ($Description) {
    Write-Cyan "使用命令行描述"
    $projectDesc = $Description
}
else {
    # 交互式输入
    Write-Yellow "请描述你的项目（输入完成后按回车两次）:"
    Write-Yellow "示例: 这是一个使用 Python FastAPI + Vue.js 的任务管理系统"
    Write-Output ""

    $lines = @()
    do {
        $line = Read-Host
        if ($line -eq "") { break }
        $lines += $line
    } while ($true)

    $projectDesc = $lines -join "`n"
}

if ([string]::IsNullOrWhiteSpace($projectDesc)) {
    Write-Output "错误: 需要提供项目描述"
    exit 1
}

Write-Output ""
Write-Green "项目描述:"
Write-Output $projectDesc
Write-Output ""

# ============================================
# 创建临时提示词
# ============================================

# 使用 StringBuilder 避免here-string格式问题
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# 任务：初始化 Auto Coding Agent 项目配置")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("根据以下项目描述，生成完整的项目配置文件：")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("项目描述：")
[void]$sb.AppendLine($projectDesc)
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## 需要生成的文件")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("### 1. CLAUDE.md")
[void]$sb.AppendLine("生成完整的 Agent 工作指令文件，包括：")
[void]$sb.AppendLine("- 项目信息（根据描述推断技术栈）")
[void]$sb.AppendLine("- 知识库引用")
[void]$sb.AppendLine("- 技能引用")
[void]$sb.AppendLine("- 完整的工作流程")
[void]$sb.AppendLine("- 代码规范（根据技术栈定制）")
[void]$sb.AppendLine("- 测试要求（使用该技术栈的测试命令）")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("### 2. task.json")
[void]$sb.AppendLine("生成初始任务文件，包括：")
[void]$sb.AppendLine("- 项目基本信息")
[void]$sb.AppendLine("- 项目初始化任务（安装依赖、配置环境等）")
[void]$sb.AppendLine("- 基础架构搭建任务")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("### 3. progress.txt")
[void]$sb.AppendLine("生成初始进度文件模板")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("### 4. init.sh / init.ps1")
[void]$sb.AppendLine("生成环境初始化脚本，根据技术栈定制：")
[void]$sb.AppendLine("- 检测包管理器（npm/yarn/pnpm/pip/poetry/go mod 等）")
[void]$sb.AppendLine("- 安装依赖的命令")
[void]$sb.AppendLine("- 启动开发服务器的命令")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("### 5. technology.md（可选）")
[void]$sb.AppendLine("如果识别出技术栈，生成技术栈说明文件")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## 技术栈识别")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("根据项目描述，识别以下信息：")
[void]$sb.AppendLine("- 前端框架（React/Vue/Angular/Svelte/纯HTML/无前端）")
[void]$sb.AppendLine("- 后端框架（Express/FastAPI/Django/Flask/Spring/Go/无后端）")
[void]$sb.AppendLine("- 数据库（PostgreSQL/MySQL/MongoDB/SQLite/无数据库）")
[void]$sb.AppendLine("- 语言（TypeScript/JavaScript/Python/Go/Java/Rust）")
[void]$sb.AppendLine("- 包管理器（npm/yarn/pnpm/pip/poetry/cargo/go mod）")
[void]$sb.AppendLine("- 测试框架（Jest/Vitest/pytest/JUnit/Go test）")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## 输出要求")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("1. 每个文件用明确的分隔符标注")
[void]$sb.AppendLine("2. 文件内容完整，可直接使用")
[void]$sb.AppendLine("3. 根据识别的技术栈定制命令和规范")
[void]$sb.AppendLine("4. 如果描述不够具体，做出合理推断并标注")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("开始生成配置文件。")

$promptContent = $sb.ToString()

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$tempFile = Join-Path $env:TEMP "init-project-prompt-$timestamp.txt"
$promptContent | Out-File -FilePath $tempFile -Encoding utf8

# ============================================
# 调用 Claude 生成配置
# ============================================

Write-Cyan "正在分析项目描述并生成配置..."
Write-Output ""

# 检查 claude 命令是否可用
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue

if ($claudeCmd) {
    Start-Process -FilePath "claude" -ArgumentList @(
        "-p",
        "--dangerously-skip-permissions",
        "--allowed-tools", "Bash Read Write Glob Grep Edit"
    ) -RedirectStandardInput $tempFile -NoNewWindow -Wait
}
else {
    Write-Yellow "Claude CLI 未安装，请手动创建配置文件"
    Write-Output ""
    Write-Output "请将以下内容发送给 Claude 或其他 AI："
    Write-Output "=========================================="
    Get-Content $tempFile
    Write-Output "=========================================="
}

# 清理
if (Test-Path $tempFile) {
    Remove-Item $tempFile -Force
}

Write-Output ""
Write-Green "初始化完成！"
Write-Output ""
Write-Output "下一步："
Write-Output "1. 检查生成的配置文件"
Write-Output "2. 编辑 task.json 添加具体任务"
Write-Output "3. 运行 .\run-automation.ps1 -Runs 10 开始自动开发"
