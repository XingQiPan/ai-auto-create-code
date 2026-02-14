# =============================================================================
# start.ps1 - 跨平台启动脚本 (PowerShell)
# =============================================================================
# 自动检测操作系统并启动相应的初始化脚本
#
# 用法: .\start.ps1 [-Command <命令>] [-Args <参数>]
#
# 命令:
#   init          - 初始化项目环境（默认）
#   run           - 运行自动化任务
#   init-project  - 初始化新项目
#   build-kb      - 构建知识库
# =============================================================================

param(
    [Parameter(Position=0)]
    [ValidateSet("init", "run", "init-project", "build-kb")]
    [string]$Command = "init",

    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Args
)

$ErrorActionPreference = "Stop"

# 获取脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

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

# 显示系统信息
function Show-SystemInfo {
    Write-Output ""
    Write-ColorOutput Magenta "========================================"
    Write-ColorOutput Magenta "  Auto Coding Agent - 跨平台启动器"
    Write-ColorOutput Magenta "========================================"
    Write-Output ""
    Write-Cyan "系统信息:"
    Write-Output "  操作系统: $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription)"
    Write-Output "  系统类型: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)"
    Write-Output "  PowerShell: $($PSVersionTable.PSVersion)"
    Write-Output "  工作目录: $PWD"
    Write-Output ""
}

# 执行命令
function Invoke-Command {
    param([string]$Cmd, [string[]]$Arguments)

    $scriptPath = Join-Path $ScriptDir "$Cmd.ps1"

    if (-not (Test-Path $scriptPath)) {
        Write-Yellow "警告: 找不到脚本 $scriptPath"
        Write-Yellow "尝试使用 Bash 版本..."

        $bashPath = Join-Path $ScriptDir "$Cmd.sh"
        if (Test-Path $bashPath) {
            if (Get-Command bash -ErrorAction SilentlyContinue) {
                & bash $bashPath $Arguments
                return
            }
            else {
                Write-Output "错误: 未找到 bash，无法执行 .sh 脚本"
                exit 1
            }
        }
        else {
            Write-Output "错误: 找不到 $Cmd 脚本（.ps1 和 .sh 都不存在）"
            exit 1
        }
    }

    Write-Green "执行: $scriptPath"
    Write-Output ""

    switch ($Cmd) {
        "init" {
            & $scriptPath
        }
        "run-automation" {
            if ($Arguments.Count -eq 0) {
                $Arguments = @("10")  # 默认运行10次
            }
            & $scriptPath -Runs $Arguments[0]
        }
        "init-project" {
            if ($Arguments.Count -gt 0) {
                if (Test-Path $Arguments[0]) {
                    & $scriptPath -DescriptionFile $Arguments[0]
                }
                else {
                    & $scriptPath -Description ($Arguments -join " ")
                }
            }
            else {
                & $scriptPath
            }
        }
        "build-knowledge" {
            & $scriptPath
        }
        default {
            & $scriptPath @Arguments
        }
    }
}

# 显示帮助
function Show-Help {
    Write-Output ""
    Write-Cyan "用法: .\start.ps1 [-Command <命令>] [-Args <参数>]"
    Write-Output ""
    Write-Cyan "命令:"
    Write-Output "  init          - 初始化项目环境（默认）"
    Write-Output "  run           - 运行自动化任务"
    Write-Output "  init-project  - 初始化新项目"
    Write-Output "  build-kb      - 构建知识库"
    Write-Output ""
    Write-Cyan "示例:"
    Write-Output "  .\start.ps1                    # 初始化环境"
    Write-Output "  .\start.ps1 run 10             # 运行10次自动化"
    Write-Output "  .\start.ps1 init-project       # 交互式创建新项目"
    Write-Output "  .\start.ps1 init-project '描述' # 使用描述创建项目"
    Write-Output "  .\start.ps1 build-kb           # 构建知识库"
    Write-Output ""
}

# 主入口
Show-SystemInfo

# 命令映射
$commandMap = @{
    "init" = "init"
    "run" = "run-automation"
    "init-project" = "init-project"
    "build-kb" = "build-knowledge"
}

if ($Command -eq "help" -or $Args -contains "--help" -or $Args -contains "-h") {
    Show-Help
    exit 0
}

$targetScript = $commandMap[$Command]
if ($targetScript) {
    Invoke-Command -Cmd $targetScript -Arguments $Args
}
else {
    Write-Output "未知命令: $Command"
    Show-Help
    exit 1
}
