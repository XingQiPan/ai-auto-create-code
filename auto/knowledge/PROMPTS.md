# 项目知识库模板

此目录存储 AI 自动生成的项目知识库，帮助后续开发快速理解代码。

---

## 知识库文件说明

| 文件 | 内容 | 用途 |
|------|------|------|
| `SUMMARY.md` | 项目概览 | 快速了解项目是做什么的 |
| `ARCHITECTURE.md` | 架构设计 | 理解项目整体结构 |
| `MODULES.md` | 模块清单 | 查找特定功能的代码位置 |
| `API.md` | API 文档 | 了解接口定义和使用方式 |
| `DATA-MODELS.md` | 数据模型 | 理解数据库结构和类型定义 |
| `KEY-FLOWS.md` | 关键流程 | 理解核心业务逻辑 |
| `INDEX.json` | 结构化索引 | 供 AI 快速检索 |

---

## 使用方式

**在 CLAUDE.md 中添加引用：**

```markdown
## 项目知识库

在开始开发前，请先阅读以下知识库文件了解项目：

- @knowledge/SUMMARY.md - 项目概览
- @knowledge/ARCHITECTURE.md - 架构设计
- @knowledge/MODULES.md - 模块清单
- @knowledge/API.md - API 文档
- @knowledge/DATA-MODELS.md - 数据模型
```

这样 AI 每次会话都能快速获取项目上下文。

---

## 生成命令

```bash
./build-knowledge.sh
```

此命令会分析代码库并自动生成/更新所有知识库文件。
