# 模块清单

<!-- 此文件由 AI 自动生成，列出项目中的所有模块及其功能 -->

## 模块索引

### 按目录分类

<!-- 示例结构，请根据实际项目修改 -->

## 页面/路由模块

| 路径 | 功能 | 关键文件 |
|------|------|----------|
| `/` | 首页 | `app/page.tsx` |
| `/login` | 登录页 | `app/login/page.tsx` |
| `/register` | 注册页 | `app/register/page.tsx` |
| `/projects` | 项目列表 | `app/projects/page.tsx` |
| `/projects/[id]` | 项目详情 | `app/projects/[id]/page.tsx` |

## 组件模块

### 布局组件
| 组件 | 路径 | 功能 |
|------|------|------|
| Header | `components/layout/Header.tsx` | 顶部导航栏 |
| Footer | `components/layout/Footer.tsx` | 底部信息栏 |

### 认证组件
| 组件 | 路径 | 功能 |
|------|------|------|
| LoginForm | `components/auth/LoginForm.tsx` | 登录表单 |
| RegisterForm | `components/auth/RegisterForm.tsx` | 注册表单 |
| LogoutButton | `components/auth/LogoutButton.tsx` | 登出按钮 |

### 业务组件
| 组件 | 路径 | 功能 |
|------|------|------|
| [组件名] | `[路径]` | [功能描述] |

## API 模块

| 端点 | 方法 | 功能 | 文件 |
|------|------|------|------|
| `/api/projects` | GET | 获取项目列表 | `app/api/projects/route.ts` |
| `/api/projects` | POST | 创建项目 | `app/api/projects/route.ts` |
| `/api/projects/[id]` | GET | 获取项目详情 | `app/api/projects/[id]/route.ts` |
| `/api/projects/[id]` | PATCH | 更新项目 | `app/api/projects/[id]/route.ts` |
| `/api/projects/[id]` | DELETE | 删除项目 | `app/api/projects/[id]/route.ts` |

## 数据访问层

| 模块 | 路径 | 功能 |
|------|------|------|
| projects | `lib/db/projects.ts` | 项目数据操作 |
| scenes | `lib/db/scenes.ts` | 分镜数据操作 |
| media | `lib/db/media.ts` | 媒体数据操作 |

## 工具模块

| 模块 | 路径 | 功能 |
|------|------|------|
| utils | `lib/utils.ts` | 通用工具函数 |
| supabase/client | `lib/supabase/client.ts` | Supabase 客户端 |
| supabase/server | `lib/supabase/server.ts` | Supabase 服务端 |

## 类型定义

| 文件 | 路径 | 内容 |
|------|------|------|
| database | `types/database.ts` | 数据库类型定义 |
| ai | `types/ai.ts` | AI 相关类型定义 |

---

## 模块依赖关系

```
[页面] ──▶ [组件] ──▶ [数据访问层] ──▶ [数据库]
   │           │             │
   └───────────┴─────────────┘
               │
               ▼
         [工具模块]
```
