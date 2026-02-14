# Skills 目录说明

此目录包含增强 AI 开发能力的技能包。

## 可用技能

| 技能 | 用途 | 调用时机 |
|------|------|----------|
| `code-analysis` | 代码库分析 | 需要理解项目结构时 |
| `architecture` | 架构设计指导 | 设计新功能架构时 |
| `debug` | 调试诊断 | 遇到 bug 需要修复时 |
| `testing` | 测试生成 | 需要编写测试时 |
| `api-design` | API 设计 | 设计新 API 时 |
| `security` | 安全审计 | 检查安全问题时 |

## 使用方式

在 CLAUDE.md 中引用需要的技能：

```markdown
## 可用技能

在开发过程中，根据需要调用以下技能：

- @skills/code-analysis/SKILL.md - 代码分析技能
- @skills/debug/SKILL.md - 调试技能
- @skills/testing/SKILL.md - 测试技能
```

## 技能调用

AI 会根据任务类型自动判断是否需要使用技能：

```
任务：修复登录 bug
  → AI 读取 @skills/debug/SKILL.md
  → 按照调试流程定位问题
  → 应用修复模式

任务：设计新的 API
  → AI 读取 @skills/api-design/SKILL.md
  → 遵循 API 设计规范
  → 应用 RESTful 模式
```
