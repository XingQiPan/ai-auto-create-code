# 常见代码模式

## 1. React 组件模式

### 基础组件

```tsx
import { FC } from 'react';

interface ButtonProps {
  onClick: () => void;
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
}

export const Button: FC<ButtonProps> = ({
  onClick,
  children,
  variant = 'primary'
}) => {
  return (
    <button
      onClick={onClick}
      className={`btn btn-${variant}`}
    >
      {children}
    </button>
  );
};
```

### 带状态的组件

```tsx
'use client';

import { useState, useCallback } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);

  const increment = useCallback(() => {
    setCount(prev => prev + 1);
  }, []);

  return (
    <div>
      <span>{count}</span>
      <button onClick={increment}>+1</button>
    </div>
  );
}
```

### 数据获取组件

```tsx
'use client';

import { useState, useEffect } from 'react';

interface DataFetcherProps<T> {
  url: string;
  render: (data: T) => React.ReactNode;
  loading?: React.ReactNode;
  error?: React.ReactNode;
}

export function DataFetcher<T>({
  url,
  render,
  loading = <div>Loading...</div>,
  error = <div>Error loading data</div>
}: DataFetcherProps<T>) {
  const [data, setData] = useState<T | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [hasError, setHasError] = useState(false);

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(setData)
      .catch(() => setHasError(true))
      .finally(() => setIsLoading(false));
  }, [url]);

  if (isLoading) return <>{loading}</>;
  if (hasError) return <>{error}</>;
  return <>{render(data!)}</>;
}
```

## 2. Next.js App Router 模式

### 页面组件

```tsx
// app/page.tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: '页面标题',
  description: '页面描述'
};

export default function HomePage() {
  return (
    <main>
      <h1>Welcome</h1>
    </main>
  );
}
```

### API 路由

```tsx
// app/api/users/route.ts
import { NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';

export async function GET(request: Request) {
  try {
    const session = await getServerSession();

    if (!session) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const users = await getUsers();

    return NextResponse.json({ users });
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal Server Error' },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();

    // 验证输入
    if (!body.name || !body.email) {
      return NextResponse.json(
        { error: 'Name and email are required' },
        { status: 400 }
      );
    }

    const user = await createUser(body);

    return NextResponse.json({ user }, { status: 201 });
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal Server Error' },
      { status: 500 }
    );
  }
}
```

### 服务端组件数据获取

```tsx
// app/projects/page.tsx
import { getProjects } from '@/lib/db/projects';

export default async function ProjectsPage() {
  const projects = await getProjects();

  return (
    <main>
      <h1>Projects</h1>
      <ul>
        {projects.map(project => (
          <li key={project.id}>{project.title}</li>
        ))}
      </ul>
    </main>
  );
}
```

## 3. 状态管理模式

### Zustand Store

```ts
// store/todoStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface Todo {
  id: string;
  title: string;
  completed: boolean;
}

interface TodoStore {
  todos: Todo[];
  addTodo: (title: string) => void;
  toggleTodo: (id: string) => void;
  deleteTodo: (id: string) => void;
}

export const useTodoStore = create<TodoStore>()(
  persist(
    (set) => ({
      todos: [],

      addTodo: (title) => set((state) => ({
        todos: [
          ...state.todos,
          {
            id: crypto.randomUUID(),
            title,
            completed: false
          }
        ]
      })),

      toggleTodo: (id) => set((state) => ({
        todos: state.todos.map(todo =>
          todo.id === id
            ? { ...todo, completed: !todo.completed }
            : todo
        )
      })),

      deleteTodo: (id) => set((state) => ({
        todos: state.todos.filter(todo => todo.id !== id)
      }))
    }),
    { name: 'todo-storage' }
  )
);
```

## 4. 错误处理模式

### API 错误类

```ts
// lib/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code: string = 'INTERNAL_ERROR'
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400, 'VALIDATION_ERROR');
    this.name = 'ValidationError';
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super(message, 401, 'UNAUTHORIZED');
    this.name = 'UnauthorizedError';
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND');
    this.name = 'NotFoundError';
  }
}
```

### 错误处理中间件

```ts
// lib/api-utils.ts
export function withErrorHandler(handler: Function) {
  return async (...args: any[]) => {
    try {
      return await handler(...args);
    } catch (error) {
      if (error instanceof AppError) {
        return NextResponse.json(
          { error: { code: error.code, message: error.message } },
          { status: error.statusCode }
        );
      }

      console.error('Unexpected error:', error);
      return NextResponse.json(
        { error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' } },
        { status: 500 }
      );
    }
  };
}
```
