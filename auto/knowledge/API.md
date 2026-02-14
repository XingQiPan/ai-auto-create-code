# API 文档

<!-- 此文件由 AI 自动生成，描述项目的所有 API 接口 -->

## API 概览

- **Base URL**: `/api`
- **认证方式**: [如: Supabase Auth / JWT]
- **响应格式**: JSON

---

## 认证 API

### 登录
```
POST /api/auth/login
```

**请求体:**
```json
{
  "email": "string",
  "password": "string"
}
```

**响应:**
```json
{
  "success": true,
  "user": { ... }
}
```

### 注册
```
POST /api/auth/register
```

**请求体:**
```json
{
  "email": "string",
  "password": "string"
}
```

---

## 项目 API

### 获取项目列表
```
GET /api/projects?page=1&limit=20
```

**响应:**
```json
{
  "projects": [...],
  "total": 100,
  "page": 1,
  "limit": 20
}
```

### 创建项目
```
POST /api/projects
```

**请求体:**
```json
{
  "title": "string",
  "story": "string",
  "style": "string"
}
```

### 获取项目详情
```
GET /api/projects/:id
```

### 更新项目
```
PATCH /api/projects/:id
```

### 删除项目
```
DELETE /api/projects/:id
```

---

## 生成 API

### 生成分镜
```
POST /api/generate/scenes
```

**请求体:**
```json
{
  "projectId": "string"
}
```

### 生成图片
```
POST /api/generate/image/:sceneId
```

### 生成视频
```
POST /api/generate/video/:sceneId
```

---

## 确认 API

### 确认分镜描述
```
POST /api/scenes/:id/confirm-description
```

### 确认图片
```
POST /api/scenes/:id/confirm-image
```

### 确认视频
```
POST /api/scenes/:id/confirm-video
```

---

## 错误响应格式

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述"
  }
}
```

### 常见错误码

| 状态码 | 错误码 | 描述 |
|--------|--------|------|
| 400 | VALIDATION_ERROR | 请求参数错误 |
| 401 | UNAUTHORIZED | 未登录 |
| 403 | FORBIDDEN | 无权限 |
| 404 | NOT_FOUND | 资源不存在 |
| 500 | INTERNAL_ERROR | 服务器错误 |
