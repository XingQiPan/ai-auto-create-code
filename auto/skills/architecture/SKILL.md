# Architecture Skill

架构设计和代码组织的指导技能。

---

## 何时使用

- 开始新项目时设计架构
- 重构现有代码结构
- 添加新模块或功能
- 评估技术方案

---

## 架构原则

### 1. 关注点分离 (SoC)

```
src/
├── app/              # 页面/路由 - 处理 HTTP 请求
├── components/       # UI 组件 - 处理展示
├── lib/              # 业务逻辑 - 处理业务规则
│   ├── db/          # 数据访问 - 处理数据存储
│   ├── services/    # 服务层 - 处理复杂逻辑
│   └── utils/       # 工具函数 - 处理通用逻辑
└── types/            # 类型定义 - 处理数据结构
```

### 2. 单一职责原则 (SRP)

每个模块只做一件事：

```
// 好：职责单一
// lib/db/projects.ts - 只处理项目数据操作
export function getProjects() { ... }
export function createProject() { ... }

// lib/services/project-service.ts - 只处理项目业务逻辑
export function validateProjectInput() { ... }
export function calculateProjectProgress() { ... }
```

### 3. 依赖倒置原则 (DIP)

高层模块不依赖低层模块：

```
// 高层：业务逻辑
// lib/services/notification-service.ts
export async function sendNotification(
  userId: string,
  message: string,
  notifier: Notifier  // 抽象接口
) {
  await notifier.send(userId, message);
}

// 低层：具体实现
// lib/notifiers/email-notifier.ts
export const emailNotifier: Notifier = {
  async send(userId, message) {
    // 发送邮件
  }
};
```

---

## 分层架构

### 三层架构

```
┌─────────────────────────────────────────────────────────────┐
│                       表现层 (Presentation)                  │
│  - 页面组件                                                  │
│  - API 路由                                                  │
│  - 处理用户交互和 HTTP 请求                                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       业务层 (Business)                      │
│  - 服务类                                                    │
│  - 业务规则验证                                              │
│  - 工作流编排                                                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       数据层 (Data)                          │
│  - 数据访问对象 (DAO)                                        │
│  - 数据库操作                                                │
│  - 外部 API 调用                                             │
└─────────────────────────────────────────────────────────────┘
```

### Next.js App Router 分层

```
app/
├── page.tsx                    # 页面组件（表现层）
├── layout.tsx                  # 布局组件
├── api/
│   └── projects/
│       └── route.ts            # API 路由（表现层入口）
│
lib/
├── services/
│   └── project-service.ts      # 业务服务（业务层）
├── db/
│   └── projects.ts             # 数据访问（数据层）
└── utils/
    └── validation.ts           # 工具函数
```

---

## 目录结构模板

### 小型项目

```
src/
├── app/                    # Next.js App Router
│   ├── page.tsx
│   ├── layout.tsx
│   └── api/
├── components/             # React 组件
│   ├── ui/                # 基础 UI 组件
│   └── features/          # 功能组件
├── lib/                    # 核心库
│   ├── db/                # 数据库操作
│   └── utils.ts           # 工具函数
└── types/                  # TypeScript 类型
```

### 中型项目

```
src/
├── app/                    # 路由
│   ├── (auth)/            # 认证相关页面组
│   ├── (dashboard)/       # 仪表盘页面组
│   └── api/               # API 路由
├── components/
│   ├── ui/                # 基础组件
│   ├── layout/            # 布局组件
│   └── features/          # 功能组件
│       ├── auth/
│       └── projects/
├── lib/
│   ├── db/                # 数据访问层
│   │   ├── index.ts
│   │   ├── projects.ts
│   │   └── users.ts
│   ├── services/          # 业务服务层
│   │   ├── project-service.ts
│   │   └── auth-service.ts
│   ├── external/          # 外部服务
│   │   ├── ai/
│   │   └── storage/
│   └── utils/             # 工具函数
├── hooks/                  # 自定义 Hooks
├── store/                  # 状态管理
└── types/                  # 类型定义
```

### 大型项目

```
src/
├── app/
│   ├── (marketing)/       # 营销页面
│   ├── (app)/             # 应用页面
│   ├── (auth)/            # 认证页面
│   └── api/               # API
│       ├── v1/            # API 版本控制
│       └── v2/
├── components/
│   ├── ui/                # 基础 UI（可独立发布）
│   ├── layout/
│   ├── patterns/          # 设计模式组件
│   └── features/
├── lib/
│   ├── core/              # 核心库（可独立发布）
│   ├── db/
│   ├── services/
│   ├── external/
│   └── utils/
├── modules/               # 功能模块（垂直切分）
│   ├── auth/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── types/
│   └── projects/
├── hooks/
├── store/
└── types/
```

---

## 设计模式

### 1. Repository 模式

```typescript
// lib/db/repositories/project-repository.ts
export interface ProjectRepository {
  findById(id: string): Promise<Project | null>;
  findAll(options: QueryOptions): Promise<Project[]>;
  save(project: Project): Promise<Project>;
  delete(id: string): Promise<void>;
}

export class SupabaseProjectRepository implements ProjectRepository {
  constructor(private supabase: SupabaseClient) {}

  async findById(id: string): Promise<Project | null> {
    const { data, error } = await this.supabase
      .from('projects')
      .select('*')
      .eq('id', id)
      .single();

    if (error) return null;
    return data;
  }

  // ... 其他方法实现
}
```

### 2. Service 层模式

```typescript
// lib/services/project-service.ts
export class ProjectService {
  constructor(
    private projectRepo: ProjectRepository,
    private sceneRepo: SceneRepository,
    private aiService: AIService
  ) {}

  async createProject(input: CreateProjectInput): Promise<Project> {
    // 1. 验证输入
    this.validateInput(input);

    // 2. 创建项目
    const project = await this.projectRepo.save({
      title: input.title,
      story: input.story,
      stage: 'draft'
    });

    // 3. 触发后续操作
    await this.aiService.generateScenes(project.id, input.story);

    return project;
  }

  private validateInput(input: CreateProjectInput): void {
    if (!input.title || input.title.length < 3) {
      throw new ValidationError('标题至少3个字符');
    }
  }
}
```

### 3. Factory 模式

```typescript
// lib/factories/service-factory.ts
export class ServiceFactory {
  private static instances: Map<string, any> = new Map();

  static getProjectService(): ProjectService {
    if (!this.instances.has('projectService')) {
      const projectRepo = new SupabaseProjectRepository(getSupabaseClient());
      const sceneRepo = new SupabaseSceneRepository(getSupabaseClient());
      const aiService = new ZhipuAIService();

      this.instances.set(
        'projectService',
        new ProjectService(projectRepo, sceneRepo, aiService)
      );
    }
    return this.instances.get('projectService');
  }
}
```

---

## 架构决策记录 (ADR)

当做出重要架构决策时，记录下来：

```markdown
# ADR-001: 使用 Supabase 作为后端

## 状态
已接受

## 背景
项目需要用户认证、数据库和文件存储功能。

## 决策
使用 Supabase 作为 BaaS 平台。

## 理由
1. 提供开箱即用的认证
2. PostgreSQL 数据库，功能强大
3. 内置文件存储
4. 实时订阅功能
5. 免费层满足初期需求

## 后果
- 依赖 Supabase 平台
- 需要遵循 Row Level Security 策略
- 迁移成本较高
```

---

## 架构检查清单

- [ ] 目录结构清晰，职责分明
- [ ] 模块之间耦合度低
- [ ] 有适当的抽象层
- [ ] 错误处理统一
- [ ] 配置管理合理
- [ ] 有扩展性考虑
- [ ] 文档完整
