# API Design Skill

设计 RESTful API 的规范和模式。

---

## 何时使用

- 设计新的 API 端点
- 重构现有 API
- API 版本升级
- API 文档编写

---

## RESTful 设计原则

### URL 设计

```
# 资源命名（名词，复数）
GET    /api/users           # 获取用户列表
GET    /api/users/:id       # 获取单个用户
POST   /api/users           # 创建用户
PATCH  /api/users/:id       # 更新用户
DELETE /api/users/:id       # 删除用户

# 嵌套资源
GET    /api/users/:id/posts         # 用户的文章列表
GET    /api/users/:id/posts/:postId # 用户的特定文章

# 动作（当不能用名词表达时）
POST   /api/users/:id/activate      # 激活用户
POST   /api/orders/:id/cancel       # 取消订单
```

### HTTP 方法

| 方法 | 用途 | 是否幂等 |
|------|------|----------|
| GET | 获取资源 | 是 |
| POST | 创建资源 | 否 |
| PUT | 完整更新 | 是 |
| PATCH | 部分更新 | 是 |
| DELETE | 删除资源 | 是 |

### 状态码

| 状态码 | 含义 | 使用场景 |
|--------|------|----------|
| 200 | OK | 成功 |
| 201 | Created | 创建成功 |
| 204 | No Content | 删除成功 |
| 400 | Bad Request | 参数错误 |
| 401 | Unauthorized | 未登录 |
| 403 | Forbidden | 无权限 |
| 404 | Not Found | 资源不存在 |
| 409 | Conflict | 资源冲突 |
| 422 | Unprocessable Entity | 验证失败 |
| 500 | Internal Server Error | 服务器错误 |

---

## API 模板

### 标准 CRUD API

```typescript
// app/api/projects/route.ts
import { NextResponse } from 'next/server';
import { getServerSession } from '@/lib/auth';
import {
  getProjects,
  createProject,
  validateProjectInput
} from '@/lib/db/projects';

// GET /api/projects - 获取列表
export async function GET(request: Request) {
  try {
    const session = await getServerSession();
    if (!session) {
      return NextResponse.json(
        { error: { code: 'UNAUTHORIZED', message: '请先登录' } },
        { status: 401 }
      );
    }

    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '20');

    const { projects, total } = await getProjects(session.user.id, { page, limit });

    return NextResponse.json({
      projects,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('GET /api/projects error:', error);
    return NextResponse.json(
      { error: { code: 'INTERNAL_ERROR', message: '服务器错误' } },
      { status: 500 }
    );
  }
}

// POST /api/projects - 创建
export async function POST(request: Request) {
  try {
    const session = await getServerSession();
    if (!session) {
      return NextResponse.json(
        { error: { code: 'UNAUTHORIZED', message: '请先登录' } },
        { status: 401 }
      );
    }

    const body = await request.json();

    // 输入验证
    const validation = validateProjectInput(body);
    if (!validation.valid) {
      return NextResponse.json(
        { error: { code: 'VALIDATION_ERROR', message: validation.message } },
        { status: 400 }
      );
    }

    const project = await createProject({
      ...body,
      userId: session.user.id
    });

    return NextResponse.json({ project }, { status: 201 });
  } catch (error) {
    console.error('POST /api/projects error:', error);
    return NextResponse.json(
      { error: { code: 'INTERNAL_ERROR', message: '服务器错误' } },
      { status: 500 }
    );
  }
}
```

### 单个资源 API

```typescript
// app/api/projects/[id]/route.ts
import { NextResponse } from 'next/server';
import { getServerSession } from '@/lib/auth';
import {
  getProjectById,
  updateProject,
  deleteProject,
  isProjectOwner
} from '@/lib/db/projects';

// GET /api/projects/:id - 获取详情
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const session = await getServerSession();
    if (!session) {
      return NextResponse.json(
        { error: { code: 'UNAUTHORIZED', message: '请先登录' } },
        { status: 401 }
      );
    }

    const project = await getProjectById(params.id);

    if (!project) {
      return NextResponse.json(
        { error: { code: 'NOT_FOUND', message: '项目不存在' } },
        { status: 404 }
      );
    }

    if (project.user_id !== session.user.id) {
      return NextResponse.json(
        { error: { code: 'FORBIDDEN', message: '无权访问此项目' } },
        { status: 403 }
      );
    }

    return NextResponse.json({ project });
  } catch (error) {
    console.error('GET /api/projects/:id error:', error);
    return NextResponse.json(
      { error: { code: 'INTERNAL_ERROR', message: '服务器错误' } },
      { status: 500 }
    );
  }
}

// PATCH /api/projects/:id - 部分更新
export async function PATCH(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const session = await getServerSession();
    if (!session) {
      return NextResponse.json(
        { error: { code: 'UNAUTHORIZED', message: '请先登录' } },
        { status: 401 }
      );
    }

    if (!await isProjectOwner(params.id, session.user.id)) {
      return NextResponse.json(
        { error: { code: 'FORBIDDEN', message: '无权修改此项目' } },
        { status: 403 }
      );
    }

    const body = await request.json();
    const project = await updateProject(params.id, body);

    return NextResponse.json({ project });
  } catch (error) {
    console.error('PATCH /api/projects/:id error:', error);
    return NextResponse.json(
      { error: { code: 'INTERNAL_ERROR', message: '服务器错误' } },
      { status: 500 }
    );
  }
}

// DELETE /api/projects/:id - 删除
export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const session = await getServerSession();
    if (!session) {
      return NextResponse.json(
        { error: { code: 'UNAUTHORIZED', message: '请先登录' } },
        { status: 401 }
      );
    }

    if (!await isProjectOwner(params.id, session.user.id)) {
      return NextResponse.json(
        { error: { code: 'FORBIDDEN', message: '无权删除此项目' } },
        { status: 403 }
      );
    }

    await deleteProject(params.id);

    return new NextResponse(null, { status: 204 });
  } catch (error) {
    console.error('DELETE /api/projects/:id error:', error);
    return NextResponse.json(
      { error: { code: 'INTERNAL_ERROR', message: '服务器错误' } },
      { status: 500 }
    );
  }
}
```

### 动作 API

```typescript
// app/api/projects/[id]/publish/route.ts
import { NextResponse } from 'next/server';

// POST /api/projects/:id/publish - 发布项目
export async function POST(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    // ... 认证和权限检查

    // 执行发布逻辑
    const result = await publishProject(params.id);

    return NextResponse.json({
      success: true,
      publishedAt: result.publishedAt
    });
  } catch (error) {
    // ... 错误处理
  }
}
```

---

## 请求/响应格式

### 成功响应

```json
// 单个资源
{
  "project": {
    "id": "uuid",
    "title": "项目名称",
    "createdAt": "2024-01-15T00:00:00Z"
  }
}

// 列表
{
  "projects": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}

// 创建成功（201）
{
  "project": { ... }
}

// 操作成功（无返回体）
204 No Content
```

### 错误响应

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "标题不能为空",
    "details": [
      {
        "field": "title",
        "message": "标题不能为空"
      }
    ]
  }
}
```

---

## API 设计检查清单

- [ ] URL 使用名词复数
- [ ] 使用正确的 HTTP 方法
- [ ] 返回正确的状态码
- [ ] 包含认证检查
- [ ] 包含权限检查
- [ ] 输入验证完整
- [ ] 错误格式统一
- [ ] 支持分页（列表接口）
- [ ] 有适当的错误日志
