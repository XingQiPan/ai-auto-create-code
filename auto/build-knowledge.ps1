# =============================================================================
# build-knowledge.ps1 - 自动构建项目知识库 (PowerShell)
# =============================================================================
# 此脚本调用 Claude Code 分析项目代码，自动生成知识库文档
#
# 用法: .\build-knowledge.ps1
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
function Write-Blue { Write-ColorOutput Blue $args }
function Write-Cyan { Write-ColorOutput Cyan $args }

# ============================================
# 配置区域
# ============================================

$KNOWLEDGE_DIR = ".\knowledge"
$LOG_DIR = ".\knowledge-logs"

# ============================================
# 主逻辑
# ============================================

Write-Output ""
Write-Output "========================================"
Write-Output "  项目知识库生成器 (PowerShell)"
Write-Output "========================================"
Write-Output ""

# 创建目录
if (-not (Test-Path $KNOWLEDGE_DIR)) {
    New-Item -ItemType Directory -Path $KNOWLEDGE_DIR | Out-Null
}
if (-not (Test-Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LOG_FILE = Join-Path $LOG_DIR "build-$timestamp.log"

Write-Yellow "将分析项目代码并生成知识库..."
Write-Output "日志文件: $LOG_FILE"

# 检查必要文件
if (-not (Test-Path "CLAUDE.md")) {
    Write-Yellow "警告: 找不到 CLAUDE.md"
}

if (-not (Test-Path "task.json")) {
    Write-Yellow "警告: 找不到 task.json"
}

# 知识库生成提示词
$promptContent = @'
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
'@

# 创建临时提示词文件
$tempFile = Join-Path $env:TEMP "knowledge-prompt-$timestamp.txt"
$promptContent | Out-File -FilePath $tempFile -Encoding utf8

Write-Output ""
Write-Cyan "正在调用 Claude Code 分析项目..."
Write-Output ""

# 调用 Claude Code 生成知识库
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue

if ($claudeCmd) {
    $runLog = Join-Path $LOG_DIR "claude-run-$timestamp.log"

    Start-Process -FilePath "claude" -ArgumentList @(
        "-p",
        "--dangerously-skip-permissions",
        '--allowed-tools', 'Bash Read Write Glob Grep Edit'
    ) -RedirectStandardInput $tempFile -RedirectStandardOutput $runLog -NoNewWindow -Wait

    Write-Output ""
    Write-Green "========================================"
    Write-Green "  知识库生成完成！"
    Write-Green "========================================"
    Write-Output ""
    Write-Output "生成的文件："
    Get-ChildItem $KNOWLEDGE_DIR | Format-Table Name, Length, LastWriteTime
    Write-Output ""
    Write-Blue "下一步："
    Write-Output "1. 查看生成的知识库文件"
    Write-Output "2. 在 CLAUDE.md 中添加知识库引用："
    Write-Output ""
    Write-Output "   ## 项目知识库"
    Write-Output "   在开始开发前，请先阅读："
    Write-Output "   - @knowledge/SUMMARY.md"
    Write-Output "   - @knowledge/ARCHITECTURE.md"
    Write-Output "   - @knowledge/MODULES.md"
    Write-Output ""
}
else {
    Write-Output ""
    Write-Yellow "Claude CLI 未安装，请手动创建知识库"
    Write-Output ""
    Write-Output "请将以下内容发送给 Claude 或其他 AI："
    Write-Output "=========================================="
    Write-Output $promptContent
    Write-Output "=========================================="
}

# 清理临时文件
if (Test-Path $tempFile) {
    Remove-Item $tempFile -Force
}
