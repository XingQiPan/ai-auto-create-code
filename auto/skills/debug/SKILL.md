# Debug Skill

系统化调试和修复 bug 的技能。

---

## 何时使用

- 程序运行出错，需要定位问题
- 功能不按预期工作
- 性能问题排查
- 修复测试失败

---

## 调试流程

### 步骤 1：复现问题

```
1. 确认问题可以稳定复现
2. 记录复现步骤
3. 确认预期行为 vs 实际行为
4. 收集错误信息（错误消息、堆栈跟踪）
```

### 步骤 2：定位问题

```
1. 分析错误堆栈，找到出错位置
2. 检查相关代码的最近修改
3. 使用二分法缩小问题范围
4. 添加日志/断点进行调试
```

### 步骤 3：分析根因

```
1. 理解代码的预期逻辑
2. 找出实际逻辑与预期的差异
3. 确定是逻辑错误、数据错误还是环境问题
```

### 步骤 4：修复并验证

```
1. 实现修复
2. 编写回归测试
3. 验证修复不影响其他功能
4. 提交代码
```

---

## 常见 Bug 类型

### 1. 空值/未定义错误

**症状：**
```
TypeError: Cannot read property 'x' of undefined
TypeError: null is not an object
```

**调试命令：**
```bash
# 查找可能的问题代码
grep -rn "\.\w\+\s*(" --include="*.ts" --include="*.tsx" | grep -v "?."
```

**修复模式：**
```tsx
// 错误
const name = user.profile.name;

// 正确：可选链
const name = user?.profile?.name;

// 正确：默认值
const name = user?.profile?.name ?? 'Unknown';

// 正确：条件检查
if (user?.profile) {
  const name = user.profile.name;
}
```

### 2. 异步问题

**症状：**
- 数据加载前就使用
- 竞态条件
- 请求顺序错误

**修复模式：**
```tsx
// 错误：没有等待数据
const [data, setData] = useState(null);
fetchData().then(setData);
console.log(data); // null

// 正确：使用 loading 状态
const [data, setData] = useState(null);
const [loading, setLoading] = useState(true);

useEffect(() => {
  fetchData()
    .then(setData)
    .finally(() => setLoading(false));
}, []);

if (loading) return <Loading />;
return <DataView data={data} />;
```

### 3. 状态更新问题

**症状：**
- UI 不更新
- 使用旧的状态值

**修复模式：**
```tsx
// 错误：直接修改状态
state.items.push(newItem);
setState(state);

// 正确：创建新对象
setState(prev => ({
  ...prev,
  items: [...prev.items, newItem]
}));

// 错误：依赖过时的闭包
const handleClick = () => {
  setTimeout(() => {
    console.log(count); // 可能是旧值
  }, 1000);
};

// 正确：使用 ref 或函数式更新
const countRef = useRef(count);
countRef.current = count;
```

### 4. 类型错误

**症状：**
```
Type 'string' is not assignable to type 'number'
Property 'x' does not exist on type 'Y'
```

**修复模式：**
```ts
// 添加类型守卫
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'email' in obj
  );
}

// 使用类型断言（谨慎）
const element = event.target as HTMLInputElement;

// 扩展类型定义
interface Window {
  myCustomProperty?: string;
}
```

---

## 调试工具命令

### 添加调试日志

```tsx
// 快速添加日志
console.log('🔍 Debug:', { variable, state, props });

// 使用 debugger 断点
debugger;

// 性能计时
console.time('operation');
// ... 操作
console.timeEnd('operation');
```

### React 调试

```tsx
// 使用 useEffect 调试状态变化
useEffect(() => {
  console.log('state changed:', state);
}, [state]);

// 使用 useRef 追踪渲染次数
const renderCount = useRef(0);
renderCount.current++;
console.log('Render count:', renderCount.current);
```

### 网络请求调试

```tsx
// 封装带日志的 fetch
async function debugFetch(url: string, options?: RequestInit) {
  console.log('📤 Request:', url, options);
  const response = await fetch(url, options);
  const data = await response.clone().json();
  console.log('📥 Response:', response.status, data);
  return response;
}
```

---

## 调试检查清单

- [ ] 能稳定复现问题吗？
- [ ] 错误消息是什么？
- [ ] 最近有相关代码修改吗？
- [ ] 相关的测试是否通过？
- [ ] 是否在正确的环境/配置下？
- [ ] 是否有异步操作未正确处理？
- [ ] 是否有空值/未定义的情况？
- [ ] 是否有类型不匹配？

---

## 修复报告模板

```markdown
## Bug 修复报告

### 问题描述
[描述 bug 的症状]

### 根本原因
[分析问题的根本原因]

### 修复方案
[描述修复方法]

### 修改文件
- [文件路径]: [修改说明]

### 测试验证
- [ ] 原问题已修复
- [ ] 添加了回归测试
- [ ] 相关功能正常工作

### 防止复发
[如何防止类似问题]
```
