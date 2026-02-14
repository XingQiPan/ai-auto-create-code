# Security Skill

安全审计和安全编码的技能。

---

## 何时使用

- 编写处理用户输入的代码
- 实现认证/授权功能
- 处理敏感数据
- 代码安全审计

---

## 安全检查清单

### 输入验证

```typescript
// ❌ 危险：直接使用用户输入
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ 安全：使用参数化查询
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('id', userId);

// ✅ 安全：使用 Zod 验证
import { z } from 'zod';

const UserInputSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  age: z.number().int().min(0).max(150)
});

function validateUserInput(input: unknown) {
  return UserInputSchema.parse(input);
}
```

### XSS 防护

```typescript
// ❌ 危险：直接渲染用户内容
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// ✅ 安全：使用 React 自动转义
<div>{userContent}</div>

// ✅ 安全：如果必须渲染 HTML，先清理
import DOMPurify from 'dompurify';

const cleanContent = DOMPurify.sanitize(userContent);
```

### CSRF 防护

```typescript
// Next.js API 路由自动处理 CSRF
// 确保 SameSite cookie 设置正确

// 在 middleware 中验证来源
export function middleware(request: NextRequest) {
  const origin = request.headers.get('origin');
  const host = request.headers.get('host');

  if (origin && !origin.includes(host || '')) {
    return new NextResponse('Forbidden', { status: 403 });
  }

  return NextResponse.next();
}
```

### 认证安全

```typescript
// ✅ 密码安全
import bcrypt from 'bcryptjs';

// 哈希密码
const hashedPassword = await bcrypt.hash(password, 10);

// 验证密码
const isValid = await bcrypt.compare(password, hashedPassword);

// ✅ Session 安全
const session = await getServerSession();
if (!session) {
  return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
}

// ✅ Token 验证
import { jwtVerify } from 'jose';

async function verifyToken(token: string) {
  try {
    const { payload } = await jwtVerify(
      token,
      new TextEncoder().encode(process.env.JWT_SECRET)
    );
    return payload;
  } catch {
    return null;
  }
}
```

---

## 敏感数据处理

### 环境变量

```typescript
// ❌ 危险：硬编码敏感信息
const apiKey = 'sk-xxxxx';

// ✅ 安全：使用环境变量
const apiKey = process.env.API_KEY;

if (!apiKey) {
  throw new Error('API_KEY is not configured');
}
```

### 日志安全

```typescript
// ❌ 危险：记录敏感信息
console.log('User login:', { email, password });

// ✅ 安全：脱敏处理
console.log('User login:', { email, password: '***' });

// ✅ 安全：使用日志脱敏工具
function sanitizeForLog(data: any): any {
  const sensitiveFields = ['password', 'token', 'apiKey', 'secret'];
  // ... 脱敏逻辑
}
```

### 响应数据过滤

```typescript
// ❌ 危险：返回完整用户对象
return NextResponse.json({ user });

// ✅ 安全：过滤敏感字段
const { password, ...safeUser } = user;
return NextResponse.json({ user: safeUser });

// ✅ 安全：使用选择字段
const safeUser = {
  id: user.id,
  email: user.email,
  name: user.name
};
```

---

## 安全头设置

```typescript
// next.config.js
const securityHeaders = [
  {
    key: 'X-DNS-Prefetch-Control',
    value: 'on'
  },
  {
    key: 'Strict-Transport-Security',
    value: 'max-age=63072000; includeSubDomains; preload'
  },
  {
    key: 'X-XSS-Protection',
    value: '1; mode=block'
  },
  {
    key: 'X-Frame-Options',
    value: 'SAMEORIGIN'
  },
  {
    key: 'X-Content-Type-Options',
    value: 'nosniff'
  },
  {
    key: 'Referrer-Policy',
    value: 'origin-when-cross-origin'
  },
  {
    key: 'Content-Security-Policy',
    value: "default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline';"
  }
];

module.exports = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: securityHeaders
      }
    ];
  }
};
```

---

## 常见漏洞防护

### SQL 注入

```typescript
// ✅ 使用 ORM/参数化查询
// Supabase/Prisma 自动防护

// ❌ 危险：字符串拼接
const query = `SELECT * FROM users WHERE id = ${id}`;

// ✅ 安全：使用 ORM
const user = await supabase
  .from('users')
  .select('*')
  .eq('id', id)
  .single();
```

### 路径遍历

```typescript
// ❌ 危险：直接使用用户输入的路径
const filePath = path.join(baseDir, userInput);

// ✅ 安全：验证和规范化路径
function safePath(baseDir: string, userInput: string): string {
  const resolved = path.resolve(baseDir, userInput);
  if (!resolved.startsWith(baseDir)) {
    throw new Error('Invalid path');
  }
  return resolved;
}
```

### 命令注入

```typescript
// ❌ 危险：直接执行用户输入
exec(`convert ${userFilename} output.png`);

// ✅ 安全：验证输入并使用参数数组
import { execFile } from 'child_process';

const allowedExtensions = ['.png', '.jpg', '.jpeg'];
const ext = path.extname(userFilename);

if (!allowedExtensions.includes(ext)) {
  throw new Error('Invalid file type');
}

execFile('convert', [userFilename, 'output.png']);
```

### 不安全的反序列化

```typescript
// ❌ 危险：不安全的反序列化
const obj = eval('(' + jsonString + ')');

// ✅ 安全：使用 JSON.parse
const obj = JSON.parse(jsonString);
```

---

## 权限控制

### RBAC（基于角色的访问控制）

```typescript
// lib/auth/rbac.ts
type Role = 'admin' | 'user' | 'guest';

const permissions: Record<Role, string[]> = {
  admin: ['read', 'write', 'delete', 'manage_users'],
  user: ['read', 'write'],
  guest: ['read']
};

export function hasPermission(role: Role, permission: string): boolean {
  return permissions[role]?.includes(permission) ?? false;
}

export function requirePermission(role: Role, permission: string) {
  if (!hasPermission(role, permission)) {
    throw new ForbiddenError(`需要 ${permission} 权限`);
  }
}
```

### 资源所有权检查

```typescript
// ✅ 始终验证资源所有权
export async function updateProject(
  projectId: string,
  userId: string,
  data: UpdateProjectInput
) {
  // 验证所有权
  const project = await getProjectById(projectId);

  if (!project) {
    throw new NotFoundError('项目不存在');
  }

  if (project.user_id !== userId) {
    throw new ForbiddenError('无权修改此项目');
  }

  // 执行更新
  return updateProjectInDb(projectId, data);
}
```

---

## 安全审计清单

- [ ] 所有用户输入都经过验证
- [ ] 使用参数化查询防止 SQL 注入
- [ ] 敏感数据不记录在日志中
- [ ] API 响应不包含敏感字段
- [ ] 认证和授权检查完整
- [ ] 安全头正确设置
- [ ] 环境变量正确配置
- [ ] 依赖包无已知漏洞
- [ ] 错误信息不泄露敏感信息
- [ ] 文件上传有类型和大小限制
