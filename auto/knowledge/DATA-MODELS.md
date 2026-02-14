# 数据模型

<!-- 此文件由 AI 自动生成，描述项目的数据结构 -->

## 数据库架构

### ER 图

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   projects  │       │   scenes    │       │   images    │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id          │───┐   │ id          │───┐   │ id          │
│ user_id     │   │   │ project_id  │   │   │ scene_id    │
│ title       │   │   │ order_index │   │   │ url         │
│ story       │   │   │ description │   │   │ path        │
│ style       │   │   │ confirmed   │   │   │ width       │
│ stage       │   │   │ status      │   └───│ height      │
│ created_at  │   │   │ created_at  │       │ version     │
│ updated_at  │   │   └─────────────┘       │ created_at  │
└─────────────┘   │                         └─────────────┘
                  │   ┌─────────────┐
                  │   │   videos    │
                  │   ├─────────────┤
                  └──▶│ id          │
                      │ scene_id    │
                      │ url         │
                      │ path        │
                      │ duration    │
                      │ task_id     │
                      │ version     │
                      │ created_at  │
                      └─────────────┘
```

---

## 表结构

### projects 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| user_id | UUID | 用户ID（外键） |
| title | VARCHAR(255) | 项目标题 |
| story | TEXT | 故事内容 |
| style | VARCHAR(50) | 视频风格 |
| stage | ENUM | 项目阶段 |
| created_at | TIMESTAMP | 创建时间 |
| updated_at | TIMESTAMP | 更新时间 |

**stage 枚举值:**
- `draft` - 草稿
- `scenes` - 分镜阶段
- `images` - 图片阶段
- `videos` - 视频阶段
- `completed` - 已完成

### scenes 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| project_id | UUID | 项目ID（外键） |
| order_index | INT | 排序索引 |
| description | TEXT | 场景描述 |
| description_confirmed | BOOLEAN | 描述是否确认 |
| image_status | ENUM | 图片状态 |
| image_confirmed | BOOLEAN | 图片是否确认 |
| video_status | ENUM | 视频状态 |
| video_confirmed | BOOLEAN | 视频是否确认 |
| created_at | TIMESTAMP | 创建时间 |

### images 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| scene_id | UUID | 场景ID（外键） |
| storage_path | VARCHAR(500) | 存储路径 |
| url | VARCHAR(500) | 图片URL |
| width | INT | 宽度 |
| height | INT | 高度 |
| version | INT | 版本号 |
| created_at | TIMESTAMP | 创建时间 |

### videos 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| scene_id | UUID | 场景ID（外键） |
| storage_path | VARCHAR(500) | 存储路径 |
| url | VARCHAR(500) | 视频URL |
| duration | FLOAT | 时长（秒） |
| task_id | VARCHAR(100) | 异步任务ID |
| version | INT | 版本号 |
| created_at | TIMESTAMP | 创建时间 |

---

## TypeScript 类型定义

```typescript
// 项目类型
interface Project {
  id: string;
  user_id: string;
  title: string;
  story: string | null;
  style: string;
  stage: 'draft' | 'scenes' | 'images' | 'videos' | 'completed';
  created_at: string;
  updated_at: string;
}

// 场景类型
interface Scene {
  id: string;
  project_id: string;
  order_index: number;
  description: string;
  description_confirmed: boolean;
  image_status: 'pending' | 'processing' | 'completed' | 'failed';
  image_confirmed: boolean;
  video_status: 'pending' | 'processing' | 'completed' | 'failed';
  video_confirmed: boolean;
  created_at: string;
}

// 图片类型
interface Image {
  id: string;
  scene_id: string;
  storage_path: string;
  url: string;
  width: number | null;
  height: number | null;
  version: number;
  created_at: string;
}

// 视频类型
interface Video {
  id: string;
  scene_id: string;
  storage_path: string;
  url: string;
  duration: number | null;
  task_id: string | null;
  version: number;
  created_at: string;
}
```

---

## Storage 结构

```
project-media/
└── {user_id}/
    └── {project_id}/
        ├── scene-1-{timestamp}.png
        ├── scene-2-{timestamp}.png
        ├── scene-1-{timestamp}.mp4
        └── ...
```
