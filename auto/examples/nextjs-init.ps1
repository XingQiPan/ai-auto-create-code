# =============================================================================
# init.ps1 - Next.js Todo App 示例初始化脚本 (PowerShell)
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

$PROJECT_NAME = "Todo App"
$PROJECT_DIR = "todo-app"
$DEV_PORT = 3000

Write-Yellow "正在初始化 $PROJECT_NAME..."

# 检查是否已存在项目目录
if (Test-Path $PROJECT_DIR) {
    Write-Yellow "项目目录已存在，跳过创建..."
}
else {
    Write-Output "创建 Next.js 项目..."
    npx create-next-app@latest $PROJECT_DIR --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --no-git
}

# 安装额外依赖
Write-Output "安装额外依赖..."
Push-Location $PROJECT_DIR
try {
    npm install zustand uuid
    npm install -D @types/uuid
}
finally {
    Pop-Location
}

# 创建目录结构
Write-Output "创建目录结构..."
$directories = @(
    "$PROJECT_DIR/src/components",
    "$PROJECT_DIR/src/hooks",
    "$PROJECT_DIR/src/types",
    "$PROJECT_DIR/src/store"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# 启动开发服务器
Write-Output "正在启动开发服务器..."
Push-Location $PROJECT_DIR
try {
    Start-Process -NoNewWindow npm -ArgumentList "run", "dev"
}
finally {
    Pop-Location
}

Start-Sleep -Seconds 5

Write-Output ""
Write-Green "✓ 初始化完成！"
Write-Green "✓ 开发服务器运行在 http://localhost:$DEV_PORT"
Write-Output ""
Write-Output "项目结构已创建："
Write-Output "  todo-app/src/components/  - 组件目录"
Write-Output "  todo-app/src/hooks/       - Hooks 目录"
Write-Output "  todo-app/src/types/       - 类型定义目录"
Write-Output "  todo-app/src/store/       - 状态管理目录"
Write-Output ""
Write-Output "下一步："
Write-Output "1. 复制 examples/nextjs-task.json 的内容到 task.json"
Write-Output "2. 运行 Agent 开始开发"
