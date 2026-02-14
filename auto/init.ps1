# =============================================================================
# init.ps1 - 项目初始化脚本模板 (PowerShell)
# =============================================================================
# 每次 Agent 会话开始时运行此脚本，确保环境正确设置。
# =============================================================================

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
function Write-Red { Write-ColorOutput Red $args }

# ============================================
# 配置区域 - 根据你的项目修改以下变量
# ============================================

$PROJECT_NAME = "你的项目名称"
$PROJECT_DIR = "你的项目目录"  # 如: "my-app", "frontend", "src"
$PACKAGE_MANAGER = "npm"       # npm, yarn, pnpm
$DEV_COMMAND = "dev"           # dev, start, serve
$DEV_PORT = 3000               # 开发服务器端口

# ============================================
# 初始化逻辑 - 通常不需要修改
# ============================================

Write-Yellow "正在初始化 $PROJECT_NAME..."

# 检查项目目录是否存在
if (-not (Test-Path $PROJECT_DIR)) {
    Write-Red "错误: 项目目录 '$PROJECT_DIR' 不存在"
    Write-Output "请修改 init.ps1 中的 PROJECT_DIR 变量"
    exit 1
}

# 安装依赖
Write-Output "正在安装依赖..."
Push-Location $PROJECT_DIR
try {
    switch ($PACKAGE_MANAGER) {
        "npm" { npm install }
        "yarn" { yarn install }
        "pnpm" { pnpm install }
        default { npm install }
    }
}
finally {
    Pop-Location
}

# 启动开发服务器（后台运行）
Write-Output "正在启动开发服务器..."
Push-Location $PROJECT_DIR
try {
    switch ($PACKAGE_MANAGER) {
        "npm" { Start-Process -NoNewWindow npm -ArgumentList "run", $DEV_COMMAND }
        "yarn" { Start-Process -NoNewWindow yarn -ArgumentList $DEV_COMMAND }
        "pnpm" { Start-Process -NoNewWindow pnpm -ArgumentList "run", $DEV_COMMAND }
        default { Start-Process -NoNewWindow npm -ArgumentList "run", $DEV_COMMAND }
    }
}
finally {
    Pop-Location
}

# 等待服务器就绪
Write-Output "等待服务器启动..."
Start-Sleep -Seconds 5

# 检查服务器是否启动成功
try {
    $response = Invoke-WebRequest -Uri "http://localhost:$DEV_PORT" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($response) {
        Write-Green "✓ 初始化完成！"
        Write-Green "✓ 开发服务器运行在 http://localhost:$DEV_PORT"
    }
}
catch {
    Write-Yellow "⚠ 服务器可能还在启动中，请稍候..."
    Write-Yellow "⚠ 如果服务器未能启动，请手动检查"
}

Write-Output ""
Write-Output "准备就绪，可以开始开发。"
Write-Output ""
Write-Output "下一步："
Write-Output "1. 查看 task.json 了解任务列表"
Write-Output "2. 选择一个 passes: false 的任务开始"
Write-Output "3. 按照 CLAUDE.md 中的工作流程执行"
