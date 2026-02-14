# 通用代码模式（全技术栈）

## Python 模式

### FastAPI 项目结构

```
project/
├── app/
│   ├── __init__.py
│   ├── main.py              # 入口文件
│   ├── config.py            # 配置
│   ├── api/
│   │   ├── __init__.py
│   │   └── v1/
│   │       ├── __init__.py
│   │       └── endpoints/
│   │           ├── users.py
│   │           └── items.py
│   ├── models/              # 数据模型
│   │   ├── __init__.py
│   │   └── user.py
│   ├── schemas/             # Pydantic 模型
│   │   ├── __init__.py
│   │   └── user.py
│   ├── services/            # 业务逻辑
│   │   ├── __init__.py
│   │   └── user_service.py
│   └── repositories/        # 数据访问
│       ├── __init__.py
│       └── user_repo.py
├── tests/
├── requirements.txt
└── pyproject.toml
```

### FastAPI 路由

```python
# app/api/v1/endpoints/users.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.user import UserCreate, UserResponse
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/", response_model=list[UserResponse])
async def list_users(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """获取用户列表"""
    service = UserService(db)
    return service.get_users(skip=skip, limit=limit)

@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    user: UserCreate,
    db: Session = Depends(get_db)
):
    """创建用户"""
    service = UserService(db)
    return service.create_user(user)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    """获取单个用户"""
    service = UserService(db)
    user = service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

### Python 测试

```python
# tests/test_users.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

class TestUsers:
    def test_list_users(self):
        response = client.get("/api/v1/users/")
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_create_user(self):
        response = client.post(
            "/api/v1/users/",
            json={"name": "Test", "email": "test@example.com"}
        )
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "Test"
```

---

## Go 模式

### Go 项目结构

```
project/
├── cmd/
│   └── server/
│       └── main.go          # 入口
├── internal/
│   ├── handler/             # HTTP 处理器
│   │   └── user.go
│   ├── service/             # 业务逻辑
│   │   └── user.go
│   ├── repository/          # 数据访问
│   │   └── user.go
│   └── model/               # 数据模型
│       └── user.go
├── pkg/
│   └── utils/
├── go.mod
└── go.sum
```

### Go HTTP Handler

```go
// internal/handler/user.go
package handler

import (
    "encoding/json"
    "net/http"
    "strconv"

    "github.com/gorilla/mux"
    "myapp/internal/service"
)

type UserHandler struct {
    service *service.UserService
}

func NewUserHandler(s *service.UserService) *UserHandler {
    return &UserHandler{service: s}
}

func (h *UserHandler) ListUsers(w http.ResponseWriter, r *http.Request) {
    users, err := h.service.GetAll(r.Context())
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(users)
}

func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    id, _ := strconv.Atoi(vars["id"])

    user, err := h.service.GetByID(r.Context(), id)
    if err != nil {
        http.Error(w, "User not found", http.StatusNotFound)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(user)
}
```

### Go 测试

```go
// internal/handler/user_test.go
package handler

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"

    "github.com/stretchr/testify/assert"
)

func TestListUsers(t *testing.T) {
    req := httptest.NewRequest(http.MethodGet, "/users", nil)
    rec := httptest.NewRecorder()

    handler := NewUserHandler(mockService)
    handler.ListUsers(rec, req)

    assert.Equal(t, http.StatusOK, rec.Code)
}
```

---

## Java/Spring 模式

### Spring Boot 项目结构

```
project/
├── src/
│   ├── main/
│   │   ├── java/com/example/
│   │   │   ├── Application.java
│   │   │   ├── controller/
│   │   │   │   └── UserController.java
│   │   │   ├── service/
│   │   │   │   └── UserService.java
│   │   │   ├── repository/
│   │   │   │   └── UserRepository.java
│   │   │   └── model/
│   │   │       └── User.java
│   │   └── resources/
│   │       └── application.yml
│   └── test/
│       └── java/com/example/
└── pom.xml
```

### Spring Controller

```java
// controller/UserController.java
package com.example.controller;

import com.example.model.User;
import com.example.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public List<User> getAllUsers() {
        return userService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return userService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public User createUser(@RequestBody User user) {
        return userService.save(user);
    }
}
```

---

## Vue.js 模式

### Vue 3 组件

```vue
<!-- components/UserList.vue -->
<script setup lang="ts">
import { ref, onMounted } from 'vue'

interface User {
  id: number
  name: string
  email: string
}

const users = ref<User[]>([])
const loading = ref(true)
const error = ref<string | null>(null)

const fetchUsers = async () => {
  try {
    const response = await fetch('/api/users')
    users.value = await response.json()
  } catch (e) {
    error.value = 'Failed to load users'
  } finally {
    loading.value = false
  }
}

onMounted(fetchUsers)
</script>

<template>
  <div class="user-list">
    <div v-if="loading">Loading...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <ul v-else>
      <li v-for="user in users" :key="user.id">
        {{ user.name }} - {{ user.email }}
      </li>
    </ul>
  </div>
</template>

<style scoped>
.user-list {
  padding: 1rem;
}
.error {
  color: red;
}
</style>
```

### Vue 测试

```typescript
// __tests__/UserList.spec.ts
import { mount } from '@vue/test-utils'
import UserList from '@/components/UserList.vue'
import { describe, it, expect, vi } from 'vitest'

describe('UserList', () => {
  it('renders loading state', () => {
    const wrapper = mount(UserList)
    expect(wrapper.text()).toContain('Loading')
  })
})
```

---

## 通用模式

### 环境变量管理

```bash
# .env.example (通用模板)
# 数据库
DATABASE_URL=
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=
DB_PASSWORD=

# API
API_PORT=3000
API_KEY=

# 认证
JWT_SECRET=
SESSION_SECRET=

# 外部服务
# ...
```

### Docker 配置

```dockerfile
# Dockerfile (通用模板)
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/main.js"]
```

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npm run lint
      - run: npm run test
      - run: npm run build
```
