# Tasks: macOS 工作时间轴记录应用

## 1. 项目初始化
- [x] 1.1 创建 Xcode 项目（macOS App，SwiftUI lifecycle）
- [x] 1.2 配置项目基础设置（Bundle ID、签名、最低版本 macOS 14.0）
- [x] 1.3 创建基础目录结构（Models、Views、ViewModels、Services）

## 2. 数据层实现
- [x] 2.1 定义 SwiftData 模型（Entry、Tag）
- [x] 2.2 实现 ModelContainer 配置
- [x] 2.3 数据导出/备份功能（基础框架）

## 3. 主窗口应用框架
- [x] 3.1 实现完整桌面窗口（NavigationSplitView）
- [x] 3.2 实现侧边栏导航（时间筛选、标签筛选、AI 汇报入口）
- [x] 3.3 实现 MenuBarExtra 菜单栏图标（可选快捷入口）
- [x] 3.4 实现应用设置界面

## 4. 核心记录功能
- [x] 4.1 实现快速输入视图（极简单输入框）
- [x] 4.2 实现全局快捷键服务（HotKeyService）
- [x] 4.3 创建悬浮输入窗口（QuickEntryWindow）
- [x] 4.4 实现记录保存逻辑（支持 #标签 语法）
- [x] 4.5 支持 Markdown 格式输入

## 5. 时间轴视图
- [x] 5.1 实现时间轴列表视图（TimelineView）
- [x] 5.2 实现按日期分组展示（今天、昨天、具体日期）
- [x] 5.3 实现记录卡片组件（EntryCard）
- [x] 5.4 实现记录编辑/删除功能
- [x] 5.5 实现 Markdown 渲染

## 6. 标签与筛选
- [x] 6.1 实现标签展示（侧边栏标签列表）
- [x] 6.2 实现标签筛选功能
- [x] 6.3 实现时间范围筛选（今天、本周、本月、本季度）
- [x] 6.4 实现全文搜索功能

## 7. AI 辅助功能
- [x] 7.1 设计 AI Service 接口抽象（AIService）
- [x] 7.2 实现 OpenAI API 集成
- [x] 7.3 实现本地 Ollama 集成
- [x] 7.4 实现智能汇报生成功能（ReportGeneratorView）
- [x] 7.5 实现内容智能提取（关键数据、时间点、项目、标签建议）
- [x] 7.6 实现后台异步 AI 处理（不阻塞用户操作）

## 8. 设置与偏好
- [x] 8.1 实现设置界面（SettingsView）
- [x] 8.2 AI 配置（API Key、模型选择、Ollama 端点）
- [x] 8.3 通用设置（开机启动、菜单栏图标）
- [x] 8.4 数据管理（导出、导入、清除）

## 9. 测试与优化
- [x] 9.1 核心数据层单元测试
- [x] 9.2 UI 测试（关键流程）
- [x] 9.3 性能优化（大量数据时的滚动性能）
- [x] 9.4 内存泄漏检查

## 完成情况

### 已完成
- ✅ 完整的桌面应用框架（NavigationSplitView + 侧边栏）
- ✅ SwiftData 数据模型（Entry、Tag、ExtractedData）
- ✅ 极简快速输入（QuickEntrySheet、QuickEntryWindow）
- ✅ 全局快捷键服务（HotKeyService）
- ✅ 时间轴视图（日期分组、卡片展示、Markdown 渲染）
- ✅ 搜索和筛选（时间范围、标签、全文搜索）
- ✅ AI 服务（OpenAI + Ollama 双后端）
- ✅ AI 自动处理（提取关键信息、生成标签、生成摘要）
- ✅ AI 汇报生成（支持多种模板）
- ✅ 设置界面（AI 配置、通用设置、数据管理）
- ✅ 菜单栏快捷入口
- ✅ GitHub Actions 自动构建和发布
- ✅ LazyVStack 懒加载优化滚动性能
- ✅ 手动测试验证核心流程
