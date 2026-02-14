# Testing Skill

自动生成测试代码的技能。

---

## 何时使用

- 完成新功能开发后
- 修复 bug 后添加回归测试
- 重构代码前确保测试覆盖
- 提高代码测试覆盖率

---

## 测试原则

### 1. AAA 模式

```typescript
describe('功能名称', () => {
  it('应该正确处理某种情况', () => {
    // Arrange - 准备测试数据
    const input = 'test data';
    const expected = 'expected result';

    // Act - 执行被测试的代码
    const result = functionUnderTest(input);

    // Assert - 验证结果
    expect(result).toBe(expected);
  });
});
```

### 2. 测试命名规范

```typescript
// 好的测试命名
it('当输入为空时，应该返回 null')
it('当用户未登录时，应该抛出 UnauthorizedError')
it('当数量超过限制时，应该截断列表')

// 不好的测试命名
it('works')
it('test 1')
it('function test')
```

### 3. 边界条件测试

```typescript
describe('validateAge', () => {
  it('应该接受有效的年龄', () => {
    expect(validateAge(25)).toBe(true);
  });

  it('应该拒绝负数年龄', () => {
    expect(() => validateAge(-1)).toThrow('年龄不能为负数');
  });

  it('应该拒绝过大的年龄', () => {
    expect(() => validateAge(200)).toThrow('年龄不合法');
  });

  it('应该拒绝非数字输入', () => {
    expect(() => validateAge('abc' as any)).toThrow();
  });
});
```

---

## 测试模板

### React 组件测试

```typescript
// __tests__/components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '@/components/Button';

describe('Button', () => {
  it('应该正确渲染按钮文本', () => {
    render(<Button onClick={() => {}}>点击我</Button>);
    expect(screen.getByText('点击我')).toBeInTheDocument();
  });

  it('点击时应该调用 onClick', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>按钮</Button>);

    fireEvent.click(screen.getByText('按钮'));

    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('disabled 时应该不可点击', () => {
    const handleClick = jest.fn();
    render(
      <Button onClick={handleClick} disabled>
        按钮
      </Button>
    );

    fireEvent.click(screen.getByText('按钮'));

    expect(handleClick).not.toHaveBeenCalled();
  });
});
```

### API 路由测试

```typescript
// __tests__/api/users.test.ts
import { NextRequest } from 'next/server';
import { GET, POST } from '@/app/api/users/route';

describe('/api/users', () => {
  describe('GET', () => {
    it('应该返回用户列表', async () => {
      const request = new NextRequest('http://localhost/api/users');
      const response = await GET(request);
      const data = await response.json();

      expect(response.status).toBe(200);
      expect(Array.isArray(data.users)).toBe(true);
    });
  });

  describe('POST', () => {
    it('应该创建新用户', async () => {
      const request = new NextRequest('http://localhost/api/users', {
        method: 'POST',
        body: JSON.stringify({ name: 'Test', email: 'test@example.com' })
      });

      const response = await POST(request);
      const data = await response.json();

      expect(response.status).toBe(201);
      expect(data.user.name).toBe('Test');
    });

    it('缺少必填字段时应该返回 400', async () => {
      const request = new NextRequest('http://localhost/api/users', {
        method: 'POST',
        body: JSON.stringify({})
      });

      const response = await POST(request);

      expect(response.status).toBe(400);
    });
  });
});
```

### 工具函数测试

```typescript
// __tests__/lib/utils.test.ts
import { cn, formatDate, capitalize } from '@/lib/utils';

describe('cn (类名合并)', () => {
  it('应该合并多个类名', () => {
    expect(cn('foo', 'bar')).toBe('foo bar');
  });

  it('应该处理条件类名', () => {
    expect(cn('base', true && 'included', false && 'excluded')).toBe('base included');
  });

  it('应该过滤空值', () => {
    expect(cn('a', null, undefined, 'b')).toBe('a b');
  });
});

describe('formatDate', () => {
  it('应该正确格式化日期', () => {
    const date = new Date('2024-01-15');
    expect(formatDate(date)).toBe('2024-01-15');
  });
});

describe('capitalize', () => {
  it('应该首字母大写', () => {
    expect(capitalize('hello')).toBe('Hello');
  });

  it('空字符串应该返回空字符串', () => {
    expect(capitalize('')).toBe('');
  });
});
```

### 自定义 Hook 测试

```typescript
// __tests__/hooks/useCounter.test.ts
import { renderHook, act } from '@testing-library/react';
import { useCounter } from '@/hooks/useCounter';

describe('useCounter', () => {
  it('应该初始化为默认值', () => {
    const { result } = renderHook(() => useCounter());
    expect(result.current.count).toBe(0);
  });

  it('应该支持自定义初始值', () => {
    const { result } = renderHook(() => useCounter(10));
    expect(result.current.count).toBe(10);
  });

  it('increment 应该增加计数', () => {
    const { result } = renderHook(() => useCounter());

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });

  it('decrement 应该减少计数', () => {
    const { result } = renderHook(() => useCounter(5));

    act(() => {
      result.current.decrement();
    });

    expect(result.current.count).toBe(4);
  });
});
```

---

## Mock 指南

### Mock 模块

```typescript
// Mock 外部依赖
jest.mock('@/lib/db', () => ({
  getProjects: jest.fn(),
  createProject: jest.fn()
}));

import { getProjects, createProject } from '@/lib/db';

describe('Projects API', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('应该调用数据库获取项目', async () => {
    (getProjects as jest.Mock).mockResolvedValue([{ id: '1', title: 'Test' }]);

    // ... 测试代码

    expect(getProjects).toHaveBeenCalledWith({ page: 1, limit: 20 });
  });
});
```

### Mock 环境变量

```typescript
process.env.DATABASE_URL = 'test-database-url';
process.env.API_KEY = 'test-api-key';
```

### Mock 时间

```typescript
describe('时间相关测试', () => {
  beforeEach(() => {
    jest.useFakeTimers();
    jest.setSystemTime(new Date('2024-01-15'));
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('应该使用当前日期', () => {
    const result = getCurrentDate();
    expect(result).toBe('2024-01-15');
  });
});
```

---

## 测试覆盖率

### 运行覆盖率报告

```bash
# Jest
npm run test -- --coverage

# Vitest
npm run test -- --coverage
```

### 覆盖率目标

| 类型 | 目标 |
|------|------|
| 语句覆盖率 | ≥ 80% |
| 分支覆盖率 | ≥ 75% |
| 函数覆盖率 | ≥ 80% |
| 行覆盖率 | ≥ 80% |

---

## 测试检查清单

- [ ] 正常路径测试
- [ ] 边界条件测试
- [ ] 错误处理测试
- [ ] 空值/未定义测试
- [ ] 异步操作测试
- [ ] Mock 外部依赖
- [ ] 测试命名清晰
- [ ] 测试相互独立
