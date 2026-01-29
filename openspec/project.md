# Project Context

## Purpose
MyTimeline 是一个 macOS 原生应用，帮助用户随手记录工作事项、成果和关键数据，解决答辩/汇报时需要翻找聊天记录的痛点。

## Tech Stack
- Swift 5.9+
- SwiftUI (UI 框架)
- SwiftData (本地数据持久化)
- macOS 14.0+ (Sonoma)

## Project Conventions

### Code Style
- 遵循 Swift API Design Guidelines
- 使用 SwiftLint 进行代码规范检查
- 采用 MVVM 架构模式

### Architecture Patterns
- MVVM + SwiftUI
- Repository Pattern 用于数据访问
- 依赖注入用于服务管理

### Testing Strategy
- 单元测试覆盖核心业务逻辑
- UI 测试覆盖关键用户流程

### Git Workflow
- main 分支为稳定版本
- feature/* 分支用于功能开发
- Conventional Commits 规范

## Domain Context
- 工作记录条目 (Entry): 用户记录的单条工作信息
- 标签 (Tag): 用于分类和筛选的标记
- 时间轴 (Timeline): 按时间顺序展示的记录视图
- 汇报 (Report): AI 生成的工作总结

## Important Constraints
- 仅支持 macOS 14.0+
- 数据仅本地存储，不涉及云同步
- 需要 Accessibility 权限用于全局快捷键

## External Dependencies
- OpenAI API / 本地 LLM 用于 AI 辅助功能
